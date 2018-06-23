--01.DDL
CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username NVARCHAR(30) NOT NULL UNIQUE,
	[Password] NVARCHAR(50) NOT NULL,
	[Name] NVARCHAR(50),
	Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	DepartmentId INT FOREIGN KEY REFERENCES Departments (Id) NOT NULL
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE [Status](
	Id INT PRIMARY KEY IDENTITY,
	Label VARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES Status(Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	[Description] VARCHAR(200) NOT NULL,
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

--02.Insert
INSERT INTO Employees (FirstName, LastName, Gender, BirthDate, DepartmentId)
VALUES
('Marlo', 'O’Malley', 'M', '9/21/1958', 1),
('Niki', 'Stanaghan', 'F', '11/26/1969', 4),
('Ayrton', 'Senna', 'M', '03/21/1960', 9),
('Ronnie', 'Peterson', 'M', '02/14/1944', 9),
('Giovanna', 'Amati', 'F', '07/20/1959', 5)

INSERT INTO Reports (CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId)
VALUES
(1, 1, '04/13/2017', NULL, 'Stuck Road on Str.133', 6, 2),
(6, 3, '09/05/2015', '12/06/2015', 'Charity trail running', 3, 5),
(14, 2, '09/07/2015', NULL, 'Falling bricks on Str.58', 5, 2),
(4, 3, '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', 1, 1)

--03.Update
UPDATE Reports
SET StatusId = 2
WHERE StatusId = 1
AND CategoryId = 4

--04.Delete
DELETE Reports
WHERE StatusId = 4

--05.Users by Age
SELECT Username, Age
FROM Users
ORDER BY Age ASC, Username DESC

--06.Unassigned Reports
SELECT [Description], OpenDate
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]

--07.Employees & Reports
SELECT e.FirstName, e.LastName, r.[Description], FORMAT(r.OpenDate, 'yyyy-MM-dd') AS OpenDate
FROM Employees AS e
JOIN Reports AS r
ON r.EmployeeId = e.Id
ORDER BY e.Id, OpenDate

--08.Most reported Category
SELECT c.[Name], COUNT (r.Id) AS ReportsNumber
FROM Categories AS c
JOIN Reports AS r
ON r.CategoryId = c.Id
GROUP BY c.[Name]
ORDER BY ReportsNumber DESC, c.[Name] ASC

--09.Employees in Category
SELECT c.[Name], COUNT(e.Id) AS [Employees Number]
FROM Categories AS c
JOIN Departments AS d
ON d.Id = c.DepartmentId
JOIN Employees AS e
ON e.DepartmentId = d.Id
GROUP BY c.[Name]
ORDER BY c.[Name]

--10.Users per Employee
SELECT e.FirstName + ' ' + e.LastName AS [Name],
	   COUNT(r.UserId) AS [Users Number]
FROM Employees AS e
LEFT JOIN Reports AS r
ON r.EmployeeId = e.Id
GROUP BY e.FirstName + ' ' + e.LastName
ORDER BY [Users Number] DESC, [Name] ASC

--11.Emergency Patrol
SELECT r.OpenDate, r.[Description], u.Email AS [Reporter Email]
FROM Reports AS r
JOIN Categories AS c
ON c.Id = r.CategoryId
JOIN Users As u
ON u.Id = r.UserId
WHERE r.CloseDate IS NULL
AND LEN(r.[Description]) > 20
AND r.[Description] LIKE '%str%'
AND c.DepartmentId IN(1, 4, 5)
ORDER BY r.OpenDate, [Reporter Email], r.Id

--12.Birthday Report
SELECT c.[Name]
FROM Categories AS c
JOIN Reports AS r
ON r.CategoryId = c.Id
JOIN Users AS u
ON u.Id = r.UserId
WHERE MONTH(r.OpenDate) = MONTH(u.BirthDate)
AND DAY (r.OpenDate) = DAY(u.BirthDate)
GROUP BY c.[Name]

--13.Numbers Coincidence
SELECT u.Username
FROM Users AS u
JOIN Reports AS r
ON r.UserId = u.Id
JOIN Categories AS c
ON c.Id = r.CategoryId
WHERE (LEFT(u.Username, 1) LIKE '[0-9]'
	   AND LEFT(u.Username, 1) = CONVERT(NVARCHAR, c.Id))
OR (RIGHT(u.Username, 1) LIKE '[0-9]'
	AND RIGHT(u.Username, 1) = CONVERT(NVARCHAR, c.Id))
GROUP BY u.Username
GO

--14.Open/Closed Statistics
WITH CTE_OpenReports (Id, [Name], OpenReportsIds) AS (
SELECT e.Id, e.FirstName + ' ' + e.LastName AS [Name],
	   COUNT(r.Id) AS OpenReportsIds
FROM Employees AS e
JOIN Reports AS r
ON r.EmployeeId = e.Id
WHERE YEAR(r.OpenDate) = 2016
GROUP BY e.Id, e.FirstName + ' ' + e.LastName)

SELECT COALESCE([or].[Name], cr.[Name]) AS [Name],
	   CONCAT(ISNULL(cr.ClosedReportsIds, 0), '/', ISNULL([or].OpenReportsIds, 0)) AS [Closed Open Reports]
FROM (
	SELECT e.Id, e.FirstName + ' ' + e.LastName AS [Name],
		   COUNT(r.Id) AS ClosedReportsIds
	FROM Employees AS e
	JOIN Reports AS r
	ON r.EmployeeId = e.Id
	WHERE YEAR(CloseDate) = 2016
	GROUP BY e.Id, e.FirstName + ' ' + e.LastName) AS cr
FULL JOIN CTE_OpenReports AS [or]
ON [or].Id = cr.Id
ORDER BY [Name], [or].Id

--15.Average Closing Time
SELECT d.[Name], 
	   ISNULL(CONVERT(NVARCHAR, AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate))), 'no info') AS [Average Duration]
