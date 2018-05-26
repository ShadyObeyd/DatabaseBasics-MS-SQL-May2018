--01.Create Database
CREATE DATABASE Minions

--02.Create Tables
CREATE TABLE Minions(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	Age INT
)

CREATE TABLE Towns(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

--03.Alter Minions Table
ALTER TABLE Minions
	ADD TownId INT

ALTER TABLE Minions
	ADD CONSTRAINT FK_Town FOREIGN KEY (TownId) REFERENCES Towns(Id)

--04.Populate Both Tables
INSERT INTO Towns (Id, [Name])
VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions (Id, [Name], Age, TownId)
VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

--05.Truncate Table Minions
TRUNCATE TABLE Minions

--06.Drop All Tables
DROP TABLE Minions
DROP TABLE Towns

--07.Create Table People
CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	Height DECIMAL(15,2),
	[Weight] DECIMAL(15,2),
	Gender CHAR(1) NOT NULL,
	Birthdate DATETIME2 NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People ([Name], Picture, Height, [Weight], Gender, Birthdate, Biography)
VALUES
('Pesho Petrov', NULL, 1.80, 95.00, 'm', CONVERT(DATETIME2, '15-02-1995', 103), 'I am Pesho Petrov and I am learning MS SQL!'),
('Ivan Ivanov', NULL, 1.95, 80.00, 'm', CONVERT(DATETIME2, '22-03-1986', 103), NULL),
('Stamat Stamatov', NULL, 1.78, 98.00, 'm', CONVERT(DATETIME2, '18-07-1978', 103), 'I am Stamat Stamatov!'),
('Penka Tatianova', NULL, 1.70, 48.00, 'f', CONVERT(DATETIME2, '30-04-2000', 103), 'I aint writting no biography!'),
('Neli Petkova', NULL, 1.63, 63.00, 'f', CONVERT(DATETIME2, '10-01-1989', 103), NULL)

--08.Create Table Users
CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTime DATETIME2,
	IsDeleted BIT
)

INSERT INTO Users (Username, [Password], ProfilePicture, LastLoginTime, IsDeleted)
VALUES
('Pesho', HASHBYTES('SHA1', 'PEsho123'), NULL, NULL, 0),
('Ivan', HASHBYTES('SHA1', 'vankata1398'), NULL, CONVERT(DATETIME2, '25-05-2018', 103), 0),
('Toshko Kukata', HASHBYTES('SHA1', 'SexyBoy'), NULL, CONVERT(DATETIME2, '25-05-2018', 103), 0),
('Bebceto', HASHBYTES('SHA1', 'Kykla'), NULL, CONVERT(DATETIME2, '25-05-2018', 103), 0),
('Gosho', HASHBYTES('SHA1', 'gesha2020'), NULL, CONVERT(DATETIME2, '25-05-2018', 103), 0)

--09.Change Primary Key
ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC079751F6B6

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY (Id, Username)

--10.Add Check Constraint
ALTER TABLE Users
ADD CONSTRAINT CHK_PasswordLenght CHECK (LEN(Password) >= 5)

--11.Set Default Value of a Field
ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime

--12.Set Unique Field
ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC07384EAE7B

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CHK_UsernameLenght CHECK (LEN(Username) >= 3)

--13.Movies Database
CREATE DATABASE Movies

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear DATETIME2,
	Lenght NVARCHAR(10),
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Rating DECIMAL(4, 2) NOT NULL,
	Notes NVARCHAR(200)
)

INSERT INTO Directors (DirectorName, Notes)
VALUES
('George Lucas', NULL),
('Jason Rothenberg', NULL),
('A&E Networks', NULL),
(' John de Mol Jr.', NULL),
('None', NULL)

INSERT INTO Genres (GenreName, Notes)
VALUES
('Sci-fy', NULL),
('Action', NULL),
('Science', NULL),
('Drama', NULL),
('Sports', NULL)

INSERT INTO Categories (CategoryName, Notes)
VALUES
('Movie', NULL),
('TV Series', NULL),
('Documentary', NULL),
('Reality Show', NULL),
('Sport Event', NULL)

INSERT INTO Movies (Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating, Notes)
VALUES
('Star Wars Episode I - The Phantom Menace', 1, CONVERT(DATETIME2, '17-09-1999', 103), NULL, 1, 1, 6.5, NULL),
('The 100', 2, CONVERT(DATETIME2, '19-03-2014', 103), '40m', 2, 2, 7.8, NULL),
('History Channel', 3, CONVERT(DATETIME2, '01-01-1995', 103), '∞', 3, 3, 10.00, NULL),
('Big Brother', 4, CONVERT(DATETIME2, '05-07-2000', 103), '1h', 4, 4, 5.4, NULL),
('Champions League', 5, CONVERT(DATETIME2, '20-04-1955', 103), NULL, 5, 5, 10.00, NULL)

