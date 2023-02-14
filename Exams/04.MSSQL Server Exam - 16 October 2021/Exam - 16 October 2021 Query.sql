CREATE DATABASE CigarShop
GO
USE CigarShop
GO

--01. DDL 
CREATE TABLE Sizes
	(
		Id INT PRIMARY KEY IDENTITY,
		Length INT NOT NULL CHECK (Length BETWEEN 10 AND 25),
		RingRange DECIMAL(3,2) NOT NULL CHECK(RingRange BETWEEN 1.50 AND 7.50)
	)

CREATE TABLE Tastes
	(
		Id INT PRIMARY KEY IDENTITY,
		TasteType VARCHAR(20) NOT NULL,
		TasteStrength VARCHAR(20) NOT NULL,
		ImageURL NVARCHAR(100) NOT NULL
	)

CREATE TABLE Brands
	(
		Id INT PRIMARY KEY IDENTITY,
		BrandName VARCHAR(30) NOT NULL UNIQUE,
		BrandDescription VARCHAR(MAX)
	)

CREATE TABLE Cigars
	(
		Id INT PRIMARY KEY IDENTITY,
		CigarName VARCHAR(80) NOT NULL,
		BrandId INT NOT NULL FOREIGN KEY REFERENCES Brands(Id),
		TastId INT NOT NULL FOREIGN KEY REFERENCES Tastes(Id),
		SizeId INT NOT NULL FOREIGN KEY REFERENCES Sizes(Id),
		PriceForSingleCigar MONEY NOT NULL,
		ImageURL NVARCHAR(100) NOT NULL
	)

CREATE TABLE Addresses
	(
		Id INT PRIMARY KEY IDENTITY,
		Town VARCHAR(30) NOT NULL,
		Country NVARCHAR(30) NOT NULL,
		Streat NVARCHAR(100) NOT NULL,
		ZIP VARCHAR(20) NOT NULL
	)

CREATE TABLE Clients
	(
		Id INT PRIMARY KEY IDENTITY,
		FirstName NVARCHAR(30) NOT NULL,
		LastName NVARCHAR(30) NOT NULL,
		Email NVARCHAR(50) NOT NULL,
		AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id)
	)

CREATE TABLE ClientsCigars
	(
		ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id),
		CigarId INT NOT NULL FOREIGN KEY REFERENCES Cigars(Id),
		PRIMARY KEY (CigarId, ClientId)
	)

--02. Insert 
INSERT INTO Cigars
	 VALUES
		('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg'),
		('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg'),
		('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg'),
		('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg'),
		('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses
	 VALUES
		('Sofia', 'Bulgaria', '18 Bul. Vasil levski', '1000'),
		('Athens', 'Greece', '4342 McDonald Avenue', '10435'),
		('Zagreb', 'Croatia', '4333 Lauren Drive', '10000')

--03. Update
UPDATE Cigars
   SET PriceForSingleCigar *= 1.2
 WHERE (SELECT Id FROM Tastes WHERE TasteType = 'Spicy') = TastId

UPDATE Brands
   SET BrandDescription = 'New description'
 WHERE BrandDescription IS NULL

--04. Delete
ALTER TABLE Clients
ALTER COLUMN AddressId INT 

UPDATE Clients
   SET AddressId = NULL
 WHERE AddressId IN (SELECT Id FROM Addresses WHERE LEFT(Country, 1) = 'C')


DELETE FROM Addresses
      WHERE LEFT(Country, 1) = 'C'

--05. Cigars by Price
  SELECT CigarName
		,PriceForSingleCigar
		,ImageURL
	FROM Cigars
ORDER BY PriceForSingleCigar, CigarName DESC

--06. Cigars by Taste
  SELECT c.Id
		,c.CigarName
		,c.PriceForSingleCigar
		,t.TasteType
		,t.TasteStrength
	FROM Cigars AS c
	JOIN Tastes AS t ON c.TastId = t.Id
   WHERE t.TasteType IN ('Earthy', 'Woody')
ORDER BY c.PriceForSingleCigar DESC

--07. Clients without Cigars
   SELECT c.Id
		 ,CONCAT(FirstName,' ',LastName) 
	   AS ClientName
		 ,c.Email
	 FROM Clients AS c
LEFT JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
	WHERE cc.CigarId IS NULL
 ORDER BY ClientName

--08. First 5 Cigars
  SELECT
   TOP 5 c.CigarName
		,c.PriceForSingleCigar
		,c.ImageURL
	FROM Cigars AS c
	JOIN Sizes AS s ON s.Id = c.SizeId
   WHERE s.Length >= 12
     AND (CHARINDEX('ci', c.CigarName) <> 0 
		  OR c.PriceForSingleCigar > 50) 
	 AND s.RingRange > 2.55
ORDER BY c.CigarName, c.PriceForSingleCigar DESC

--09. Clients with ZIP Codes
  SELECT CONCAT(FirstName, ' ',LastName) 
	  AS FullName,
		 Country,
		 ZIP,
		 CONCAT('$', MAX(PriceForSingleCigar))
	  AS CigarPrice
	FROM Clients AS c
	JOIN Addresses AS a ON a.Id = c.AddressId
	JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
	JOIN Cigars AS cg ON cg.Id = cc.CigarId
   WHERE TRY_PARSE(a.ZIP AS BIGINT) IS NOT NULL
GROUP BY c.FirstName,c.LastName,a.Country,a.ZIP
ORDER BY FullName 

--10. Cigars by Size
  SELECT LastName
		,CEILING(AVG(s.Length))
	  AS CiagrLength
		,CEILING(AVG(s.RingRange))
	  AS CiagrRingRange
	FROM ClientsCigars AS cc
	JOIN Clients AS cl ON cl.Id = cc.ClientId
	JOIN Cigars AS c ON c.Id = cc.CigarId
	JOIN Sizes AS s ON s.Id = c.SizeId
GROUP BY cl.LastName
ORDER BY CiagrLength DESC
GO

--11. Client with Cigars 
CREATE FUNCTION udf_ClientWithCigars(@name NVARCHAR(30)) 
RETURNS INT AS
BEGIN
	RETURN
	(
		SELECT COUNT(*)
		  FROM ClientsCigars AS cc
		  JOIN Clients AS c ON c.Id = cc.ClientId
		 WHERE FirstName = @name
	)
END
GO

--12. Search for Cigar with Specific Taste
CREATE PROC usp_SearchByTaste 
	@taste VARCHAR(20) AS
BEGIN
	SELECT c.CigarName
		  ,CONCAT('$', PriceForSingleCigar) AS Price
		  ,TasteType
		  ,BrandName
		  ,CONCAT(Length, ' cm') AS CigarLength
		  ,CONCAT(RingRange,' cm') AS CigarRingRange
	  FROM Cigars AS c
	  JOIN Brands AS b ON c.BrandId = b.Id
	  JOIN Sizes AS s ON s.Id = c.SizeId
	  JOIN Tastes AS t ON t.Id = c.TastId
	 WHERE t.TasteType = @taste
  ORDER BY CigarLength, CigarRingRange DESC
END