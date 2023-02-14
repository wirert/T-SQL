CREATE DATABASE Service
GO
USE Service
GO

--01. DDL
CREATE TABLE Users
	(
		Id INT PRIMARY KEY IDENTITY,
		Username VARCHAR(30) UNIQUE NOT NULL,
		Password VARCHAR(50) NOT NULL,
		Name VARCHAR(50),
		Birthdate DATETIME,
		Age INT NOT NULL CHECK (Age BETWEEN 14 AND 110),
		Email VARCHAR(50) NOT NULL 
	)

CREATE TABLE Departments
	(
		Id INT PRIMARY KEY IDENTITY,
		Name VARCHAR(50) NOT NULL
	)

CREATE TABLE Employees
	(
		Id INT PRIMARY KEY IDENTITY,
		FirstName VARCHAR(25),
		LastName VARCHAR(25),
		Birthdate DATETIME,
		Age INT CHECK (Age BETWEEN 18 AND 110),
		DepartmentId INT NOT NULL FOREIGN KEY REFERENCES  Departments(Id)
	)

CREATE TABLE Categories
	(
		Id INT PRIMARY KEY IDENTITY,
		Name VARCHAR(50) NOT NULL,		
		DepartmentId INT NOT NULL FOREIGN KEY REFERENCES  Departments(Id)
	)

CREATE TABLE Status
	(
		Id INT PRIMARY KEY IDENTITY,
		Label VARCHAR(20) NOT NULL		
	)

CREATE TABLE Reports
	(
		Id INT PRIMARY KEY IDENTITY,
		CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories(Id),
		StatusId INT NOT NULL FOREIGN KEY REFERENCES Status(Id),
		OpenDate DATETIME NOT NULL,
		CloseDate DATETIME,
		Description VARCHAR(200) NOT NULL,
		UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
		EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
	)

--02. Insert 
INSERT INTO Employees
	 VALUES
		('Marlo', 'O''Malley', '1958-9-21', NULL, 1),
		('Niki', 'Stanaghan', '1969-11-26', NULL, 4),
		('Ayrton', 'Senna', '1960-03-21', NULL, 9),
		('Ronnie', 'Peterson', '1944-02-14', NULL, 9),
		('Giovanna', 'Amati', '1959-07-20', NULL, 5)

INSERT INTO Reports
	 VALUES
		( 1, 1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
		( 6, 3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
		( 14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2),
		( 4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

--03. Update
UPDATE Reports
   SET CloseDate = GETDATE()
 WHERE CloseDate IS NULL

 --04. Delete
 DELETE FROM Reports
	   WHERE StatusId = 4

--05. Unassigned Reports
   SELECT Description
		 ,FORMAT(OpenDate, 'dd-MM-yyyy') AS OpenDate
	 FROM Reports AS r
LEFT JOIN Employees AS e ON e.Id = r.EmployeeId
	WHERE e.Id IS NULL
 ORDER BY r.OpenDate, Description

 --06. Reports & Categories
 SELECT Description
	   ,c.Name AS CategoryName
	FROM Reports AS r
	JOIN Categories AS c ON c.Id = r.CategoryId
ORDER BY Description, CategoryName

--07. Most Reported Category
 SELECT 
 TOP 5 c.Name AS CategoryName
	   ,COUNT(*) AS ReportsNumber
	FROM Reports AS r
	JOIN Categories AS c ON c.Id = r.CategoryId
GROUP BY c.Name
ORDER BY ReportsNumber DESC, CategoryName

--08. Birthday Report
  SELECT Username
		,c.Name AS CategoryName
	FROM Reports AS r
	JOIN Users AS u ON u.Id = r.UserId
	JOIN Categories AS c ON c.Id = r.CategoryId
   WHERE FORMAT(u.Birthdate, 'MM-dd') = FORMAT(r.OpenDate, 'MM-dd')
ORDER BY Username, CategoryName

--09. User per Employee
   SELECT CONCAT(FirstName, ' ', LastName) AS FullName
		 ,COUNT(u.Id) AS UsersCount
	 FROM Employees AS e
LEFT JOIN Reports AS r ON e.Id = r.EmployeeId
LEFT JOIN Users AS u ON u.Id = r.UserId
 GROUP BY FirstName, LastName
 ORDER BY UsersCount DESC, FullName

--10. Full Info
   SELECT
		  CASE 
			WHEN FirstName IS NULL AND LastName IS NULL THEN 'None'
			ELSE CONCAT(FirstName, ' ', LastName) 
		  END
	   AS Employee
		 ,ISNULL(d.Name, 'None') AS Department
		 ,ISNULL(c.Name, 'None') AS Category
		 ,r.Description
		 ,FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate
		 ,s.Label AS Status
		 ,ISNULL(u.Name, 'None') AS [User]
	 FROM Reports AS r
LEFT JOIN Users AS u ON u.Id = r.UserId	
LEFT JOIN Employees AS e ON e.Id = r.EmployeeId
LEFT JOIN Departments AS d ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c ON c.Id = r.CategoryId
LEFT JOIN Status AS s ON s.Id = r.StatusId
 ORDER BY e.FirstName DESC, e.LastName DESC, Department, Category, Description, OpenDate, Status, [User]

GO

--11. Hours to Complete
CREATE FUNCTION udf_HoursToComplete
	(@StartDate DATETIME, 
	 @EndDate DATETIME)
RETURNS INT AS
BEGIN	
	IF (@StartDate IS NULL OR @EndDate IS NULL) RETURN 0
	RETURN DATEDIFF(HOUR, @StartDate, @EndDate)				
END
GO
SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports
GO

--12. Assign Employee
CREATE PROC usp_AssignEmployeeToReport 
	@EmployeeId INT, @ReportId INT
AS 
BEGIN
	DECLARE @employeeDepId INT = (SELECT DepartmentId FROM Employees WHERE Id = @EmployeeId)
	DECLARE @reportDepId INT = (SELECT DepartmentId 
								  FROM Reports AS r
								  JOIN Categories AS c ON c.Id = r.CategoryId
								  WHERE r.Id = @ReportId)

	IF (@employeeDepId = @reportDepId)
		BEGIN
			UPDATE Reports
			   SET EmployeeId = @EmployeeId
			 WHERE Id = @ReportId
		END
	ELSE
		BEGIN
			RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
		END
END

EXEC usp_AssignEmployeeToReport 17, 2
