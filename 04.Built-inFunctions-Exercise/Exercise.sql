USE SoftUni
GO

--01.Find Names of All Employees by First Name
SELECT FirstName, LastName
FROM Employees
WHERE FirstName LIKE 'Sa%'
GO

--02.Find Names of All employees by Last Name 
SELECT FirstName, LastName
FROM Employees
WHERE LastName LIKE '%ei%'
GO

--03.Find First Names of All Employees
SELECT FirstName
FROM Employees
WHERE DepartmentID IN (3, 10)
AND HireDate BETWEEN '01-01-1995' AND '12-31-2005'
GO

--04.Find All Employees Except Engineers
SELECT FirstName, LastName
FROM Employees
WHERE NOT JobTitle LIKE '%engineer%'
GO

--05.Find Towns with Name Length
SELECT [Name]
FROM Towns
WHERE LEN([Name]) BETWEEN 5 AND 6
ORDER BY [Name] ASC
GO

--06.Find Towns Starting With
SELECT *
FROM Towns
WHERE [Name] LIKE '[M, K, B, E]%'
ORDER BY [Name] ASC
GO

--07.Find Towns Not Starting With
SELECT *
FROM Towns
WHERE NOT [Name] LIKE '[R, B, D]%'
ORDER BY [Name] ASC
GO

--08.Create View Employees Hired After 2000 Year
CREATE VIEW v_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName
FROM Employees
WHERE HireDate > '12-31-2000'
GO

SELECT *
FROM v_EmployeesHiredAfter2000
GO

--09.Length of Last Name
SELECT FirstName, LastName
FROM Employees
WHERE LEN(LastName) = 5
GO

--10.Countries Holding ‘A’ 3 or More Times
USE Geography
GO

SELECT CountryName, IsoCode
FROM Countries
WHERE CountryName LIKE '%a%a%a%'
ORDER BY IsoCode ASC
GO

--11.Mix of Peak and River Names
SELECT PeakName, RiverName, 
	Mix = 
	 LOWER(PeakName + 
	 SUBSTRING(RiverName, 2, 
		 LEN(RiverName)))
FROM Peaks
CROSS JOIN Rivers
WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1)
ORDER BY Mix ASC
GO

--12.Games from 2011 and 2012 year
USE Diablo
GO

SELECT TOP (50) [Name], [Start] = 
	FORMAT(Start, 'yyyy-MM-dd')
FROM Games
WHERE [Start] BETWEEN '01-01-2011' AND '12-31-2012'
ORDER BY [Start] ASC, [Name] ASC
GO

--13.User Email Providers
SELECT Username, [Email Provider] =
	SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email))
FROM Users
ORDER BY [Email Provider] ASC, Username ASC 
GO

--14.Get Users with IPAdress Like Pattern
SELECT Username, IpAddress
FROM Users
WHERE IpAddress LIKE '___.1_%._%.___'
ORDER BY Username ASC
GO

--15.Show All Games with Duration and Part of the Day
SELECT Game = [Name], 
		[Part of the Day] =
			CASE
			 WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 
			  THEN 'Morning'
			 WHEN DATEPART(HOUR, [Start]) BETWEEN 12 AND 17
			  THEN 'Afternoon'
			 WHEN DATEPART(HOUR, [Start]) BETWEEN 18 AND 23
			  THEN 'Evening'
			END,
		Duration =
			CASE
			 WHEN Duration <= 3 
			  THEN 'Extra Short'
			 WHEN Duration BETWEEN 4 AND 6
			  THEN 'Short'
			 WHEN Duration > 6
			  THEN 'Long'
			 WHEN Duration IS NULL
			  THEN 'Extra Long'
			END
FROM Games
ORDER BY Game ASC,
         Duration ASC,
		 [Part of the Day] ASC
GO

--16.Orders Table
USE Orders
GO

SELECT
	   ProductName, 
	   OrderDate,
	   [Pay Due] =
	     DATEADD(DAY, 3, OrderDate),
	   [Deliver Due] =
	     DATEADD(MONTH, 1, OrderDate)
FROM Orders
GO

--17.People Table
CREATE TABLE People (
	Id INT NOT NULL IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
	Birthdate DATETIME2 NOT NULL

	CONSTRAINT PK_PeopleId
	PRIMARY KEY (Id)
)
GO

INSERT INTO People ([Name], Birthdate)
VALUES
('Victor', CONVERT(DATETIME2, '07-12-2000', 103)),
('Steven', CONVERT(DATETIME2, '10-09-1992', 103)),
('Stephen', CONVERT(DATETIME2, '19-09-1910', 103)),
('John', CONVERT(DATETIME2, '06-01-2010', 103))
GO

SELECT 
 [Name], 
 [Age in Years] = 
	DATEDIFF(YEAR, Birthdate, GETDATE()),
 [Age int Months] =
	DATEDIFF(MONTH, Birthdate, GETDATE()),
 [Age in Days] = 
	DATEDIFF(DAY, Birthdate, GETDATE()),
 [Age in Minutes] =
	DATEDIFF(MINUTE, Birthdate, GETDATE())
FROM People
GO