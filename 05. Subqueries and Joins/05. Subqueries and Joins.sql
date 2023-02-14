-- task 01: Employee Address
SELECT TOP 5
	e.EmployeeID
	,e.JobTitle
	,a.AddressID
	,a.AddressText
FROM Employees AS e
JOIN Addresses AS a
ON e.AddressID = a.AddressID
ORDER BY a.AddressID

-- task 02: Addresses with Towns
SELECT TOP 50
	 e.FirstName
	,e.LastName
	,t.Name AS Town
	,a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY FirstName, 
		 LastName

-- task 03: Sales Employees 
SELECT
	e.EmployeeID
	,e.FirstName
	,e.LastName
	,d.Name AS DepartmentName
FROM Departments AS d 
JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID

-- task 04: Employee Departments
SELECT TOP 5
	e.EmployeeID
	,e.FirstName
	,e.Salary
	,d.Name AS DepartmentName
FROM Departments AS d
JOIN Employees AS e ON e.DepartmentID = d.DepartmentID
WHERE Salary > 15000
ORDER BY d.DepartmentID

-- task 05: Employees Without Projects
SELECT TOP 3
	 e.EmployeeID
	,e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep 
	   ON e.EmployeeID = ep.EmployeeID
WHERE ProjectID IS NULL
ORDER BY e.EmployeeID

-- task 06: Employees Hired After 
SELECT 
	e.FirstName
	,e.LastName
	,e.HireDate
	,d.[Name] AS [DeptName]
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE		[HireDate] > 1999-1-1 
		AND d.[Name] IN ('Finance', 'Sales')
ORDER BY HireDate

-- task 07: Employees With Project
SELECT  TOP 5
	 e.EmployeeID
	,e.FirstName
	,p.Name AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE	p.StartDate > 2002-8-13 
	AND p.EndDate IS NULL
ORDER BY e.EmployeeID

-- task 08: Employee 24
SELECT
	e.EmployeeID
	,e.FirstName
	,CASE 
		WHEN YEAR(p.StartDate) >= 2005 THEN NULL
		ELSE p.[Name]
	 END AS ProjectName
FROM(
	SELECT * FROM Employees
	WHERE EmployeeID = 24
	) AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON p.ProjectID = ep.ProjectID

-- task 09: Employee Manager
SELECT
	 e.EmployeeID
	,e.FirstName
	,e.ManagerID
	,m.FirstName AS ManagerName
FROM Employees AS m
JOIN Employees AS e 
     ON e.ManagerID = m.EmployeeID
WHERE e.ManagerID IN (3,7)
ORDER BY e.EmployeeID

-- task 10: Employees Summary
SELECT TOP 50
	 e.EmployeeID
	,CONCAT_WS(' ', e.FirstName, e.LastName) AS EmployeeName
	,CONCAT_WS(' ', m.FirstName, m.LastName) AS ManagerName
	,d.[Name] AS [DepartmentName]
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
JOIN Employees AS m ON e.ManagerID = m.EmployeeID
ORDER BY e.EmployeeID

-- task 11: Min Average Salary
SELECT
	MIN(Avr) AS MinAverageSalary
  FROM
 (
	SELECT 
		   AVG(Salary) AS Avr
	  FROM Employees
  GROUP BY DepartmentID
 ) AS AvgByDepart

-- task 12: Highest Peaks in Bulgaria
GO
USE [Geography]
GO

SELECT 
 	  c.CountryCode
 	 ,m.MountainRange
 	 ,p.PeakName
 	 ,p.Elevation
 FROM Countries AS c
 JOIN MountainsCountries AS mc 
   ON c.CountryCode = mc.CountryCode  	  
 JOIN Mountains AS m 
   ON m.Id = mc.MountainId
 JOIN Peaks AS p 
   ON p.MountainId = m.Id 
WHERE c.CountryName = 'Bulgaria'
      AND Elevation > 2835
ORDER BY Elevation DESC

-- task 13: Count Mountain Ranges
SELECT 
	 c.CountryCode
	,COUNT(m.MountainRange) AS MountainRanges
