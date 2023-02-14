--01. Employees with Salary Above 35000
CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
BEGIN
	SELECT FirstName
		  ,LastName
	  FROM Employees
	WHERE Salary > 35000
END
GO
--02. Employees with Salary Above Number
CREATE PROC usp_GetEmployeesSalaryAboveNumber @number DECIMAL(18,4)
AS
BEGIN
	SELECT FirstName
		  ,LastName
	  FROM Employees
	 WHERE Salary >= @number
END

GO
--03. Town Names Starting With
CREATE PROC usp_GetTownsStartingWith @startWith VARCHAR(50)
AS
BEGIN
	SELECT [Name] AS Town
	  FROM Towns
	 WHERE [Name] LIKE @startWith +'%'
END
GO

--04. Employees from Town
CREATE PROC usp_GetEmployeesFromTown @townName VARCHAR(50)
AS
BEGIN
	SELECT e.FirstName
		  ,e.LastName
	  FROM Towns AS t
	  JOIN Addresses AS a ON t.TownID = a.TownID
	  JOIN Employees AS e ON a.AddressID = e.AddressID
	 WHERE t.Name = @townName
END
GO

--05. Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(10)
AS
BEGIN	
	IF (@salary < 30000) RETURN 'Low'
	ELSE IF (@salary > 50000) RETURN 'High'
	RETURN 'Average'
END
GO
--06. Employees by Salary Level
CREATE PROC usp_EmployeesBySalaryLevel @salaryLevel VARCHAR(10)
AS 
BEGIN 
	SELECT FirstName
		  ,LastName
	  FROM Employees
	 WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END
GO

--07. Define Function
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @index INT = 1;
	WHILE (@index <= LEN(@word))
		BEGIN		
			IF (CHARINDEX(SUBSTRING(@word, @index, 1), @setOfLetters) = 0) RETURN 0
			SET @index +=1
		END;
	RETURN 1;
END;
GO
--08. *Delete Employees and Departments
CREATE OR ALTER PROC usp_DeleteEmployeesFromDepartment 
		(@departmentId INT)
AS
BEGIN
	DELETE FROM EmployeesProjects
		  WHERE EmployeeID IN (SELECT EmployeeID 
							     FROM Employees 
							    WHERE DepartmentID = @departmentId)
	
	UPDATE Employees
	   SET ManagerID = NULL
	 WHERE ManagerID IN (SELECT EmployeeID 
						   FROM Employees 
						  WHERE DepartmentID = @departmentId)

	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT NULL

	UPDATE Departments
	   SET ManagerID = NULL
	 WHERE DepartmentID = @departmentId

	DELETE FROM Employees
		  WHERE DepartmentID = @departmentId

	DELETE FROM Departments
		  WHERE DepartmentID = @departmentId

	SELECT COUNT(*) 
	  FROM Employees
	 WHERE DepartmentID = @departmentId

END
GO
--------------------
CREATE DATABASE [Schema]
GO
USE [Schema]
GO

CREATE TABLE AccountHolders
(
	 Id INT PRIMARY KEY IDENTITY
	,FirstName VARCHAR(50) NOT NULL
	,LastName VARCHAR(50) NOT NULL
	,SSN VARCHAR(20) NOT NULL
);

CREATE TABLE Accounts
(
	Id INT PRIMARY KEY IDENTITY
	,AccountHolderId INT NOT NULL FOREIGN KEY REFERENCES AccountHolders(Id)
	,Balance DECIMAL(18, 4) NOT NULL
);
GO
--09. Find Full Name

CREATE PROC usp_GetHoldersFullName 
AS
BEGIN
	SELECT CONCAT_WS(' ', FirstName, LastName) 
	    AS [Full Name] 
	 FROM AccountHolders
END
GO
--10. People with Balance Higher Than
CREATE PROC usp_GetHoldersWithBalanceHigherThan @number DECIMAL(18,4)
AS
BEGIN
	SELECT h.FirstName
		  ,h.LastName
	  FROM AccountHolders AS h
	  JOIN Accounts AS a ON a.AccountHolderId = h.Id
  GROUP BY h.Id, h.FirstName, h.LastName
    HAVING SUM(a.Balance) > @number
  ORDER BY FirstName, LastName
END;
GO

--11. Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(10,4), @yearlyInterestRate FLOAT, @numberYears INT)
RETURNS DECIMAL(10,4) AS
BEGIN
	RETURN @sum * POWER(1 + @yearlyInterestRate, @numberYears)
END
GO

--12. Calculating Interest
CREATE PROC usp_CalculateFutureValueForAccount 
		@accountId INT, @interstRate FLOAT
AS
BEGIN
	SELECT a.Id AS [Account Id]
		  ,h.FirstName 
		AS [First Name]
		  ,h.LastName 
		AS [Last Name]
		  ,a.Balance 
		AS [Current Balance]
		  ,dbo.ufn_CalculateFutureValue(a.Balance, @interstRate, 5) 
		AS [Balance in 5 years]
	  FROM AccountHolders AS h
	  JOIN Accounts AS a ON a.AccountHolderId = h.Id
	 WHERE a.Id = @accountId  
END;
GO
--13. *Cash in User Games Odd Rows
USE Diablo
GO

CREATE FUNCTION ufn_CashInUsersGames (@gameName NVARCHAR(50))
RETURNS TABLE AS
RETURN(	
	  SELECT SUM(Cash) 
		  AS SumCash
		FROM(
			  SELECT ug.Cash
					,ROW_NUMBER() OVER (PARTITION BY g.Name 
									    ORDER BY ug.Cash DESC) 
				  AS [RowNumber]
				FROM UsersGames AS ug
				JOIN Games AS g ON g.Id = ug.GameId
			   WHERE g.Name = @gameName
			 ) 
		  AS RowNumberSubquery
	   WHERE RowNumber % 2 <> 0	
	   );