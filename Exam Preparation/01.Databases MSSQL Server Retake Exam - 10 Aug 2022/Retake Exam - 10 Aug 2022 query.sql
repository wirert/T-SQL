CREATE DATABASE NationalTouristSitesOfBulgaria
GO
USE NationalTouristSitesOfBulgaria
GO

--01. DDL 

CREATE TABLE Categories 
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Municipality] VARCHAR(50),
	[Province] VARCHAR(50)
)

CREATE TABLE Sites
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,	
	[LocationId] INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
	[CategoryId] INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	[Establishment] VARCHAR(15)
)

CREATE TABLE Tourists
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Age] INT NOT NULL CHECK ([Age] BETWEEN 0 AND 120),
	[PhoneNumber] VARCHAR(20) NOT NULL,
	[Nationality] VARCHAR(30) NOT NULL,
	[Reward] VARCHAR(20)
)

CREATE TABLE SitesTourists
(
	[TouristId] INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
	[SiteId] INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL,
	PRIMARY KEY (TouristId, SiteId)
)

CREATE TABLE BonusPrizes
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE TouristsBonusPrizes
(
	[TouristId] INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
	[BonusPrizeId] INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL,
	PRIMARY KEY (TouristId, BonusPrizeId)
)

--02. Insert
INSERT INTO Tourists
	 VALUES ('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL),
			('Peter Bosh', 48, '+447911844141', 'UK', NULL),
			('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
			('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge'),
			('Kremena Popova', 38, '+359893298604', 'Bulgaria', NULL)

INSERT INTO Sites
	 VALUES ('Ustra fortress', 90, 7, 'X'),
			('Karlanovo Pyramids', 65, 7, NULL),
			('The Tomb of Tsar Sevt', 63, 8, 'V BC'),
			('Sinite Kamani Natural Park', 17, 1, NULL),
			('St. Petka of Bulgaria � Rupite', 92, 6, '1994')

--03. Update
UPDATE Sites
   SET Establishment = '(not defined)'
 WHERE Establishment IS NULL

--04. Delete 
DELETE FROM TouristsBonusPrizes
	  WHERE BonusPrizeId = (SELECT Id FROM BonusPrizes WHERE Name = 'Sleeping bag')

DELETE FROM BonusPrizes
WHERE Name = 'Sleeping bag'

--05. Tourists
  SELECT Name
		,Age
		,PhoneNumber
		,Nationality
	FROM Tourists
ORDER BY Nationality, Age DESC, Name

--06. Sites with Their Location and Category
  SELECT s.[Name] AS [Site]
		,l.[Name] AS [Location]
		,s.Establishment
		,c.[Name] AS Category
	FROM Sites AS s
	JOIN Locations AS l ON l.Id = s.LocationId
	JOIN Categories AS c ON c.Id = s.CategoryId
ORDER BY Category DESC, [Location], [Site]

--07. Count of Sites in Sofia Province
  SELECT l.Province
	    ,l.Municipality
	    ,l.[Name] AS [Location]
	    ,COUNT(*) AS CountOfSites
    FROM Locations AS l
    JOIN Sites AS s ON s.LocationId = l.Id
   WHERE l.Province = 'Sofia'
GROUP BY l.Province,l.Municipality, l.Name
ORDER BY CountOfSites DESC, [Location]

--08. Tourist Sites established BC
  SELECT s.[Name] AS [Site]
		,l.[Name] AS [Location]
		,l.Municipality
		,l.Province
		,s.Establishment
	FROM Sites AS s
	JOIN Locations AS l ON l.Id = s.LocationId
   WHERE LEFT(s.[Name], 1) NOT IN ('B', 'M', 'D') 
		 AND Establishment LIKE '%BC%'
ORDER BY [Site]

--09. Tourists with their Bonus Prizes
   SELECT t.[Name]
		 ,t.Age
		 ,t.PhoneNumber
		 ,t.Nationality
		 ,ISNULL(b.[Name], '(no bonus prize)') AS Reward
	 FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tbp ON t.Id = tbp.TouristId
LEFT JOIN BonusPrizes AS b ON b.Id = tbp.BonusPrizeId
 ORDER BY t.[Name]

--10. Tourists visiting History & Archaeology sites
SELECT DISTINCT 
		 SUBSTRING(t.[Name], CHARINDEX(' ',t.[Name]), LEN(t.[Name]))
	  AS LastName
	    ,t.Nationality
		,t.Age
		,t.PhoneNumber
	FROM SitesTourists AS st
	JOIN Tourists AS t ON t.Id = st.TouristId
	JOIN Sites AS s ON s.Id = st.SiteId
	JOIN Categories AS c ON c.Id = s.CategoryId
   WHERE c.[Name] = 'History and archaeology'
ORDER BY LastName
GO

--11. Tourists Count on a Tourist Site
CREATE FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100))
RETURNS INT AS
BEGIN
	RETURN(
			SELECT COUNT(*)
			  FROM Sites AS s
		 LEFT JOIN SitesTourists AS st ON s.Id = st.SiteId
		 LEFT JOIN Tourists AS t ON t.Id = st.TouristId
			 WHERE s.[Name] = @Site)
END

GO
--12. Annual Reward Lottery
CREATE PROC usp_AnnualRewardLottery 
	(@TouristName VARCHAR(50)) AS
BEGIN
	DECLARE @touristId INT = (SELECT Id FROM Tourists WHERE Name = @TouristName);
	DECLARE @sitesVisited INT = (SELECT COUNT(*) FROM SitesTourists WHERE TouristId = @touristId)
	DECLARE @reward VARCHAR(20) = NULL;

	IF (@sitesVisited >= 100) SET @reward = 'Gold badge'
	ELSE IF (@sitesVisited >= 50) SET @reward = 'Silver badge'
	ELSE IF (@sitesVisited >= 25) SET @reward = 'Bronze badge'

	UPDATE Tourists
	   SET Reward = @reward

	SELECT Name
		  ,Reward
	  FROM Tourists
	 WHERE Name = @TouristName

END







