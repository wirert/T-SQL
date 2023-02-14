-- task 1: Find Names of All Employees by First Name
USE SoftUni
GO

SELECT
	 [FirstName]
	,[LastName]
FROM Employees
WHERE [FirstName] LIKE 'Sa%'

-- task 02: Find Names of All Employees by Last Name
SELECT
	 FirstName
	,LastName
FROM Employees
WHERE [LastName] LIKE '%ei%'

-- task 03: Find First Names of All Employees
SELECT  
	[FirstName]
FROM Employees
WHERE [DepartmentID] IN (3,10) AND (DATEPART(YEAR, HireDate) BETWEEN 1995 AND 2005)

-- task 04: Find All Employees Except Engineers
SELECT 
	 FirstName
	,LastName
FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'

-- task 05: Find Towns with Name Length
SELECT [Name] 
FROM Towns
WHERE LEN([Name]) IN (5,6)
ORDER BY [Name]

-- task 06: Find Towns Starting With
SELECT * FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]

-- task 07: Find Towns Not Starting With
SELECT * FROM Towns
WHERE [Name] LIKE '[^RBD]%'
ORDER BY [Name]

-- task 08: Create View Employees Hired After 2000 Year
GO
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT 
	[FirstName], 
	[LastName] 
FROM [Employees]
WHERE YEAR(HireDate) > 2000
GO

-- task 09: Length of Last Name
SELECT 
	FirstName,
	LastName
FROM Employees
WHERE LEN(LastName) = 5

--task 10: Rank Employees by Salary
SELECT 
	EmployeeID,
	FirstName,
	LastName,
	Salary,
	DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
FROM Employees
WHERE (Salary BETWEEN 10000 AND 50000) AND [Rank] = 2
ORDER BY Salary DESC

-- task 11: Find All Employees with Rank 2
SELECT * FROM
(
	SELECT 
		EmployeeID,
		FirstName,
		LastName,
		Salary,
		DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS [Rank]
	FROM Employees
) 
AS E
WHERE (Salary BETWEEN 10000 AND 50000) AND [Rank] = 2
ORDER BY Salary DESC

-- task 12: Countries Holding 'A' 3 or More Times
USE [Geography]
GO

SELECT 
	CountryName,
	IsoCode
FROM Countries
WHERE LOWER(CountryName) LIKE '%a%a%a%'
ORDER BY IsoCode

-- task 13: Mix of Peak and River Names
SELECT 
	p.[PeakName],
	r.[RiverName],
	LOWER(CONCAT(p.[PeakName], SUBSTRING(r.[RiverName], 2, (LEN(r.[RiverName]) - 1)))) AS [Mix]
FROM [Peaks] AS p,
	 [Rivers] AS r 
WHERE RIGHT(p.[PeakName], 1) = LOWER(LEFT(r.[RiverName], 1))
ORDER BY [Mix]

----- var2
SELECT 
	p.PeakName,
	r.RiverName,
	LOWER(CONCAT(p.PeakName, SUBSTRING(r.RiverName, 2, (LEN(r.RiverName) - 1)))) AS [Mix]
FROM Peaks AS p
JOIN Rivers AS r 
ON RIGHT(p.PeakName, 1) = LOWER(LEFT(r.RiverName, 1))
ORDER BY [Mix]

--task 14: Games From 2011 and 2012 Year
GO
USE Diablo
GO
 
 SELECT TOP(50) 
	[Name],
	FORMAT([Start], 'yyyy-MM-dd') AS [Start]
 FROM Games
 WHERE YEAR([Start]) IN (2011, 2012)
 ORDER BY [Start], 
		  [Name]

-- task 15: User Email Providers
SELECT  
	[Username],
	SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email) - CHARINDEX('@', Email)) 
 AS [Email Provider]
FROM [Users]
ORDER BY [Email Provider], 
		 [Username]

-- task 16: Get Users with IP Address Like Pattern
SELECT
	Username,
	IpAddress AS [IP Address]
FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

-- task 17: Show All Games with Duration & Part of the Day
SELECT 
	[Name],
	CASE
		WHEN DATEPART(HOUR, [Start]) >= 0 AND DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start]) >= 12 AND DATEPART(HOUR, [Start]) < 18 THEN 'Afternoon'
		ELSE 'Evening'
	END AS [Part of the Day],
	CASE
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration <= 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
		ELSE 'Extra Long'
	END AS Duration
FROM Games 
ORDER BY [Name],
		 [Duration],
		 [Part of the Day]

-- task 18: Orders Table
GO
USE Orders
GO

SELECT 
	ProductName,
	OrderDate,
	DATEADD(DAY, 3, OrderDate) AS [Pay Due],
	DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders
