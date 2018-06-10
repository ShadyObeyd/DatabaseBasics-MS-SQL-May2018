USE Demo
GO

--01.One-To-One Relationship
CREATE TABLE Persons (
	PersonID INT NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	Salary DECIMAL(15, 2),
	PassportID INT NOT NULL UNIQUE
)
GO

CREATE TABLE Passports(
	PassportID INT NOT NULL,
	PassportNumber NVARCHAR(50) NOT NULL UNIQUE
)
GO

INSERT INTO Passports
VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')
GO

INSERT INTO Persons
VALUES
(1, 'Roberto', 43300, 102),
(2, 'Tom', 56100, 103),
(3, 'Yana', 60200, 101)
GO

ALTER TABLE Persons
ADD CONSTRAINT PK_Persons
PRIMARY KEY (PersonID)
GO

ALTER TABLE Passports
ADD CONSTRAINT PK_Passports
PRIMARY KEY (PassportID)
GO

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passports
FOREIGN KEY (PassportID)
REFERENCES Passports(PassportID)
GO

--02.One-To-Many Relationship
CREATE TABLE Manufacturers(
	ManufacturerID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	EstablishedOn DATE 
)

CREATE TABLE Models(
	ModelID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManufacturerID INT
)

INSERT INTO Manufacturers
VALUES
(1, 'BMW', CONVERT(DATE, '07/03/1916')),
(2, 'Tesla', CONVERT(DATE, '01/01/2003')),
(3, 'Lada', CONVERT(DATE, '01/05/1966'))

INSERT INTO Models
VALUES
(101, 'X1', 1),
(102, 'i6', 1),
(103, 'Model S', 2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)

ALTER TABLE Manufacturers
ADD CONSTRAINT PK_Manufacturers
PRIMARY KEY (ManufacturerID)

ALTER TABLE Models
ADD CONSTRAINT PK_Models
PRIMARY KEY (ModelID)

ALTER TABLE Models
ADD CONSTRAINT FK_Models_Manufacturers
FOREIGN KEY (ManufacturerID)
REFERENCES Manufacturers(ManufacturerID)

--03.Many-To-Many Relationship
CREATE TABLE Students (
	StudentID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

INSERT INTO Students
VALUES
(1, 'Mila'),
(2, 'Toni'),
(3, 'Ron')

CREATE TABLE Exams (
	ExamID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

INSERT INTO Exams
VALUES
(101, 'SpringMVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g')

CREATE TABLE StudentsExams(
	StudentID INT NOT NULL,
	ExamID INT NOT NULL
)

ALTER TABLE Students
ADD CONSTRAINT PK_Students
PRIMARY KEY (StudentID)

ALTER TABLE Exams
ADD CONSTRAINT PK_Exams
PRIMARY KEY (ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_StudentsExams
PRIMARY KEY (StudentID, ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_Students
FOREIGN KEY (StudentID)
REFERENCES Students(StudentID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentsExams_Exams
FOREIGN KEY (ExamID)
REFERENCES Exams(ExamID)

--04.Self-Referencing
CREATE TABLE Teachers(
	TeacherID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	ManagerID INT

	CONSTRAINT PK_Teachers
	PRIMARY KEY (TeacherID)

	CONSTRAINT FK_Teachers_ManagerID
	FOREIGN KEY (ManagerID)
	REFERENCES Teachers (TeacherID)
)

INSERT INTO Teachers
VALUES
(101, 'John', NULL),
(102, 'Maya', 106),
(103, 'Silvia', 106),
(104, 'Ted', 105),
(105, 'Mark', 101),
(106, 'Greta', 101)

--05.Online Store Database
CREATE TABLE Cities (
	CityID INT NOT NULL IDENTITY,
	[Name] VARCHAR(50) NOT NULL

	CONSTRAINT PK_Cities
	PRIMARY KEY (CityID)
)

CREATE TABLE Customers(
	CustomerID INT NOT NULL IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Birthday DATE,
	CityID INT NOT NULL

	CONSTRAINT PK_Customers
	PRIMARY KEY (CustomerID)

	CONSTRAINT FK_Customers_Cities
	FOREIGN KEY (CityID)
	REFERENCES Cities (CityID)
)

CREATE TABLE Orders (
	OrderID INT NOT NULL IDENTITY,
	CustomerID INT NOT NULL

	CONSTRAINT PK_Orders
	PRIMARY KEY (OrderID)

	CONSTRAINT FK_Orders_Customers
	FOREIGN KEY (CustomerID)
	REFERENCES Customers (CustomerID)
)

CREATE TABLE ItemTypes (
	ItemTypeID INT NOT NULL IDENTITY,
	[Name] VARCHAR(50) NOT NULL

	CONSTRAINT PK_ItemTypes
	PRIMARY KEY (ItemTypeID)
)

CREATE TABLE Items(
	ItemID INT NOT NULL IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	ItemTypeID INT NOT NULL

	CONSTRAINT PK_Items
	PRIMARY KEY (ItemID)

	CONSTRAINT FK_Items_ItemTypes
	FOREIGN KEY (ItemTypeID)
	REFERENCES ItemTypes (ItemTypeID)
)

CREATE TABLE OrderItems(
	OrderID INT NOT NULL,
	ItemID INT NOT NULL

	CONSTRAINT PK_OrderItems
	PRIMARY KEY (OrderID, ItemID)

	CONSTRAINT FK_OrderItems_Orders
	FOREIGN KEY (OrderID)
	REFERENCES Orders (OrderID),

	CONSTRAINT FK_OrderItems_Items
	FOREIGN KEY (ItemID)
	REFERENCES Items (ItemID)
)

--06.University Database
CREATE TABLE Majors (
	MajorID INT NOT NULL IDENTITY,
	[Name] NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Majors
	PRIMARY KEY (MajorID)
)

CREATE TABLE Students (
	StudentID INT NOT NULL,
	StudentNumber NVARCHAR(50) NOT NULL UNIQUE,
	StudentName NVARCHAR(50) NOT NULL,
	MajorID INT NOT NULL

	CONSTRAINT PK_Students
	PRIMARY KEY (StudentID)

	CONSTRAINT FK_Students_Majors
	FOREIGN KEY (MajorID)
	REFERENCES Majors (MajorID)
)

CREATE TABLE Payments (
	PaymentID INT NOT NULL IDENTITY,
	PaymentDate DATE NOT NULL,
	PaymentAmount DECIMAL(15,2) NOT NULL,
	StudentID INT NOT NULL

	CONSTRAINT PK_Payments
	PRIMARY KEY (PaymentID)

	CONSTRAINT FK_Payments_Students
	FOREIGN KEY (StudentID)
	REFERENCES Students (StudentID)
)

CREATE TABLE Subjects (
	SubjectID INT NOT NULL IDENTITY,
	SubjectName NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Subjects
	PRIMARY KEY (SubjectID)
)

CREATE TABLE Agenda (
	StudentID INT NOT NULL,
	SubjectID INT NOT NULL

	CONSTRAINT PK_Agenda
	PRIMARY KEY (StudentID, SubjectID)

	CONSTRAINT FK_Agenda_Students
	FOREIGN KEY (StudentID)
	REFERENCES Students (StudentID),

	CONSTRAINT FK_Agenda_Subjects
	FOREIGN KEY (SubjectID)
	REFERENCES Subjects (SubjectID)
)

--09.Peaks in Rila
USE Geography
GO

SELECT MountainRange, PeakName, Elevation
FROM Peaks AS p
JOIN Mountains AS m
ON m.Id = p.MountainId
WHERE m.MountainRange = 'Rila'
ORDER BY p.Elevation DESC
GO