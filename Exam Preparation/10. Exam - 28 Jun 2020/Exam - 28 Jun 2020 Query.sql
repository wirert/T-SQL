--01. DDL
CREATE TABLE Planets
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL FOREIGN KEY REFERENCES Planets(Id)
)

CREATE TABLE Spaceships
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK (Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards
(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber CHAR(10) NOT NULL UNIQUE CHECK(LEN(CardNumber) = 10),
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT NOT NULL FOREIGN KEY REFERENCES Colonists(Id),
	JourneyId INT NOT NULL FOREIGN KEY REFERENCES Journeys(Id)
)

--02. Insert
INSERT INTO Planets
	 VALUES
		('Mars'), 
		('Earth'), 
		('Jupiter'), 
		('Saturn')

INSERT INTO Spaceships
	 VALUES
		('Golf', 'VW', 3), 
		('WakaWaka', 'Wakanda', 4), 
		('Falcon9', 'SpaceX', 1), 
		('Bed', 'Vidolov', 6)

--03. Update
UPDATE Spaceships
   SET LightSpeedRate += 1
 WHERE Id BETWEEN 8 AND 12

--04. Delete
DELETE FROM TravelCards
	  WHERE JourneyId BETWEEN 1 AND 3

DELETE FROM Journeys
	  WHERE Id BETWEEN 1 AND 3

--05. Select All Military Journeys
  SELECT Id,
		 FORMAT(JourneyStart, 'dd/MM/yyyy')
	  AS JourneyStart,
	     FORMAT(JourneyEnd, 'dd/MM/yyyy')
	  AS JourneyEnd
	FROM Journeys
   WHERE Purpose = 'Military'
ORDER BY JourneyStart

--06. Select All Pilots
  SELECT c.Id,
		 CONCAT(FirstName, ' ', LastName) 
	  AS FullName
	FROM Colonists AS c
	JOIN TravelCards AS tc ON c.Id = tc.ColonistId
   WHERE tc.JobDuringJourney = 'Pilot'
ORDER BY c.Id

--07. Count Colonists
SELECT COUNT(c.Id) AS [Count]
  FROM Colonists AS c
  JOIN TravelCards AS tc ON tc.ColonistId = c.Id
  JOIN Journeys AS j ON j.Id = tc.JourneyId
 WHERE j.Purpose = 'technical'

--08. Select Spaceships With Pilots
  SELECT s.[Name],
		 s.Manufacturer
	FROM Spaceships AS s
	JOIN Journeys AS j ON j.SpaceshipId = s.Id
	JOIN TravelCards AS tc ON tc.JourneyId = j.Id
	JOIN Colonists AS c ON c.Id = tc.ColonistId
   WHERE tc.JobDuringJourney = 'Pilot' AND DATEDIFF(YEAR, c.BirthDate, '2019-01-01') < 30
ORDER BY s.[Name]

--09. Planets And Journeys 
  SELECT p.[Name] AS PlanetName,
		 COUNT(j.Id) AS JourneysCount
	FROM Planets AS p
	JOIN Spaceports AS s ON p.Id = s.PlanetId
	JOIN Journeys AS j ON j.DestinationSpaceportId = s.Id
GROUP BY p.[Name]
ORDER BY JourneysCount DESC, PlanetName

--10. Select Special Colonists
SELECT *
  FROM (
	SELECT tc.JobDuringJourney,
		   CONCAT(c.FirstName, ' ', c.LastName)
		AS FullName,
		   DENSE_RANK() OVER 
							(PARTITION BY tc.JobDuringJourney
								 ORDER BY c.BirthDate
							)
		AS JobRank
	  FROM Colonists AS c
	  JOIN TravelCards AS tc ON tc.ColonistId = c.Id
	   ) 
    AS RankedSubquery
 WHERE JobRank = 2

 GO
--11. Get Colonists Count
CREATE FUNCTION udf_GetColonistsCount
 (@PlanetName VARCHAR (30))
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(t.ColonistId)				  
			 FROM Planets AS p
			 JOIN Spaceports AS s ON p.Id = s.PlanetId
			 JOIN Journeys AS j ON j.DestinationSpaceportId = s.Id
			 JOIN TravelCards AS t ON t.JourneyId = j.Id
		    WHERE p.[Name] = @PlanetName)
END

GO
--12. Change Journey Purpose
CREATE PROC usp_ChangeJourneyPurpose
 @JourneyId INT, @NewPurpose VARCHAR(11)
AS
BEGIN
	IF @JourneyId NOT IN (SELECT Id FROM Journeys) 
		BEGIN
			RAISERROR('The journey does not exist!', 16, 1)
			RETURN
		END

	IF @NewPurpose = (SELECT Purpose FROM Journeys WHERE Id = @JourneyId)
		BEGIN
			RAISERROR('You cannot change the purpose!', 16, 1)
			RETURN
		END

	UPDATE Journeys
	   SET Purpose = @NewPurpose
	 WHERE Id = @JourneyId
END

