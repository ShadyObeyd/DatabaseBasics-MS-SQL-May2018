USE Gringotts
GO

--01.Records’ Count
SELECT COUNT(*) 
	AS [Count] 
FROM WizzardDeposits
GO

--02.Longest Magic Wand
SELECT MAX(MagicWandSize) 
	AS LongestMagicWand
FROM WizzardDeposits
GO

--03.Longest Magic Wand per Deposit Groups
SELECT DepositGroup, MAX(MagicWandSize) 
	AS LongestMagicWand
FROM WizzardDeposits
GROUP BY DepositGroup
GO

--04.Smallest Deposit Group per Magic Wand Size
SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)
GO

--05.Deposits Sum
SELECT DepositGroup, SUM(DepositAmount) 
	AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup
GO

--06.Deposits Sum for Ollivander Family
SELECT DepositGroup, SUM(DepositAmount) 
	AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
GO

--07.Deposits Filter
SELECT DepositGroup, SUM(DepositAmount) 
	AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC
GO

--08.Deposit Charge
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge)
	AS MinDepositCharge
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator ASC, DepositGroup ASC
GO

--09.Age Groups
SELECT 
	AgeGroup =
	CASE
		WHEN Age BETWEEN 0 AND 10 
			THEN '[0-10]'
		WHEN Age BETWEEN 11 AND 20
			THEN '[11-20]'
		WHEN Age BETWEEN 21 AND 30
			THEN '[21-30]'
		WHEN Age BETWEEN 31 AND 40
			THEN '[31-40]'
		WHEN Age BETWEEN 41 AND 50
			THEN '[41-50]'
		WHEN Age BETWEEN 51 AND 60
			THEN '[51-60]'
		WHEN Age >= 61
			THEN '[61+]'
	END,
	COUNT(*)
FROM WizzardDeposits
GROUP BY CASE
			WHEN Age BETWEEN 0 AND 10 
				THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20
				THEN '[11-20]'
			WHEN Age BETWEEN 21 AND 30
				THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40
				THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50
				THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60
				THEN '[51-60]'
			WHEN Age >= 61
				THEN '[61+]'
		 END
GO

--10.First Letter
SELECT LEFT(FirstName, 1)
	AS FirstLetter
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)
GO

--11.Average Interest
SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest)
	AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY IsDepositExpired, DepositGroup
ORDER BY DepositGroup DESC, IsDepositExpired ASC
GO

--12.Rich Wizard, Poor Wizard
SELECT SUM([Difference]) AS SumDifference
FROM (
	SELECT FirstName AS [Host Wizzard], DepositAmount AS [Host Wizzard Deposit],
		LEAD(FirstName) OVER (ORDER BY Id) AS [GuestWizzard], 
		LEAD(DepositAmount) OVER (ORDER BY Id) AS [Guest Wizzard Deposit],
		[Difference] = DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id)
	FROM WizzardDeposits) AS Differences
GO

--13.Departments Total Salaries
USE SoftUni
GO

SELECT DepartmentID, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
GO

--14.Employees Minimum Salaries
SELECT DepartmentID, MIN(Salary) AS MinimumSalary
FROM
Employees
WHERE HireDate > '01/01/2000'
GROUP BY DepartmentID
HAVING DepartmentID IN (2, 5, 7)
GO

--15.Employees Average Salaries
SELECT * INTO EmployeesNew
FROM Employees
WHERE Salary > 30000


DELETE FROM EmployeesNew
WHERE ManagerID = 42


UPDATE EmployeesNew
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS AverageSalary
FROM EmployeesNew
GROUP BY DepartmentID
GO

--16.Employees Maximum Salaries
SELECT DepartmentID, MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17.Employees Count Salaries
SELECT COUNT(*)
FROM Employees
WHERE ManagerID IS NULL
GO

--18.3rd Highest Salary
SELECT DISTINCT DepartmentID, Salary
FROM (
SELECT DepartmentID, Salary,
	DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS RankedSalary
FROM Employees) AS Empl
WHERE RankedSalary = 3
GO

--19.Salary Challenge
SELECT TOP (10) FirstName, LastName, DepartmentID
FROM Employees AS e
WHERE Salary > (
	SELECT AVG(Salary)
	FROM Employees
	WHERE DepartmentID = e.DepartmentID
)
ORDER BY DepartmentID
GO
