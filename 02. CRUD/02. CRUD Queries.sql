-- task 2
SELECT * FROM Departments

-- task 3
SELECT [Name] FROM Departments

-- task 4
SELECT * FROM Employees

SELECT FirstName, LastName, Salary FROM Employees

-- task 5
SELECT FirstName, MiddleName, LastName FROM Employees

-- task 6: email from name
SELECT  CONCAT(FirstName,'.',LastName, '@', 'softuni.bg') as [Full Email Address]
	  FROM Employees

-- task 7 : Find All Different Employee’s Salaries
SELECT DISTINCT Salary FROM Employees

-- task 8: Find All Information About Employees
SELECT * FROM Employees
		WHERE JobTitle = 'Sales Representative'

-- task 9: Find Names of All Employees by Salary in Range
SELECT FirstName, LastName, JobTitle 
  FROM Employees
 WHERE Salary BETWEEN 20000 AND 30000

-- task 10: Find Names of All Employees
SELECT CONCAT(FirstName,' ',MiddleName,' ', LastName) as [Full Name] 
  FROM Employees
 WHERE Salary IN (25000, 14000, 12500, 23600)

-- task 11: Find All Employees Without Manager
SELECT FirstName, LastName 
  FROM Employees
 WHERE ManagerID IS NULL

-- task 12: Find All Employees with Salary More Than
SELECT FirstName, LastName, Salary 
  FROM Employees
 WHERE Salary > 50000
 ORDER BY Salary DESC

-- task 13: Find 5 Best Paid Employees
SELECT TOP(5) FirstName, LastName 
	  FROM Employees
	 ORDER BY Salary DESC

-- task 14: Find All Employees Except Marketing
SELECT FirstName, LastName 
  FROM Employees
 WHERE DepartmentID <> 4

-- task 15: Sort Employees Table
SELECT * FROM Employees
		ORDER BY Salary DESC,
				   FirstName,
			   LastName DESC,
				  MiddleName

-- task 16: Create View Employees with Salaries
GO
CREATE VIEW V_EmployeesSalaries AS
	 SELECT FirstName, LastName, Salary 
	   FROM Employees
GO

-- task 17 View with job title
GO
CREATE VIEW V_EmployeeNameJobTitle AS 
	 SELECT 
	 	   CONCAT(FirstName,' ',MiddleName,' ', LastName) AS [Full Name]
	 	  ,JobTitle AS [Job Title] 
	   FROM Employees
GO
-- task 18: Distinct Job Titles
SELECT DISTINCT JobTitle FROM Employees

-- task 19: Find First 10 Started Projects
SELECT TOP(10) * 
	  FROM Projects
	 ORDER BY StartDate, [Name]

-- task 20: Last 7 Hired Employees
SELECT TOP(7) FirstName, LastName, HireDate 
	  FROM Employees
	 ORDER BY HireDate DESC

-- task 21: Increase Salaries
SELECT * FROM Employees

UPDATE Employees
   SET Salary *= 1.12
 WHERE DepartmentID IN
					  (
					  SELECT DepartmentID 
						FROM Departments
					   WHERE [Name] IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services')
					   )

SELECT Salary FROM Employees
GO

-- task 22. All Mountain Peaks
USE [Geography]
GO

SELECT PeakName FROM Peaks
	ORDER BY PeakName

-- task 23: Biggest Countries by Population
SELECT TOP(30) CountryName, [Population] 
	  FROM Countries
	 WHERE ContinentCode = 'EU'
	 ORDER BY [Population] DESC
	
-- task 24: Countries and Currency (Euro / Not Euro) 
SELECT * FROM Currencies

SELECT  CountryName,
		CountryCode,	    
        CASE CurrencyCode
			WHEN 'EUR' THEN 'Euro'
			ELSE 'Not Euro'
	    END
    AS Currency 
  FROM Countries
 ORDER BY CountryName

 -- task 25: All Diablo Characters
 USE Diablo

 SELECT [Name] 
   FROM Characters
  ORDER BY [Name]