FROM Mountains AS m
JOIN MountainsCountries AS mc 
  ON m.Id = mc.MountainId
JOIN Countries AS c 
  ON c.CountryCode = mc.CountryCode 
WHERE c.CountryName IN ('Bulgaria', 'United States', 'Russia') 
GROUP BY c.CountryCode

-- task 14: Countries With or Without Rivers
SELECT TOP 5
	 c.CountryName
	,r.RiverName
FROM Countries AS c
JOIN Continents AS co ON c.ContinentCode = co.ContinentCode 
					 AND co.ContinentName = 'Africa'
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
ORDER BY c.CountryName

-- task 15: Continents and Currencies
SELECT
	 r.ContinentCode
	,r.CurrencyCode
	,r.CurrencyUssage
FROM (
	 SELECT
	 	 c.ContinentCode
	 	,c.CurrencyCode
	 	,COUNT(c.CurrencyCode) AS [CurrencyUssage]
	 	,DENSE_RANK()   OVER 
	 				(
	 			PARTITION BY c.ContinentCode 
	 				ORDER BY COUNT(c.CurrencyCode) DESC
	 				) AS CurrencyRank
	 FROM Countries AS c
	 GROUP BY ContinentCode, CurrencyCode
	 HAVING COUNT(c.CurrencyCode) > 1
	 ) 
   AS r
WHERE r.CurrencyRank = 1
ORDER BY r.ContinentCode

-- task 16: Countries Without any Mountains
   SELECT
		COUNT(c.CountryCode) AS [Count]
	 FROM Countries AS c
LEFT JOIN MountainsCountries AS mc 
	   ON c.CountryCode = mc.CountryCode
	WHERE mc.MountainId IS NULL

-- task 17: Highest Peak and Longest River by Country
SELECT TOP 5
		   c.CountryName
		  ,MAX(p.Elevation) AS HighestPeakElevation
		  ,MAX(r.[Length]) AS LongestRiverLength		
	  FROM Countries AS c
 LEFT JOIN CountriesRivers AS cr 
	    ON cr.CountryCode = c.CountryCode
 LEFT JOIN Rivers AS r 
		ON cr.RiverId = r.Id
 LEFT JOIN MountainsCountries AS mc 
		ON mc.CountryCode = c.CountryCode
 LEFT JOIN Mountains AS m 
		ON mc.MountainId = m.Id
 LEFT JOIN Peaks AS p 
		ON p.MountainId = m.Id
  GROUP BY c.CountryName
  ORDER BY HighestPeakElevation DESC,
 		   LongestRiverLength DESC,
 		   CountryName

-- task 18: Highest Peak Name and Elevation by Country
   SELECT TOP 5
   	    j.CountryName 
	 AS [Country]
   	   ,CASE 
			WHEN j.PeakName IS NULL THEN '(no highest peak)'
   	   		ELSE j.PeakName
   	    END 
	 AS [Highest Peak Name]
   	   ,CASE 
			WHEN j.Elevation IS NULL THEN 0
   	   		ELSE j.Elevation
   	    END 
		AS [Highest Peak Elevation]
   	   ,CASE 
			WHEN j.MountainRange IS NULL THEN '(no mountain)'
   	   		ELSE j.MountainRange
   	    END 
	 AS [Mountain]
    FROM
   	    (
   			SELECT 
   				   c.CountryName
   				  ,p.PeakName
   				  ,p.Elevation
   				  ,m.MountainRange
   				  ,DENSE_RANK() 
				   OVER (
   						PARTITION BY c.CountryName 
   						ORDER BY p.Elevation DESC
   						) 
				AS [PeaksRank]		  	
   			  FROM Countries AS c 
   		 LEFT JOIN MountainsCountries AS mc 
   				ON mc.CountryCode = c.CountryCode
   		 LEFT JOIN Mountains AS m 
   				ON mc.MountainId = m.Id
   		 LEFT JOIN Peaks AS p 
   				ON p.MountainId = m.Id
     	 ) 
	  AS j
   WHERE j.PeaksRank = 1
ORDER BY Country, 
		 [Highest Peak Name]