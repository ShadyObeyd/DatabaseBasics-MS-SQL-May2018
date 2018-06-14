USE SoftUni
GO

--01.Employee Address
SELECT TOP (5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText
      FROM Employees AS e
      JOIN Addresses AS a
        ON a.AddressID = e.AddressID
  ORDER BY e.AddressID
GO

--02.Addresses with Towns
SELECT TOP (50) e.FirstName, e.LastName, t.[Name] AS Town, a.AddressText
      FROM Employees AS e
      JOIN Addresses AS a
        ON a.AddressID = e.AddressID
      JOIN Towns AS t
        ON t.TownID = a.TownID
  ORDER BY e.FirstName ASC, e.LastName ASC
GO

--03.Sales Employee
SELECT 
         e.EmployeeID, e.FirstName, e.LastName, d.[Name] AS DepartmentName
    FROM Employees AS e
    JOIN Departments AS d
      ON d.DepartmentID = e.DepartmentID
     AND d.[Name] = 'Sales'
ORDER BY e.EmployeeID
GO

--04.Employee Departments
SELECT TOP (5) e.EmployeeID, e.FirstName, e.Salary, d.[Name] AS DepartmentName
      FROM Employees AS e
      JOIN Departments AS d
        ON d.DepartmentID = e.DepartmentID
       AND e.Salary > 15000
  ORDER BY d.DepartmentID
GO

--05.Employees Without Project
SELECT TOP (3) emp.EmployeeID, emp.FirstName
      FROM Employees AS emp
 LEFT JOIN EmployeesProjects AS empPr
        ON empPr.EmployeeID = emp.EmployeeID
     WHERE empPr.EmployeeID IS NULL
  ORDER BY emp.EmployeeID
GO

--06.Employees Hired After
SELECT e.FirstName, e.LastName, e.HireDate, d.[Name] AS DeptName
  FROM Employees AS e
  JOIN Departments AS d
    ON d.DepartmentID = e.DepartmentID
 WHERE e.HireDate > '01/01/1999'
   AND d.[Name] = 'Sales' OR d.[Name] = 'Finance'
 ORDER BY e.HireDate

--07.Employees with Project
SELECT TOP (5) emp.EmployeeID, emp.FirstName, p.[Name] AS ProjectName
      FROM Employees AS emp
 LEFT JOIN EmployeesProjects AS empPr
        ON empPr.EmployeeID = emp.EmployeeID
INNER JOIN Projects AS p
        ON p.ProjectID = empPr.ProjectID
     WHERE empPr.EmployeeID IS NOT NULL
       AND p.StartDate > '08/13/2002'
       AND p.EndDate IS NULL
  ORDER BY emp.EmployeeID
GO


--08.Employee 24
SELECT e.EmployeeID, e.FirstName, ProjectName =
  CASE
  WHEN p.StartDate >= '01/01/2005' 
  THEN NULL
  ELSE p.[Name]
   END
  FROM EmployeesProjects AS ep
  JOIN Employees AS e
    ON e.EmployeeID = ep.EmployeeID
  JOIN Projects AS p
    ON p.ProjectID = ep.ProjectID
 WHERE ep.EmployeeID = 24
GO

--09.Employee Manager
SELECT 
        e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName AS ManagerName
   FROM Employees AS e
   JOIN Employees AS m
     ON m.EmployeeID = e.ManagerID
   WHERE e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID
GO

--10.Employee Summary
SELECT TOP (50) e.EmployeeID, 
                e.FirstName + ' ' + e.LastName AS EmployeeName,
	            m.FirstName + ' ' + m.LastName AS ManagerName,
	            d.[Name] AS DepartmentName 
      FROM Employees AS e
      JOIN Employees AS m
        ON m.EmployeeID = e.ManagerID
      JOIN Departments AS d
        ON d.DepartmentID = e.DepartmentID
   ORDER BY e.EmployeeID
GO

--11.Min Average Salary
SELECT MIN(AvgSalary) AS MinAverageSalary
FROM (
	  SELECT AVG(Salary) AS AvgSalary
	  FROM Employees
	  GROUP BY DepartmentID
) AS AvgSalaries

--12.Highest Peaks in Bulgaria
USE Geography
GO

SELECT 
         mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation
    FROM MountainsCountries AS mc
    JOIN Mountains AS m
      ON m.Id = mc.MountainId
    JOIN Peaks AS p
      ON p.MountainId = mc.MountainId
   WHERE mc.CountryCode = 'BG'
     AND p.Elevation > 2835
ORDER BY p.Elevation DESC
GO

--13.Count Mountain Ranges
SELECT 
        mc.CountryCode, COUNT(MountainRange) AS MountainRanges
   FROM MountainsCountries AS mc
   JOIN Mountains AS m
     ON m.Id = mc.MountainId
   WHERE mc.CountryCode IN ('BG', 'RU', 'US')
GROUP BY mc.CountryCode
GO

--14.Countries with Rivers
SELECT TOP (5) c.CountryName, r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr
ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r
ON r.Id = cr.RiverId
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName
GO

--15.Continents and Currencies
WITH CTE_CurrencyCounted (ContinentCode, CurrencyCode, CurrencyUsage) AS (
	SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage
	  FROM Countries 
  GROUP BY ContinentCode, CurrencyCode
    HAVING COUNT(CurrencyCode) > 1
)

SELECT cci.ContinentCode, cci.CurrencyCode, MaxCurrencies.MaxCurrency
FROM (
	SELECT ContinentCode, MAX(CurrencyUsage) AS MaxCurrency
	  FROM CTE_CurrencyCounted
  GROUP BY ContinentCode
) AS MaxCurrencies
    JOIN CTE_CurrencyCounted AS cci
      ON cci.ContinentCode = MaxCurrencies.ContinentCode
     AND cci.CurrencyUsage = MaxCurrencies.MaxCurrency
ORDER BY cci.ContinentCode
GO

--16.Countries without any Mountains
SELECT COUNT (*) AS CountryCode
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
WHERE mc.MountainId IS NULL

--17.Highest Peak and Longest River by Country
SELECT TOP(5) c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
ON mc.CountryCode = c.CountryCode
LEFT JOIN Peaks AS p
ON p.MountainId = mc.MountainId
LEFT JOIN CountriesRivers AS cr
ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r
ON r.Id = cr.RiverId
GROUP BY c.CountryName
ORDER BY MAX(p.Elevation) DESC, MAX(r.[Length]) DESC, c.CountryName ASC
GO

--18.Highest Peak Name and Elevation by Country
WITH CTE_MaxElevation(CountryName, PeakName, Elevation, MountainRange) AS (
SELECT c.CountryName, p.PeakName, MAX(p.Elevation) AS [Highest Peak Elevation], m.MountainRange
     FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
       ON mc.CountryCode = c.CountryCode
LEFT JOIN Mountains AS m
       ON m.Id = mc.MountainId
LEFT JOIN Peaks AS p
ON p.MountainId = mc.MountainId
GROUP BY c.CountryName, p.PeakName, m.MountainRange
)

SELECT TOP (5) MaxElevations.CountryName, 
	   ISNULL(cci.PeakName, '(no highest peak)') AS [Highest Peak Name], 
	   ISNULL(MaxElevations.MaxElevation, '0') AS [Highest Peak Elevation], 
	   ISNULL(cci.MountainRange, '(no mountain)') AS [Mountain]
FROM (
	SELECT CountryName, MAX(Elevation) AS MaxElevation
	FROM CTE_MaxElevation
	GROUP BY CountryName
) AS MaxElevations
LEFT JOIN CTE_MaxElevation AS cci
ON cci.Elevation = MaxElevations.MaxElevation
AND cci.CountryName = MaxElevations.CountryName
ORDER BY MaxElevations.CountryName, cci.PeakName
GO