--14.Car Rental Database
CREATE DATABASE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate DECIMAL(15,2) NOT NULL,
	WeeklyRate DECIMAL(15,2) NOT NULL,
	MonthlyRate DECIMAL(15,2) NOT NULL,
	WeekendRate DECIMAL(15,2) NOT NULL
)

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber NVARCHAR(50) NOT NULL UNIQUE,
	Manufacturer NVARCHAR(50),
	Model NVARCHAR(50),
	CarYear INT,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Doors INT,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(50),
	Available BIT
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber INT UNIQUE,
	FullName NVARCHAR(50) NOT NULL,
	[Address] NVARCHAR(50),
	City NVARCHAR(50) NOT NULL,
	ZIPCode INT,
	Notes NVARCHAR(50)
)

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
	CarId INT FOREIGN KEY REFERENCES Cars(Id),
	TankLevel INT, 
	KilometrageStart DECIMAL(15, 2) NOT NULL,
	KilometrageEnd DECIMAL(15, 2) NOT NULL,
	TotalKilometrage DECIMAL(15, 2),
	StartDate DATETIME2 NOT NULL,
	EndDate DATETIME2 NOT NULL,
	TotalDays INT,
	RateApplied DECIMAL(15, 2),
	TaxRate DECIMAL(15, 2) NOT NULL,
	OrderStatus NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

INSERT INTO Categories (CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
('Saloon', 15.50, 25.30, 50.00, 44.30),
('Cabriolet/Roadster', 20.00, 40.75, 100.00, 75.00),
('Small Car', 11.30, 18.70, 68.34, 50.00)

INSERT INTO Cars (PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES
('H2251BP', 'Honda', 'CR-V', 2008, 1, 5, NULL, 'Good', 1),
('T9816', 'Audi', '80', 1989, 1, 5, NULL, 'Excelent', 1),
('H0483BB', 'Ford', 'Mondeo', 2009, 1, 5, NULL, 'Average', 1)

INSERT INTO Employees (FirstName, LastName, Title, Notes)
VALUES
('Pesho', 'Petrov', 'Sales Manager', NULL),
('Georgi', 'Ivanov', 'Sales Person', 'Most sales of last year!'),
('Toncho', 'Tonchev', 'Accountant', 'To be fired!')

INSERT INTO Customers (DriverLicenceNumber, FullName, [Address], City, ZIPCode, Notes)
VALUES
(98548763, 'Georgi Georgiev', 'Balkanska str. 8', 'Shumen', 9700, 'Do not give rentals to this person!'),
(NULL, 'Vanko 1', NULL, 'Varna', 4444, 'Long forgotten rapper!'),
(54489632, 'Pesho Peshev', 'Viktorinova str. 10', 'Budapest', 8756, NULL)

INSERT INTO RentalOrders (EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus, Notes)
VALUES
(2, 3, 1, 60, 13600, 18000, 50000, CONVERT(DATETIME2, '18-05-2018', 103), CONVERT(DATETIME2, '28-05-2018', 103), 10, 25.30, 2.50, 'Approved', NULL),
(3, 1, 2, 55, 5000, 15000, 180000, CONVERT(DATETIME2, '22-03-2018', 103), CONVERT(DATETIME2, '27-03-2018', 103), 7, 40.75, 3.44, 'In Progress', 'Customer must be notified!'),
(1, 1, 1, 48, 0, 30000, 30000, CONVERT(DATETIME2, '10-04-2018', 103), CONVERT(DATETIME2, '13-04-2018', 103), NULL, NULL, 5.00, 'Denied', 'Customer didn''t pay!')

--15.Hotel Database
CREATE DATABASE Hotel

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

INSERT INTO Employees (FirstName, LastName, Title, Notes)
VALUES
('Hasan', 'Ibrahimov', 'Cleaner', 'Does his job well - reccomended for promotion.'),
('Georgi', 'Petrov', 'Hotel Manager', NULL),
('Petar', 'Peshev', 'Receptionist', 'Does not speak fluent English - considered to be fired.')

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	AccountNumber INT NOT NULL UNIQUE,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	PhoneNumber NVARCHAR(10) NOT NULL,
	EmergencyName NVARCHAR(50),
	EmergencyNumber NVARCHAR(10),
	Notes NVARCHAR(200)
)

INSERT INTO Customers (AccountNumber, FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber, Notes)
VALUES
(458968, 'Todor', 'Jivkov', '+359867588', 'Bai Tosho', '112', NULL),
(558963, 'Pesho', 'Goshev', '0878654712', 'Bosa na kvartala', NULL, NULL),
(123456, 'Boiko', 'Borisov', '112', NULL, NULL, NULL)

CREATE TABLE RoomStatus(
	Id INT PRIMARY KEY IDENTITY,
	RoomStatus NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

INSERT INTO RoomStatus (RoomStatus, Notes)
VALUES
('Occupied', NULL),
('Vacant', 'Needs cleaning!'),
('Uninhabitable', 'Needs repairs')

CREATE TABLE RoomTypes(
	Id INT PRIMARY KEY IDENTITY,
	RoomType NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

INSERT INTO RoomTypes (RoomType, Notes)
VALUES
('Normal', NULL),
('Appartment', 'Separte rooms - a bedroom and a kitchen'),
('Luxury room', NULL)

CREATE TABLE BedTypes(
	Id INT PRIMARY KEY IDENTITY,
	BedType NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(200)
)

INSERT INTO BedTypes (BedType, Notes)
VALUES
('Normal bed', NULL),
('King-sized bed', NULL),
('Queen-sized bed', NULL)

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	RoomNumber INT NOT NULL UNIQUE,
	RoomType INT FOREIGN KEY REFERENCES RoomTypes(Id),
	BedType INT FOREIGN KEY REFERENCES BedTypes(Id),
	Rate DECIMAL(4, 2),
	RoomStatus INT FOREIGN KEY REFERENCES RoomStatus(Id),
	Notes NVARCHAR(200)
)

INSERT INTO Rooms (RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes)
VALUES
(315, 1, 1, 4.5, 1, NULL),
(208, 2, 3, 9.5, 3, NULL),
(101, 3, 2, 10.00, 2, NULL)

CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	PaymentDate DATETIME2 NOT NULL,
	AccountNumber INT NOT NULL UNIQUE,
	FirstDateOccupied DATETIME2 NOT NULL,
	LastDateOccupied DATETIME2 NOT NULL,
	TotalDays INT,
	AmountCharged DECIMAL(15,2) NOT NULL,
	TaxRate DECIMAL(15,2),
	TaxAmount DECIMAL(15,2),
	PaymentTotal DECIMAL(15,2) NOT NULL,
	Notes NVARCHAR(200)
)

INSERT INTO Payments 
VALUES
(1, CONVERT(DATETIME2, '15-02-2017', 103), 556587, CONVERT(DATETIME2, '20-02-2017', 103), CONVERT(DATETIME2, '25-02-2017', 103), 5, 2568.36, NULL, NULL, 2763.48, NULL),
(3, CONVERT(DATETIME2, '23-03-2017', 103), 786312, CONVERT(DATETIME2, '18-11-2017', 103), CONVERT(DATETIME2, '18-12-2017', 103), 30, 5218.00, NULL, NULL, 5586.39, NULL),
(2, CONVERT(DATETIME2, '15-02-2017', 103), 358968, CONVERT(DATETIME2, '01-01-2017', 103), CONVERT(DATETIME2, '20-01-2017', 103), 20, 4158.45, NULL, NULL, 4395.80, NULL)

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	DateOccupied DATETIME2 NOT NULL,
	AccountNumber INT NOT NULL UNIQUE,
	RoomNumber INT REFERENCES Rooms(RoomNumber),
	RateApplier DECIMAL(15, 2),
	PhoneCharge DECIMAL(15, 2),
	Notes NVARCHAR(200)
)

