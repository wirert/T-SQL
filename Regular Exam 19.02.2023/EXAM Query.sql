CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY,
	StreetName NVARCHAR(100) NOT NULL,
	StreetNumber INT NOT NULL,
	Town VARCHAR(30) NOT NULL,
	Country VARCHAR(50) NOT NULL,
	ZIP INT NOT NULL
)

CREATE TABLE Publishers
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) UNIQUE NOT NULL,
	AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id),
	Website NVARCHAR(40),
	Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
	Id INT PRIMARY KEY IDENTITY,
	PlayersMin INT NOT NULL,
	PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	YearPublished INT NOT NULL,
	Rating DECIMAL(4,2) NOT NULL,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
	PublisherId INT NOT NULL FOREIGN KEY REFERENCES Publishers(Id),
	PlayersRangeId INT NOT NULL FOREIGN KEY REFERENCES PlayersRanges(Id)
)

CREATE TABLE Creators
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
	CreatorId INT FOREIGN KEY REFERENCES Creators(Id),
	BoardgameId INT FOREIGN KEY REFERENCES Boardgames(Id),
	PRIMARY KEY (CreatorId, BoardgameId)
)

--02. Insert
INSERT INTO Boardgames
	 VALUES
	 	('Deep Blue', 2019,	5.67, 1, 15, 7),
		('Paris', 2016, 9.78, 7, 1, 5),
		('Catan: Starfarers', 2021,	9.87, 7, 13, 6),
		('Bleeding Kansas',	2020, 3.25,	3, 7, 4),
		('One Small Step',	2019, 5.75,	5, 9, 2)

INSERT INTO Publishers
	 VALUES
		('Agman Games',	5, 'www.agmangames.com', '+16546135542'),
		('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
		('BattleBooks',	13,	'www.battlebooks.com', '+12345678907')

--03. Update
UPDATE PlayersRanges
   SET PlayersMax +=1
 WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
   SET [Name] = CONCAT([Name], 'V2')
 WHERE YearPublished >= 2020

--04. Delete
 ALTER TABLE Publishers
ALTER COLUMN AddressId INT NULL

UPDATE Publishers
   SET AddressId = NULL
 WHERE AddressId IN (SELECT Id FROM Addresses WHERE LEFT(Town, 1) = 'L')

DELETE FROM Addresses
	  WHERE Id IN (SELECT Id FROM Addresses WHERE LEFT(Town, 1) = 'L')

 ALTER TABLE Boardgames
ALTER COLUMN PublisherId INT

UPDATE Boardgames
   SET PublisherId = NULL
 WHERE PublisherId IN (SELECT Id FROM Publishers WHERE AddressId IS NULL)

DELETE FROM CreatorsBoardgames
	  WHERE BoardgameId IN (SELECT Id FROM Boardgames WHERE PublisherId IS NULL)

DELETE FROM Boardgames
	  WHERE PublisherId IS NULL

DELETE FROM Publishers
      WHERE AddressId IS NULL	  

--05. Boardgames by Year of Publication 
  SELECT [Name],
		 Rating
	FROM Boardgames
ORDER BY YearPublished, [Name] DESC

--06. Boardgames by Category
  SELECT b.Id,
		 b.Name,
		 b.YearPublished,
		 c.Name AS CategoryName
	FROM Boardgames AS b
	JOIN Categories AS c ON b.CategoryId = c.Id
   WHERE c.Name IN ('Strategy Games', 'Wargames')
ORDER BY b.YearPublished DESC

--07. Creators without Boardgames
   SELECT c.Id,
		  CONCAT(FirstName,' ', LastName) 
	   AS CreatorName,
		  c.Email
	 FROM Creators AS c
LEFT JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
	WHERE cb.BoardgameId IS NULL
 ORDER BY CreatorName

--08. First 5 Boardgames
  SELECT 
   TOP 5 b.[Name],
		 b.Rating,
		 c.[Name] AS CategoryName
	FROM Boardgames AS b
	JOIN PlayersRanges AS pr ON b.PlayersRangeId = pr.Id
	JOIN Categories AS c ON c.Id = b.CategoryId
   WHERE (Rating > 7 AND b.[Name] LIKE '%a%')
      OR (Rating > 7.5 AND (PlayersMin = 2 AND PlayersMax = 5))
ORDER BY b.Name, b.Rating DESC

--09. Creators with Emails
  SELECT FullName,
		 Email,
		 Rating
	FROM (
	  SELECT CONCAT(FirstName, ' ',LastName)
		  AS FullName,
			 c.Email,
			 b.Rating,
			 DENSE_RANK() OVER (PARTITION BY c.Id ORDER BY b.Rating DESC)
		  AS RankedRating
		FROM Creators AS c
		JOIN CreatorsBoardgames AS cb ON cb.CreatorId = c.Id
		JOIN Boardgames AS b ON b.Id = cb.BoardgameId
	   WHERE RIGHT(c.Email, 4) = '.com'
	      ) 
	  AS RankedSubquery
   WHERE RankedRating = 1
ORDER BY FullName

--10. Creators by Rating
  SELECT c.LastName,
		 CEILING(AVG(b.Rating)) AS AverageRating,
		 p.[Name] AS PublisherName
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON cb.CreatorId = c.Id
	JOIN Boardgames AS b ON b.Id = cb.BoardgameId
	JOIN Publishers AS p ON p.Id = b.PublisherId
GROUP BY c.LastName, p.[Name]
  HAVING p.[Name] = 'Stonemaier Games'
ORDER BY AVG(b.Rating) DESC

--11. Creator with Boardgames
GO

CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30))
RETURNS INT AS
BEGIN
	RETURN (
		SELECT COUNT(cb.BoardgameId)
		  FROM Creators AS c
		  JOIN CreatorsBoardgames AS cb ON cb.CreatorId = c.Id
		 WHERE c.FirstName = @name
		   )			
END

GO
SELECT dbo.udf_CreatorWithBoardgames('Bruno')
GO

--12. Search for Boardgame with Specific Category
CREATE PROC usp_SearchByCategory
 (@category VARCHAR(50)) AS
BEGIN
	SELECT b.[Name],
		   b.YearPublished,
		   b.Rating,
		   c.[Name] AS CategoryName,
		   p.[Name] AS PublisherName,
		   CONCAT(PlayersMin, ' people') AS MinPlayers,
		   CONCAT(PlayersMax, ' people') AS MaxPlayers
	  FROM Boardgames AS b
	  JOIN Categories AS c ON c.Id = b.CategoryId
	  JOIN Publishers AS p ON p.Id = b.PublisherId
	  JOIN PlayersRanges AS pr ON pr.Id = b.PlayersRangeId
	 WHERE c.[Name] = @category
  ORDER BY PublisherName, YearPublished DESC
END

GO
EXEC usp_SearchByCategory 'Wargames'