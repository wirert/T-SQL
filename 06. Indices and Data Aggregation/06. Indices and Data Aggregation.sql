--01. Records’ Count
SELECT 
	   COUNT(*) AS Count
  FROM WizzardDeposits

--02. Longest Magic Wand
SELECT MAX(MagicWandSize) 
	AS LongestMagicWand
  FROM WizzardDeposits

--03. Longest Magic Wand per Deposit Groups
  SELECT DepositGroup,
		 MAX(MagicWandSize)
	  AS LongestMagicWand
    FROM WizzardDeposits
GROUP BY DepositGroup

--04. Smallest Deposit Group per Magic Wand Size
  SELECT TOP 2
			 DepositGroup
		FROM(
			  SELECT DepositGroup, 
					 AVG(MagicWandSize) AS AverageWandSize
			    FROM WizzardDeposits
			GROUP BY DepositGroup
			)
		  AS AverageWandSizeSubquery
	ORDER BY AverageWandSize

--05. Deposits Sum
  SELECT DepositGroup,
		 SUM(DepositAmount) 
	  AS TotalSum
    FROM WizzardDeposits
GROUP BY DepositGroup

--06. Deposits Sum for Ollivander Family
  SELECT DepositGroup,
		 SUM(DepositAmount) 
	  AS TotalSum 
	FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
  HAVING MagicWandCreator = 'Ollivander family'

--07. Deposits Filter
  SELECT DepositGroup,
		 SUM(DepositAmount) 
	  AS TotalSum 
	FROM WizzardDeposits
   WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
  HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--08. Deposit Charge
  SELECT DepositGroup,
		 MagicWandCreator,
		 MIN(DepositCharge) 
	  AS MinDepositCharge 
	FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

--09. Age Groups
  SELECT AgeGroup,
		 COUNT(*)
	  AS WizardCount
    FROM(
		  SELECT 
				 CASE 
					WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
					WHEN Age <= 20 THEN '[11-20]'
					WHEN Age <= 30 THEN '[21-30]'
					WHEN Age <= 40 THEN '[31-40]'
					WHEN Age <= 50 THEN '[41-50]'
					WHEN Age <= 60 THEN '[51-60]'
					ELSE '[61+]'
				 END
			  AS AgeGroup
		    FROM WizzardDeposits
		)
	  AS AgeGroupsSubquery
GROUP BY AgeGroup

--10. First Letter
  SELECT FirstLetter
	FROM(
		  SELECT LEFT(FirstName, 1)
			  AS FirstLetter
			FROM WizzardDeposits
		   WHERE DepositGroup = 'Troll Chest'
		)
	  AS Subquery
GROUP BY FirstLetter

--11. Average Interest
  SELECT DepositGroup
		,IsDepositExpired
		,AVG(DepositInterest)
	  AS AverageInterest
	FROM WizzardDeposits
   WHERE DepositStartDate > '1985-01-01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

--12. *Rich Wizard, Poor Wizard
  SELECT 
		 SUM([Difference])
	  AS SumDifference
	FROM(
	  SELECT h.FirstName AS [Host Name]
			,h.DepositAmount AS [Host Deposit]
			,g.FirstName AS [Guest Name]
			,g.DepositAmount AS [Guest Deposit]
			,h.DepositAmount - g.DepositAmount
		  AS [Difference]
		FROM WizzardDeposits AS h
		JOIN WizzardDeposits AS g
		  ON g.Id = h.Id + 1
	    )
	  AS Subquery
    
--13. Departments Total Salaries
GO
USE SoftUni
GO

  SELECT DepartmentID
		,SUM(Salary) 
	  AS TotalSalary
	FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--14. Employees Minimum Salaries
  SELECT DepartmentID
		,MIN(Salary)
	  AS MinimumSalary
	FROM Employees
   WHERE HireDate > '01/01/2000'
GROUP BY DepartmentID
  HAVING DepartmentID IN (2,5,7)

--15. Employees Average Salaries

SELECT * 
  INTO EmployeesSalaryFiltered
  FROM Employees
 WHERE Salary > 30000

DELETE FROM EmployeesSalaryFiltered
	  WHERE ManagerID = 42

UPDATE EmployeesSalaryFiltered
   SET Salary += 5000
 WHERE DepartmentID = 1

  SELECT DepartmentID
		,AVG(Salary)
	  AS AverageSalary 
	FROM EmployeesSalaryFiltered
GROUP BY DepartmentID

--16. Employees Maximum Salaries
  SELECT DepartmentID
		,MAX(Salary) 
	  AS MaxSalary
	FROM Employees
GROUP BY DepartmentID
  HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17. Employees Count Salaries
SELECT COUNT(*) 
    AS [Count]
  FROM Employees
 WHERE ManagerID IS NULL

--18. *3rd Highest Salary
  SELECT 
DISTINCT DepartmentID
		,Salary 
	  AS ThirdHighestSalary  
	FROM(
		  SELECT DepartmentID
				,Salary
				,DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC)
			  AS SalaryRank
			FROM Employees
		)
	  AS RankedSubquery
   WHERE SalaryRank = 3

--19. **Salary Challenge
  SELECT TOP 10
		 FirstName
		,LastName
		,e.DepartmentID
	FROM Employees 
	  AS e
	JOIN (
		  SELECT DepartmentID
				,AVG(Salary) 
			  AS AverageSalary
			FROM Employees
		GROUP BY DepartmentID
		  ) 
	   AS a ON e.DepartmentID = a.DepartmentID
	WHERE Salary > AverageSalary
 ORDER BY DepartmentID