FROM Reports AS r
JOIN Categories AS c
ON c.Id = r.CategoryId
JOIN Departments AS d
ON d.Id = c.DepartmentId
GROUP BY d.[Name]
GO

--16.Favorite Categories
WITH CTE_TotalReportsPerDepartments ([Department Name], ReportsPerDepartment) AS (
SELECT d.[Name] AS [Department Name],
       COUNT(r.Id) AS ReportsPerDepartmentsCount
FROM Departments AS d
JOIN Categories AS c
ON c.DepartmentId = d.Id
JOIN Reports AS r
ON r.CategoryId = c.Id
JOIN Users AS u
ON u.Id = r.UserId
GROUP BY d.[Name])
 
SELECT e.[Department Name],
       e.[Category Name],
       CAST(ROUND((CAST(e.ReportsPerCategoryCount AS DECIMAL) / dtr.ReportsPerDepartment) * 100, 0) AS INT) AS [Percentage]
FROM (
    SELECT d.[Name] AS [Department Name],
           c.[Name] AS [Category Name],
           COUNT(r.Id) AS ReportsPerCategoryCount
    FROM Departments AS d
    JOIN Categories AS c
    ON c.DepartmentId = d.Id
    JOIN Reports AS r
    ON r.CategoryId = c.Id
    JOIN Users AS u
    ON u.Id = r.UserId
    GROUP BY c.[Name], d.[Name]) AS e
JOIN CTE_TotalReportsPerDepartments AS dtr
ON dtr.[Department Name] = e.[Department Name]
ORDER BY [Department Name], [Category Name], [Percentage]

--17.Employee’s Load
CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT)
RETURNS INT
AS
BEGIN
	DECLARE @ReportsCount INT = (SELECT COUNT(Id) 
							 FROM Reports
							 WHERE EmployeeId = @employeeId
							 AND StatusId = @statusId)
	RETURN @ReportsCount
END
GO

--18.Assign Employee
CREATE PROCEDURE usp_AssignEmployeeToReport(@employeeId INT, @reportId INT) AS
BEGIN
	DECLARE @employeeDepartmentId INT = (
										 SELECT DepartmentId
										 FROM Employees
										 WHERE Id = @employeeId);
	
	DECLARE @reportsCategoryDepartmentId INT = (SELECT c.DepartmentId
												FROM Reports AS r
												JOIN Categories As c
												ON c.Id = r.CategoryId
												WHERE r.Id = @reportId);
	IF(@employeeDepartmentId = @reportsCategoryDepartmentId)
	BEGIN
		UPDATE Reports
		SET EmployeeId = @employeeId
	END
	ELSE
	BEGIN
		RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1);
		ROLLBACK
	END
END


--19.Close Reports
CREATE TRIGGER tr_CompletedReport ON Reports AFTER UPDATE
AS
BEGIN
	IF UPDATE (CloseDate)
	BEGIN
		UPDATE Reports
		SET StatusId = 3;
	END
END

--20.Categories Revision
WITH CTE_CountedReports (CategoryName, [Reports Number], InProgressCount, WaitingCount) AS (
SELECT c.[Name], 
	   COUNT(r.Id) AS [Reports Number],
	   SUM(CASE WHEN s.Label = 'in progress' THEN 1 ELSE 0 END) AS InProgressCount,
	   SUM(CASE WHEN s.Label = 'waiting' THEN 1 ELSE 0 END) AS WaitingCount
FROM Categories AS c
JOIN Reports AS r
ON r.CategoryId = c.Id
JOIN [Status] AS s
ON s.Id = r.StatusId
WHERE r.StatusId = 1
OR r.StatusId = 2
GROUP BY c.[Name])

SELECT CategoryName, 
	   [Reports Number],
	   [Main Status] =
	   CASE
	     WHEN InProgressCount > WaitingCount THEN 'in progress'
		 WHEN WaitingCount > InProgressCount THEN 'waiting'
		 ELSE 'equal'
	   END
FROM CTE_CountedReports