INSERT INTO Occupancies
VALUES
(2, CONVERT(DATETIME2, '18-12-2017', 103), 458965, 315, NULL, NULL, NULL),
(3, CONVERT(DATETIME2, '09-09-2018', 103), 639821, 101, NULL, NULL, NULL),
(1, CONVERT(DATETIME2, '10-06-2016', 103), 214569, 208, NULL, NULL, NULL)

--16.Create SoftUni Database
CREATE DATABASE  SoftUni

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	AddressText NVARCHAR(100) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL,
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50),
	LastName NVARCHAR(50) NOT NULL,
	JobTitle NVARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
	HireDate DATETIME2,
	Salary DECIMAL(15, 2) NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

--17.Backup Database
BACKUP DATABASE SoftUni TO DISK = 'D:\softuni-backup.bak'

DROP DATABASE SoftUni

RESTORE DATABASE SoftUni FROM DISK = 'D:\softuni-backup.bak'

--18.Basic Insert
INSERT INTO Towns ([Name])
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments
VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees (FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary, AddressId)
VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 3, CONVERT(DATETIME2, '01/02/2013', 103), 3500, NULL),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, CONVERT(DATETIME2, '02/03/2004', 103), 4000, NULL),
('Maria', 'Petrova', 'Ivanova', 'Intern', 4, CONVERT(DATETIME2, '28/08/2016', 103), 525.25, NULL),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, CONVERT(DATETIME2, '09/12/2007', 103), 3000, NULL),
('Peter', 'Pan', 'Pan', 'Intern', 3, CONVERT(DATETIME2, '28/08/2016', 103), 599.88, NULL)

--19.Basic Select All Fields
SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees

--20.Basic Select All Fields And Order Them
SELECT * FROM Towns ORDER BY [Name]
SELECT * FROM Departments ORDER BY [Name]
SELECT * FROM Employees ORDER BY Salary DESC

--21.Basic Select Some Fields
SELECT [Name] FROM Towns ORDER BY [Name]
SELECT [Name] FROM Departments ORDER BY [Name]
SELECT FirstName, LastName, JobTitle, Salary FROM Employees ORDER BY Salary DESC

--22. Increase Employyes Salary
UPDATE Employees
SET Salary = Salary + (Salary * 0.1)

SELECT Salary FROM Employees

--23.Decrease Tax Rate
UPDATE Payments
SET TaxRate = TaxRate - (TaxRate * 0.03)

SELECT TaxRate FROM Payments

--24.Delete All Records
TRUNCATE TABLE Occupancies