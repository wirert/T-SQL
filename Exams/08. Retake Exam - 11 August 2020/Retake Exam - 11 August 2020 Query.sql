CREATE DATABASE Bakery
GO
USE Bakery
GO

--01. DDL
CREATE TABLE Countries
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Customers
	(
		Id INT PRIMARY KEY IDENTITY,
		FirstName NVARCHAR(25) NOT NULL,
		LastName NVARCHAR(25) NOT NULL,
		Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
		Age INT,
		PhoneNumber CHAR(10) NOT NULL CHECK (LEN(PhoneNumber) = 10),
		CountryId INT FOREIGN KEY REFERENCES Countries(Id)
	)

CREATE TABLE Products
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(25) NOT NULL UNIQUE,
		[Description] NVARCHAR(250),
		Recipe NVARCHAR(MAX) NOT NULL,
		Price MONEY NOT NULL CHECK (Price >= 0)
	)

CREATE TABLE Feedbacks
	(
		Id INT PRIMARY KEY IDENTITY,
		[Description] NVARCHAR(255),
		Rate DECIMAL(3,2) NOT NULL CHECK(Rate BETWEEN 0.00 AND 10.00),
		ProductId INT NOT NULL FOREIGN KEY REFERENCES Products(Id),
		CustomerId INT NOT NULL FOREIGN KEY REFERENCES Customers(Id)
	)

CREATE TABLE Distributors
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(25) NOT NULL UNIQUE,
		AddressText NVARCHAR(30) UNIQUE NOT NULL,
		Summary NVARCHAR(200),
		CountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id)
	)

CREATE TABLE Ingredients
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] NVARCHAR(30) NOT NULL,
		[Description] NVARCHAR(200),
		OriginCountryId INT NOT NULL FOREIGN KEY REFERENCES Countries(Id),
		DistributorId INT NOT NULL FOREIGN KEY REFERENCES Distributors(Id)
	)

CREATE TABLE ProductsIngredients
	(
		ProductId INT FOREIGN KEY REFERENCES Products(Id),
		IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id),
		PRIMARY KEY (ProductId, IngredientId)
	)

--02. Insert
INSERT INTO Distributors ([Name], CountryId, AddressText, Summary)
	 VALUES
		('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
		('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
		('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
		('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
		('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers (FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
	 VALUES
		('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
		('Kendra', 'Loud', 22, 'F', '0063631526', 11),
		('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
		('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
		('Tom', 'Loeza', 31, 'M', '0144876096', 23),
		('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
		('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
		('Josefa', 'Opitz', 43, 'F', '0197887645', 17)

--03. Update
UPDATE Ingredients
   SET DistributorId = 35
 WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')
						
UPDATE Ingredients
   SET OriginCountryId = 14
 WHERE OriginCountryId = 8

--04. Delete
DELETE FROM Feedbacks
	  WHERE CustomerId = 14 OR ProductId = 5

--05. Products By Price
  SELECT [Name],
		 Price,
		 [Description]
	FROM Products
ORDER BY Price DESC, [Name]

--06. Negative Feedback
  SELECT ProductId,
		 Rate,
		 [Description],
		 CustomerId,
		 Age,
		 Gender
	FROM Feedbacks AS f
	JOIN Customers AS c ON c.Id = f.CustomerId
   WHERE f.Rate < 5.0
ORDER BY f.ProductId DESC, Rate

--07. Customers without Feedback 
   SELECT CONCAT(FirstName, ' ', LastName) AS CustomerName,
		  PhoneNumber,
		  Gender
	 FROM Customers AS c
LEFT JOIN Feedbacks AS f ON c.Id = f.CustomerId
	WHERE f.Id IS NULL
 ORDER BY c.Id

--08. Customers by Criteria
  SELECT FirstName,
		 Age,
		 PhoneNumber
	FROM Customers
   WHERE (AGE >= 21 AND FirstName LIKE '%an%')
		OR (RIGHT(PhoneNumber, 2) = '38' AND CountryId <> (SELECT Id FROM Countries WHERE Name = 'Greece'))
ORDER BY FirstName, Age DESC

--09. Middle Range Distributors
  SELECT d.Name AS DistributorName,
		 i.Name AS IngredientName,
		 p.Name AS ProductName,
		 AVG(f.Rate) AS AverageRate
	FROM ProductsIngredients AS pri
	JOIN Ingredients AS i ON i.Id = pri.IngredientId
	JOIN Products AS p ON p.Id = pri.ProductId
	JOIN Distributors AS d ON d.Id = i.DistributorId
	JOIN Feedbacks AS f ON f.ProductId = p.Id
GROUP BY d.Name, i.Name, p.Name
  HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY DistributorName, IngredientName, ProductName

--10. Country Representative
  SELECT CountryName,
		 DisributorName
	FROM(
		  SELECT c.Name AS CountryName,
				 d.Name AS DisributorName,
				 DENSE_RANK() OVER (PARTITION BY c.Name ORDER BY COUNT(i.Id) DESC) AS [Rank]
			FROM Countries AS c 
			JOIN Distributors AS d ON d.CountryId = c.Id
	   LEFT JOIN Ingredients AS i ON d.Id = i.DistributorId
		GROUP BY c.Name, d.Name
		)
	  AS RankedQuery
   WHERE [Rank] = 1
ORDER BY CountryName, DisributorName
GO

--11. Customers With Countries
CREATE VIEW v_UserWithCountries 
AS
	(
	  SELECT CONCAT(c.FirstName,' ',c.LastName) AS CustomerName,
			 Age,
			 Gender,
			 ct.Name AS CountryName
		FROM Customers AS c
		JOIN Countries AS ct ON c.CountryId = ct.Id
	)
GO
SELECT TOP 5 *
        FROM v_UserWithCountries
    ORDER BY Age

GO

--12. Delete Products
CREATE TRIGGER tr_delete_relations_product 
ON Products INSTEAD OF DELETE
AS
BEGIN TRANSACTION
	DELETE FROM Feedbacks
		  WHERE ProductId IN (SELECT Id FROM deleted);

	DELETE FROM ProductsIngredients
		  WHERE ProductId IN (SELECT Id FROM deleted);

	DELETE FROM Products
		  WHERE Id IN (SELECT Id FROM deleted);
COMMIT
GO

DELETE FROM Products WHERE Id = 7