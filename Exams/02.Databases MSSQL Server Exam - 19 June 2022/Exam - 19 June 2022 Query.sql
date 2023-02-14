CREATE DATABASE Zoo
GO
USE Zoo
GO

--01. DDL
CREATE TABLE Owners
	(
		 Id INT PRIMARY KEY IDENTITY
		,Name VARCHAR(50) NOT NULL
		,PhoneNumber VARCHAR(15) NOT NULL
		,Address VARCHAR(50)
	);

CREATE TABLE AnimalTypes
	(
		 Id INT PRIMARY KEY IDENTITY
		,AnimalType VARCHAR(30) NOT NULL
	);

CREATE TABLE Cages
	(
		  Id INT PRIMARY KEY IDENTITY
		 ,AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
	);

CREATE TABLE Animals
	(
		 Id INT PRIMARY KEY IDENTITY
		,Name VARCHAR(30) NOT NULL
		,BirthDate DATE NOT NULL
		,OwnerId INT FOREIGN KEY REFERENCES Owners(Id)
		,AnimalTypeId INT NOT NULL FOREIGN KEY REFERENCES AnimalTypes(Id)
	);

CREATE TABLE AnimalsCages
	(
		 CageId INT FOREIGN KEY REFERENCES Cages(Id)
		,AnimalId INT FOREIGN KEY REFERENCES Animals(Id)
		,PRIMARY KEY (CageId, AnimalId)
	);

CREATE TABLE VolunteersDepartments
	(
		 Id INT PRIMARY KEY IDENTITY
		,DepartmentName VARCHAR(30) NOT NULL
	);

CREATE TABLE Volunteers
	(
		 Id INT PRIMARY KEY IDENTITY
		,Name VARCHAR(50) NOT NULL
		,PhoneNumber VARCHAR(15) NOT NULL
		,Address VARCHAR(50)
		,AnimalId INT FOREIGN KEY REFERENCES Animals(Id)
		,DepartmentId INT NOT NULL FOREIGN KEY REFERENCES VolunteersDepartments(Id)
	);

--02. Insert
INSERT INTO Volunteers
	 VALUES
		('Anita Kostova','0896365412','Sofia, 5 Rosa str.',15,1),
		('Dimitur Stoev','0877564223',null,42,4),
		('Kalina Evtimova','0896321112','Silistra, 21 Breza str.',9,7),
		('Stoyan Tomov','0898564100','Montana, 1 Bor str.',18,8),
		('Boryana Mileva','0888112233',NULL,31,5);

INSERT INTO Animals
	VALUES
		('Giraffe','2018-09-21',21,1),
		('Harpy Eagle','2015-04-17',15,3),
		('Hamadryas Baboon','2017-11-02',NULL,1),
		('Tuatara','2021-06-30',2,4);

--03. Update
DECLARE @ownerId INT = (SELECT Id FROM Owners WHERE Name = 'Kaloqn Stoqnov')

UPDATE Animals
   SET OwnerId = @ownerId
 WHERE OwnerId IS NULL

--04. Delete
 DECLARE @departmentId INT = (SELECT Id 
								FROM VolunteersDepartments
							   WHERE DepartmentName = 'Education program assistant')

ALTER TABLE Volunteers
ALTER COLUMN DepartmentId INT

UPDATE Volunteers
   SET DepartmentId = NULL
 WHERE DepartmentId = @departmentId

DELETE FROM VolunteersDepartments
	  WHERE Id = @departmentId

--05. Volunteers
  SELECT Name,
  	     PhoneNumber,
  	     Address,
  	     AnimalId,
  	     DepartmentId
    FROM Volunteers
ORDER BY Name, AnimalId, DepartmentId

--06. Animals data
  SELECT a.Name,
		 t.AnimalType,
		 FORMAT(a.BirthDate, 'dd.MM.yyyy') 
	  AS BirthDate
	FROM Animals AS a
	JOIN AnimalTypes AS t ON a.AnimalTypeId = t.Id
ORDER BY Name

--07. Owners and Their Animals
  SELECT 
   TOP 5 o.Name 
	  AS Owner
		,COUNT(a.Id) 
	  AS CountOfAnimals
	FROM Owners AS o
	JOIN Animals AS a ON a.OwnerId = o.Id
GROUP BY o.Name
ORDER BY CountOfAnimals DESC, Owner

--08. Owners, Animals and Cages
  SELECT CONCAT(o.Name,'-', a.Name)
	  AS OwnersAnimals
	    ,o.PhoneNumber
		,ac.CageId
	FROM Owners AS o
	JOIN Animals AS a ON a.OwnerId = o.Id
	JOIN AnimalsCages AS ac ON ac.AnimalId = a.Id
	JOIN AnimalTypes AS t ON t.Id = a.AnimalTypeId
   WHERE t.AnimalType = 'mammals'
ORDER BY o.Name, a.Name DESC

--09. Volunteers in Sofia

  SELECT v.Name
		,v.PhoneNumber
		,LTRIM(SUBSTRING(LTRIM(v.Address), CHARINDEX(',', v.Address) + 1, LEN(v.Address)))
	  AS Address
	FROM Volunteers AS v
	JOIN VolunteersDepartments AS vd ON vd.Id = v.DepartmentId
   WHERE vd.DepartmentName = 'Education program assistant' 
		 AND v.Address LIKE '%Sofia%'
ORDER BY Name

--10. Animals for Adoption
  SELECT a.Name
		,YEAR(a.BirthDate) AS BirthYear
		,t.AnimalType
	FROM Animals AS a
	JOIN AnimalTypes AS t ON t.Id = a.AnimalTypeId
   WHERE a.OwnerId IS NULL 
		 AND a.BirthDate >= '01/01/2018'
         AND t.AnimalType <> 'Birds'
ORDER BY a.Name
GO

--11. All Volunteers in a Department
CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
RETURNS INT AS
BEGIN
	RETURN 
		(
			SELECT COUNT(*) 
			  FROM VolunteersDepartments AS vd
			  JOIN Volunteers AS v ON vd.Id = v.DepartmentId
			 WHERE vd.DepartmentName = @VolunteersDepartment
		)
END

GO
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')
GO

--12. Animals with Owner or Not
CREATE PROC usp_AnimalsWithOwnersOrNot 
			@AnimalName VARCHAR(30)
AS
BEGIN
	SELECT a.Name
		  ,ISNULL(o.Name, 'For adoption')
		AS OwnersName
	  FROM Animals AS a
 LEFT JOIN Owners AS o ON a.OwnerId = o.Id
	 WHERE a.Name = @AnimalName
END


