CREATE DATABASE TripService
GO
USE TripService
GO

--01. DDL
CREATE TABLE Cities
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(5,2)
)

CREATE TABLE Rooms
(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL (6,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT NOT NULL FOREIGN KEY REFERENCES Hotels(Id)
)

CREATE TABLE Trips
(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT NOT NULL FOREIGN KEY REFERENCES Rooms(Id),
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,
	CHECK (BookDate < ArrivalDate),
	CHECK (ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips
(
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	TripId INT FOREIGN KEY REFERENCES Trips(Id),
	Luggage INT NOT NULL CHECK (Luggage >= 0),
	PRIMARY KEY (AccountId, TripId)
)


--02. Insert
INSERT INTO Accounts
	 VALUES
		('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
		('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
		('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
		('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips
	 VALUES
		( 101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
		( 102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
		( 103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
		( 104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
		( 109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

--03. Update
UPDATE Rooms
   SET Price *= 1.14
 WHERE HotelId IN (5,7,9)

--04. Delete
DELETE FROM AccountsTrips
	  WHERE AccountId = 47

--05. EEE-Mails
  SELECT a.FirstName,
		 a.LastName,
		 FORMAT(a.BirthDate, 'MM-dd-yyyy') AS BirthDate,
		 c.[Name] AS Hometown,
		 a.Email
	FROM Accounts AS a
	JOIN Cities AS c ON c.Id = a.CityId
   WHERE LEFT(Email, 1) = 'e'
ORDER BY c.[Name]

--06. City Statistics
  SELECT c.[Name] AS City,
		 COUNT(h.Id) AS Hotels
	FROM Cities AS c
	JOIN Hotels AS h ON h.CityId = c.Id
GROUP BY c.Id, c.[Name]
ORDER BY Hotels DESC, City

--07. Longest and Shortest Trips
  SELECT a.Id,
	  CONCAT(FirstName, ' ', LastName)
   AS FullName,
	  MAX(DATEDIFF(DAY, ArrivalDate, ReturnDate))
   AS LongestTrip,
      MIN(DATEDIFF(DAY, ArrivalDate, ReturnDate))
   AS ShortestTrip
 FROM Accounts AS a
 JOIN AccountsTrips AS at ON at.AccountId = a.Id
 JOIN Trips AS t ON t.Id = at.TripId
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id, a.FirstName, a.LastName
ORDER BY LongestTrip DESC, ShortestTrip

--08. Metropolis
  SELECT
  TOP 10 c.Id,
		 c.Name AS City,
		 c.CountryCode AS Country,
		 COUNT(a.Id) AS Accounts
	FROM Cities AS c
	JOIN Accounts AS a ON a.CityId = c.Id
GROUP BY c.Id, c.Name, c.CountryCode
ORDER BY Accounts DESC

--09. Romantic Getaways
   SELECT a.Id,
 		  a.Email,
 		  c.Name AS City,
 		  COUNT(t.Id) AS Trips
 	 FROM Accounts AS a
 	 JOIN Cities AS c ON c.Id = a.CityId
LEFT JOIN AccountsTrips AS at ON at.AccountId = a.Id
LEFT JOIN Trips AS t ON t.Id = at.TripId
LEFT JOIN Rooms AS r ON r.Id = t.RoomId
LEFT JOIN Hotels AS h ON h.Id = r.HotelId	
    WHERE h.CityId = a.CityId
 GROUP BY a.Id, a.Email, c.Name
   HAVING COUNT(t.Id) >= 1
 ORDER BY Trips DESC, Id

--10. GDPR Violation
  SELECT t.Id,
		 CONCAT(a.FirstName + ' ', a.MiddleName + ' ', a.LastName) AS FullName,
	     c.[Name] AS [From],
		 ch.[Name] AS [To],
		 CASE
			WHEN t.CancelDate IS NULL THEN CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
			ELSE 'Canceled'
		 END
	  AS Duration
	FROM Trips AS t
	JOIN AccountsTrips AS at ON t.Id = at.TripId
	JOIN Accounts AS a ON a.Id = at.AccountId
	JOIN Cities AS c ON c.Id = a.CityId
	JOIN Rooms AS r ON r.Id = t.RoomId
	JOIN Hotels AS h ON h.Id = r.HotelId
	JOIN Cities AS ch ON ch.Id = h.CityId
ORDER BY FullName, t.Id

GO
--11. Available Room
CREATE FUNCTION udf_GetAvailableRoom
 (@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(MAX)
BEGIN
	DECLARE @RoomId INT = (
						SELECT 
						 TOP 1 r.Id
						  FROM Rooms AS r
						  JOIN Hotels AS h ON h.Id = r.HotelId
					 LEFT JOIN Trips AS t ON r.Id = t.RoomId						  
						 WHERE r.HotelId = @HotelId
							   AND r.Beds >= @People
							   AND r.Id NOT IN
											(
										SELECT RoomId 
										  FROM Trips
										 WHERE @Date BETWEEN ArrivalDate AND ReturnDate 
										      AND CancelDate IS NULL
											)
					  ORDER BY r.Price DESC
						  )

	IF (@RoomId IS NULL) RETURN 'No rooms available'
	ELSE 		
		DECLARE @RoomType NVARCHAR(20) = (SELECT Type FROM Rooms WHERE Id = @RoomId)
		DECLARE @Beds INT = (SELECT Beds FROM Rooms WHERE Id = @RoomId)
		DECLARE @TotalPrice DECIMAL(8,2) = ((SELECT BaseRate FROM Hotels WHERE Id = @HotelId) 
										  + (SELECT Price FROM Rooms WHERE Id = @RoomId)) 
										  * @People

		RETURN CONCAT('Room ',@RoomId,': ', @RoomType,' (',@Beds, ' beds) - $', @TotalPrice)		
END
GO

--12. Switch Room
CREATE PROC usp_SwitchRoom 
 @TripId INT, @TargetRoomId INT
AS
BEGIN
	DECLARE @TripRoomId INT = (SELECT TOP 1 RoomId FROM Trips WHERE Id = @TripId)
	DECLARE @Accounts INT = (SELECT COUNT(*) FROM AccountsTrips WHERE TripId = @TripId)

	IF ((SELECT TOP 1 HotelId FROM Rooms WHERE Id = @TripRoomId) <> (SELECT TOP 1 HotelId FROM Rooms WHERE Id = @TargetRoomId))
		BEGIN
			RAISERROR('Target room is in another hotel!', 16, 1)
			RETURN
		END
	IF ((SELECT TOP 1 Beds FROM Rooms WHERE Id = @TargetRoomId) < @Accounts)
		BEGIN
			RAISERROR('Not enough beds in target room!', 16, 1)
			RETURN
		END	
	
	UPDATE Trips
	   SET RoomId = @TargetRoomId
	 WHERE Id = @TripId	
END
GO


EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

EXEC usp_SwitchRoom 10, 7

EXEC usp_SwitchRoom 10, 8
