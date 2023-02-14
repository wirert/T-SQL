CREATE DATABASE Airport
GO
USE Airport
GO

--01. DDL
CREATE TABLE Passengers
	(
		Id INT PRIMARY KEY IDENTITY,
		FullName VARCHAR(100) UNIQUE NOT NULL,
		Email VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Pilots
	(
		Id INT PRIMARY KEY IDENTITY,
		FirstName VARCHAR(30) UNIQUE NOT NULL,
		LastName VARCHAR(30) UNIQUE NOT NULL,
		Age TINYINT NOT NULL CHECK (Age BETWEEN 21 AND 62),
		Rating FLOAT CHECK (Rating BETWEEN 0.0 AND 10.0)
	)

CREATE TABLE AircraftTypes
	(
		Id INT PRIMARY KEY IDENTITY,
		TypeName VARCHAR(30) UNIQUE NOT NULL
	)

CREATE TABLE Aircraft
	(
		Id INT PRIMARY KEY IDENTITY,
		Manufacturer VARCHAR(25) NOT NULL,
		Model VARCHAR(30) NOT NULL,
		[Year] INT NOT NULL,
		FlightHours INT,
		Condition CHAR(1) NOT NULL,
		TypeId INT NOT NULL FOREIGN KEY REFERENCES AircraftTypes(Id)
	)

CREATE TABLE PilotsAircraft
	(
		AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id),
		PilotId INT FOREIGN KEY REFERENCES Pilots(Id),
		PRIMARY KEY (AircraftId, PilotId)
	)

CREATE TABLE Airports
	(
		Id INT PRIMARY KEY IDENTITY,
		AirportName VARCHAR(70) UNIQUE NOT NULL,
		Country VARCHAR(100) UNIQUE NOT NULL
	)

CREATE TABLE FlightDestinations
	(
		Id INT PRIMARY KEY IDENTITY,
		AirportId INT NOT NULL FOREIGN KEY REFERENCES Airports(Id),
		Start DATETIME NOT NULL,
		AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft(Id),
		PassengerId INT NOT NULL FOREIGN KEY REFERENCES Passengers(Id),
		TicketPrice DECIMAL(18, 2) NOT NULL DEFAULT(15)
	)

--02. Insert
INSERT INTO Passengers
	 SELECT CONCAT(FirstName, ' ',LastName),
			CONCAT(FirstName,LastName, '@gmail.com')
	   FROM Pilots
	  WHERE Id BETWEEN 5 AND 15

--03. Update
UPDATE Aircraft
   SET Condition = 'A'
 WHERE Condition IN ('B', 'C')
	   AND (FlightHours IS NULL OR FlightHours <= 100)
	   AND Year >= 2013
			
--04. Delete
DELETE FROM Passengers
	  WHERE LEN(FullName) <= 10

--05. Aircraft 
  SELECT Manufacturer,
	     Model,
	     FlightHours,
	     Condition
    FROM Aircraft
ORDER BY FlightHours DESC

--06. Pilots and Aircraft
  SELECT p.FirstName,
		 p.LastName,
		 a.Manufacturer,
		 a.Model,
		 a.FlightHours
	FROM Pilots AS p
	JOIN PilotsAircraft AS pa ON p.Id = pa.PilotId
	JOIN Aircraft AS a ON a.Id = pa.AircraftId
   WHERE a.FlightHours IS NOT NULL
		 AND a.FlightHours < 304
ORDER BY FlightHours DESC, FirstName

--07. Top 20 Flight Destinations
  SELECT
  TOP 20 d.Id AS DestinationId		
		,d.Start
		,p.FullName
		,a.AirportName
		,d.TicketPrice
	FROM FlightDestinations AS d
	JOIN Passengers AS p ON p.Id = d.PassengerId
	JOIN Airports AS a ON a.Id = d.AirportId
   WHERE DAY(d.Start) % 2 = 0
ORDER BY TicketPrice DESC, AirportName

--08. Number of Flights for Each Aircraft
  SELECT AircraftId
		,Manufacturer
		,FlightHours
		,COUNT(*) AS FlightDestinationsCount
		,ROUND(AVG(TicketPrice), 2) AS AvgPrice
	FROM Aircraft AS a
	JOIN FlightDestinations AS d ON d.AircraftId = a.Id
GROUP BY AircraftId, Manufacturer, FlightHours
  HAVING COUNT(*) >= 2
ORDER BY FlightDestinationsCount DESC, AircraftId

--09. Regular Passengers
  SELECT FullName
		,COUNT(*) AS CountOfAircraft
		,SUM(TicketPrice) AS TotalPayed
	FROM Passengers AS p
	JOIN FlightDestinations AS d ON p.Id = d.PassengerId
   WHERE SUBSTRING(FullName, 2,1) = 'a'
GROUP BY FullName
  HAVING COUNT(*) > 1
ORDER BY FullName

--10. Full Info for Flight Destinations
  SELECT a.AirportName
		,d.[Start] AS DayTime
		,d.TicketPrice
		,p.FullName
		,ac.Manufacturer
		,ac.Model
	FROM FlightDestinations AS d
	JOIN Passengers AS p ON p.Id = d.PassengerId
	JOIN Airports AS a ON a.Id = d.AirportId
	JOIN Aircraft AS ac ON ac.Id = d.AircraftId
   WHERE CAST(d.[Start] AS TIME) BETWEEN '06:00' AND '20:00'
		 AND TicketPrice > 2500
ORDER BY Model
GO

--11. Find all Destinations by Email Address
CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50)) 
RETURNS INT AS
BEGIN
	RETURN 
		(
			SELECT COUNT(d.Id)
			  FROM Passengers AS p
		 LEFT JOIN FlightDestinations AS d ON p.Id = d.PassengerId
			 WHERE Email = @email
		  GROUP BY p.Id		    
		)
END
GO

--12. Full Info for Airports
CREATE PROC usp_SearchByAirportName
	@airportName VARCHAR(70) AS
BEGIN
	SELECT ap.AirportName
		  ,p.FullName
		  ,CASE
				WHEN d.TicketPrice <= 400 THEN 'Low'
				WHEN d.TicketPrice <= 1500 THEN 'Medium'
				ELSE 'High'
		   END
		AS LevelOfTickerPrice
		  ,a.Manufacturer
		  ,a.Condition
		  ,t.TypeName
	  FROM FlightDestinations AS d
	  JOIN Airports AS ap ON ap.Id = d.AirportId
	  JOIN Passengers AS p ON p.Id = d.PassengerId
	  JOIN Aircraft AS a ON a.Id = d.AircraftId
	  JOIN AircraftTypes AS t ON t.Id = a.TypeId
	 WHERE ap.AirportName = @airportName
  ORDER BY Manufacturer, FullName
END