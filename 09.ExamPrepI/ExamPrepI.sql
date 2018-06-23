--01.DDL
CREATE TABLE Clients(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Gender CHAR NOT NULL CHECK (Gender = 'M' OR Gender = 'F'),
	BirthDate DATETIME,
	CreditCard NVARCHAR(30) NOT NULL,
	CardValidity DATETIME,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Towns(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Offices(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(40),
	ParkingPlaces INT,
	TownId INT NOT NULL FOREIGN KEY REFERENCES Towns (Id)
)

CREATE TABLE Models(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	ProductionYear DATETIME,
	Seats INT,
	Class NVARCHAR(10),
	Consumption DECIMAL (14, 2)
)

CREATE TABLE Vehicles (
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	ModelId INT NOT NULL FOREIGN KEY REFERENCES Models(Id),
	OfficeId INT NOT NULL FOREIGN KEY REFERENCES Offices(Id),
	Mileage INT
)

CREATE TABLE Orders(
	Id INT NOT NULL PRIMARY KEY IDENTITY,
	ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(Id),
	TownId INT NOT NULL FOREIGN KEY REFERENCES Towns(Id),
	VehicleId INT NOT NULL FOREIGN KEY REFERENCES Vehicles(Id),
	CollectionDate DATETIME NOT NULL,
	CollectionOfficeId INT NOT NULL FOREIGN KEY REFERENCES Offices(Id),
	ReturnDate DATETIME,
	ReturnOfficeId INT FOREIGN KEY REFERENCES Offices(Id),
	Bill DECIMAL (14, 2),
	TotalMileage INT
)

--02.Insert
INSERT INTO Models
VALUES
('Chevrolet', 'Astro', CONVERT(DATETIME, '2005-07-27', 102), 4, 'Economy', 12.60),
('Toyota', 'Solara', CONVERT(DATETIME, '2009-10-15', 102), 7, 'Family', 13.80),
('Volvo', 'S40', CONVERT(DATETIME, '2010-10-12', 102), 3, 'Average', 11.30),
('Suzuki', 'Swift', CONVERT(DATETIME, '2000-02-03', 102), 7, 'Economy', 16.20)

INSERT INTO Orders
VALUES
(17, 2, 52, CONVERT(DATETIME, '2017-08-08', 102), 30, CONVERT(DATETIME, '2017-09-04', 102), 42, 2360, 7434),
(78, 17, 50, CONVERT(DATETIME, '2017-04-22', 102), 10, CONVERT(DATETIME, '2017-05-09', 102), 12, 2326, 7326),
(27, 13, 28, CONVERT(DATETIME, '2017-04-25', 102), 21, CONVERT(DATETIME, '2017-05-09', 102), 34, 597, 1880)

--03.Update
UPDATE Models
SET Class = 'Luxury'
WHERE Consumption > 20

--04.Delete
DELETE FROM Orders
WHERE ReturnDate IS NULL

--05.Showroom
SELECT Manufacturer, Model
FROM Models
ORDER BY Manufacturer ASC, Id DESC

--06.Y Generation
SELECT FirstName, LastName
FROM Clients
WHERE BirthDate BETWEEN '1977-01-01' AND '1994-12-31'
ORDER BY FirstName, LastName, Id

--07.Spacious Office
SELECT t.[Name], o.[Name], o.ParkingPlaces
FROM Offices AS o
JOIN Towns AS t
ON t.Id = o.TownId
WHERE o.ParkingPlaces > 25
ORDER BY t.[Name], o.Id

--08.Available Vehicles
SELECT m.Model, m.Seats, v.Mileage
FROM Vehicles AS v
JOIN Models AS m
ON m.Id = v.ModelId
WHERE v.Id NOT IN(
	SELECT VehicleId
	FROM Orders
	WHERE ReturnDate IS NULL
)
ORDER BY v.Mileage ASC, m.Seats DESC, m.Id ASC

--09.Offices per Town
SELECT t.[Name], COUNT(o.Id) AS OfficesNumber
FROM Offices AS o
JOIN Towns AS t
ON t.Id = o.TownId
GROUP BY t.[Name]
ORDER BY COUNT(o.Id) DESC, t.[Name] ASC

--10.Buyer's Best Choise
SELECT m.Manufacturer, m.Model, COUNT(v.Id) AS TimesOrdered
FROM Vehicles AS v
JOIN Orders AS o
ON o.VehicleId = v.Id
RIGHT JOIN Models AS m
ON m.Id = v.ModelId
GROUP BY m.Manufacturer, m.Model
ORDER BY TimesOrdered DESC, m.Manufacturer DESC, m.Model ASC

--11.Kinda Person
WITH CTE_RankedClientsClasses (Names, Class, RankedClasses) AS (
SELECT c.FirstName + ' ' + c.LastName AS Names,
	   m.Class,
	   RANK() OVER (PARTITION BY c.FirstName + ' ' + c.LastName ORDER BY COUNT(m.Class) DESC) AS RankedClasses
FROM Clients AS c
JOIN Orders AS o
ON o.ClientId = c.Id
JOIN Vehicles AS v
ON v.Id = o.VehicleId
JOIN Models AS m
ON m.Id = v.ModelId
GROUP BY c.FirstName + ' ' + c.LastName, m.Class)

SELECT Names, Class
FROM CTE_RankedClientsClasses
WHERE RankedClasses = 1
ORDER BY Names, Class

--12.Age Groups Revenue
SELECT AgeGroup =
     CASE
		WHEN BirthDate BETWEEN '1970-01-01' AND '1979-12-31'
			THEN '70''s'
		WHEN BirthDate BETWEEN '1980-01-01' AND '1989-12-31'
			THEN '80''s'
		WHEN BirthDate BETWEEN '1990-01-01' AND '1999-12-31'
			THEN '90''s'
	    ELSE 'Others'
	END,
	SUM(o.Bill) AS Revenue,
	AVG(o.TotalMileage) AS AverageMileage
FROM Clients AS c
JOIN Orders As o
ON o.ClientId = c.Id
GROUP BY CASE
			WHEN BirthDate BETWEEN '1970-01-01' AND '1979-12-31'
				THEN '70''s'
			WHEN BirthDate BETWEEN '1980-01-01' AND '1989-12-31'
				THEN '80''s'
			WHEN BirthDate BETWEEN '1990-01-01' AND '1999-12-31'
				THEN '90''s'
			ELSE 'Others'
		 END
ORDER BY AgeGroup

--13.Consumption in Mind
WITH CTE_OrderedModels (Manufacturer, Model, AverageConsumption, [Counter]) AS (
SELECT TOP(7) m.Manufacturer,
	   m.Model,
	   AVG(m.Consumption) AS AverageConsumption,
	   COUNT(m.Model) AS [Counter]
FROM Orders AS o
JOIN Vehicles AS v
ON v.Id = o.VehicleId
JOIN Models AS m
ON m.Id = v.ModelId
GROUP BY m.Manufacturer, m.Model
ORDER BY [Counter] DESC)

SELECT Manufacturer, AverageConsumption
FROM CTE_OrderedModels
WHERE AverageConsumption BETWEEN 5 AND 15
ORDER BY Manufacturer, AverageConsumption

--14.Debt Hunter
WITH CTE_RankedBills (ClientId, CategoryName, Email, Bill, TownName, RankedBills) AS (
SELECT c.Id,
	   c.FirstName + ' ' + c.LastName AS CategoryName, 
	   c.Email, 
	   o.Bill, 
	   t.[Name],
	   DENSE_RANK() OVER (PARTITION BY t.[Name] ORDER BY o.Bill DESC) AS RankedBills
FROM Clients AS c
JOIN Orders AS o
ON o.ClientId = c.Id
JOIN Towns As t
ON t.Id = o.TownId
WHERE o.CollectionDate > c.CardValidity AND o.Bill IS NOT NULL
GROUP BY c.Id, c.FirstName, c.LastName, c.Email, o.Bill,t.[Name])

SELECT CategoryName, Email, Bill, TownName
FROM CTE_RankedBills
WHERE RankedBills <= 2
ORDER BY TownName, Bill, ClientId

--15.Town Statistics
WITH CTE_CountedMenAndWomen (TownId, MenCount, WomenCount) AS (
SELECT o.TownId,
	  CASE WHEN (c.Gender = 'M') THEN COUNT(o.Id) END AS MenCount,
	  CASE WHEN (c.Gender = 'F') THEN COUNT(o.Id) END AS WomenCount
FROM Orders AS o
JOIN Clients AS c
ON c.Id = o.ClientId
GROUP BY c.Gender, o.TownId)

SELECT t.[Name] AS TownName,
	   (SUM(cci.MenCount) * 100) / (SUM(cci.MenCount) + ISNULL(SUM(cci.WomenCount), 0)) AS MalePercent,
	   (SUM(cci.WomenCount) * 100) / (ISNULL(SUM(cci.MenCount), 0) + SUM(cci.WomenCount)) AS FemalePercent
FROM CTE_CountedMenAndWomen AS cci
JOIN Towns AS t
ON t.Id = cci.TownId
GROUP BY t.[Name]
GO

--16.Home Sweet Home
WITH CTE_RankedRentedVehicles (ReturnOfficeId, OfficeId, Id, Manufacturer, Model) AS (
SELECT ReturnOfficeId, OfficeId, Id, Manufacturer, Model
FROM (
SELECT DENSE_RANK() OVER (PARTITION BY v.Id ORDER BY o.CollectionDate DESC) LatestRentedVehiclesRank,
       o.ReturnOfficeId,
	   v.OfficeId,
	   v.Id,
	   m.Manufacturer,
	   m.Model
FROM Orders AS o
RIGHT JOIN Vehicles AS v
ON v.Id = o.VehicleId
JOIN Models AS m
ON m.Id = v.ModelId) AS RankedByDateDesc
WHERE LatestRentedVehiclesRank = 1)

SELECT CONCAT(Manufacturer, ' - ', Model) AS Vehicle,
	   [Location] =
			 CASE
				WHEN (SELECT COUNT(*) 
					  FROM Orders AS o
				      WHERE o.VehicleId = CTE_RankedRentedVehicles.Id) = 0
				THEN 'home'
				WHEN 
					CTE_RankedRentedVehicles.ReturnOfficeId IS NULL
				THEN 'on a rent'
				WHEN
					CTE_RankedRentedVehicles.OfficeId <> CTE_RankedRentedVehicles.ReturnOfficeId
				THEN (SELECT CONCAT(t.[Name], ' - ', o.[Name])
				      FROM Towns AS t
					  JOIN Offices AS o
					  ON o.TownId = t.Id
					  WHERE o.Id = CTE_RankedRentedVehicles.ReturnOfficeId)
			 END
FROM CTE_RankedRentedVehicles
ORDER BY Vehicle, CTE_RankedRentedVehicles.Id

--17.Find My Ride
CREATE FUNCTION udf_CheckForVehicle(@townName NVARCHAR(50), @seatsNumber INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @result NVARCHAR(MAX) = (SELECT TOP(1) CONCAT(o.[Name], ' - ', m.Model)
									 FROM Models AS m
									 JOIN Vehicles AS v
									 ON v.ModelId = m.Id
									 JOIN Offices AS o
									 ON o.Id = v.OfficeId
									 JOIN Towns AS t
									 ON t.Id = o.TownId
									 WHERE m.Seats = @seatsNumber
									 AND t.[Name] = @townName
									 ORDER BY o.[Name]);
	IF(@result IS NULL)
	BEGIN
		RETURN 'NO SUCH VEHICLE FOUND';
	END

	RETURN @result
END
GO

--18.Move a Vehicle
CREATE PROCEDURE usp_MoveVehicle(@vehicleId INT, @officeId INT)
AS
BEGIN
	DECLARE @vehicleCountInOffice INT = (SELECT COUNT(Id) 
										 FROM Vehicles
										 WHERE OfficeId = @officeId);
	
	DECLARE @freeVehicleSpots INT = (SELECT ParkingPlaces 
									 FROM Offices
									 WHERE Id = @officeId);
	
	IF(@freeVehicleSpots > @vehicleCountInOffice)
	BEGIN
		UPDATE Vehicles
		SET OfficeId = @officeId
		WHERE Id = @vehicleId
	END
	ELSE
	BEGIN
		RAISERROR('Not enough room in this office!', 16, 1)
	END
END

--19.Move the Tally
CREATE TRIGGER tr_MoveTheTally ON Orders AFTER UPDATE
AS
BEGIN
	DECLARE @newTotalMileage INT = (SELECT TotalMileage
									FROM inserted);

	DECLARE @oldTotalMileage INT = (SELECT TotalMileage
									FROM deleted);

	DECLARE @vehicleId INT = (SELECT VehicleId
							  FROM inserted);

	IF(@oldTotalMileage IS NULL AND @vehicleId IS NOT NULL)
	BEGIN
		UPDATE Vehicles
		SET Mileage += @newTotalMileage
		WHERE Id = @vehicleId
	END
END