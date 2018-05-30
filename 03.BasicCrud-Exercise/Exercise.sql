USE SoftUni
GO

--02.Find All Information About Departments
SELECT * 
FROM Departments
GO

--03.Find all Department Names
SELECT [Name] 
FROM Departments
GO

--04.Find Salary of Each Employee
SELECT FirstName, LastName, Salary 
FROM Employees
GO

--05.Find Full Name of Each Employee
SELECT FirstName, MiddleName, LastName 
 FROM Employees
GO

--06.Find Email Address of Each Employee
SELECT [Full Email Address] = 
	FirstName + '.' + LastName + '@softuni.bg'
FROM Employees
GO

--07.Find All Different Employee’s Salaries
SELECT DISTINCT Salary
FROM Employees
GO

--08.Find all Information About Employees
SELECT *
FROM Employees
WHERE JobTitle = 'Sales Representative'
GO

--09.Find Names of All Employees by Salary in Range
SELECT FirstName, LastName, JobTitle
FROM Employees
WHERE Salary 
BETWEEN 20000 
AND 30000
GO

--10.Find Names of All Employees 
SELECT [Full Name] =
	FirstName + ' ' + MiddleName + ' ' + LastName
FROM Employees
WHERE Salary 
IN (25000, 14000, 12500, 23600)
GO

--11.Find All Employees Without Manager
SELECT FirstName, LastName
FROM Employees
WHERE ManagerID 
IS NULL
GO

--12.Find All Employees with Salary More Than 50000
SELECT FirstName, LastName, Salary
FROM Employees
WHERE Salary > 50000
ORDER BY Salary DESC
GO

--13.Find 5 Best Paid Employees
SELECT TOP (5) FirstName, LastName
FROM Employees
ORDER BY Salary DESC
GO

--14.Find All Employees Except Marketing
SELECT FirstName, LastName
FROM Employees
WHERE NOT DepartmentID = 4
GO

--15.Sort Employees Table
SELECT *
FROM Employees
ORDER BY Salary DESC, 
		 FirstName ASC, 
		 LastName DESC,
		 MiddleName ASC
GO

--16.Create View Employees with Salaries
CREATE VIEW v_EmployeesSalaries AS
SELECT FirstName, LastName, Salary
FROM Employees
GO

--17.Create View Employees with Job Titles
CREATE VIEW v_EmployeeNameJobTitle AS
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS [Full Name],
JobTitle
FROM Employees
GO

--18.Distinct Job Titles
SELECT DISTINCT JobTitle
FROM Employees
GO

--19.Find First 10 Started Projects
SELECT TOP (10) *
FROM Projects
ORDER BY StartDate, [Name]
GO

--20.Last 7 Hired Employees
SELECT TOP (7) FirstName, LastName, HireDate
FROM Employees
ORDER BY HireDate DESC
GO

--21.Increase Salaries
UPDATE Employees
SET Salary = Salary * 1.12
WHERE DepartmentID IN (1, 2, 4, 11)
GO

SELECT Salary FROM Employees
GO

UPDATE Employees
SET Salary = Salary / 1.12
WHERE DepartmentID IN (1, 2, 4, 11)
GO

--22.All Mountain Peaks
USE Geography
GO

SELECT PeakName
FROM Peaks
ORDER BY PeakName
GO

--23.Biggest Countries by Population
SELECT TOP (30) CountryName, [Population]
FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY [Population] DESC, CountryName ASC
GO

--24.*Countries and Currency (Euro / Not Euro)
SELECT CountryName, CountryCode, Currency =
	CASE CurrencyCode
		WHEN 'EUR' 
		THEN 'Euro'
		ELSE 'Not Euro'
	END
FROM Countries
ORDER BY CountryName ASC

--25.All Diablo Characters
USE Diablo
GO

SELECT [Name]
FROM Characters
ORDER BY [Name]
GO