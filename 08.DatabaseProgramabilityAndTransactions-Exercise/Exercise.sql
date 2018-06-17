--01.Employees with Salary Above 35000
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000 AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees
	 WHERE Salary > 35000
END
GO

--02.Employees with Salary Above Number
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@value DECIMAL (18, 4)) AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees
	 WHERE Salary >= @value
END
GO

--03.Town Names Starting With
CREATE PROCEDURE usp_GetTownsStartingWith (@townStr VARCHAR(50)) AS
BEGIN
	SELECT [Name]
	  FROM Towns
	 WHERE [Name] LIKE @townStr + '%'
END
GO

--04.Employees from Town
CREATE PROCEDURE usp_GetEmployeesFromTown (@townName VARCHAR(50)) AS
BEGIN
	SELECT e.FirstName, e.LastName
	  FROM Employees AS e
	  JOIN Addresses AS a
	    ON a.AddressID = e.AddressID
	  JOIN Towns AS t
	    ON t.TownID = a.TownID
	 WHERE t.[Name] = @townName
END
GO

--05.Salary Level Function
CREATE FUNCTION ufn_GetSalaryLevel (@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(7);
	IF(@salary < 30000)
	BEGIN
		SET @salaryLevel = 'Low';
	END
	ELSE IF (@salary BETWEEN 30000 AND 50000)
	BEGIN
		SET @salaryLevel = 'Average';
	END
	ELSE
	BEGIN
		SET @salaryLevel = 'High';
	END
	RETURN @salaryLevel;
END
GO

--06.Employees by Salary Level
CREATE PROCEDURE usp_EmployeesBySalaryLevel (@salaryLevel VARCHAR(50)) AS
BEGIN
	SELECT FirstName, LastName
	  FROM Employees
	 WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END
GO

--07.Define Function
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @currentIndex INT = 1;

	WHILE (@currentIndex <= LEN(@word))
	BEGIN
		DECLARE @currentLetter CHAR(1) = SUBSTRING(@word, @currentIndex, 1);
		DECLARE @ContainsLetter INT = CHARINDEX(@currentLetter, @setOfLetters);

		IF(@ContainsLetter = 0)
		BEGIN
			RETURN 0;
		END
		SET @currentIndex += 1;
	END
	RETURN 1;
END
GO

--08.Delete Employees and Departments
CREATE PROCEDURE usp_DeleteEmployeesFromDepartment (@departmentId INT) AS
BEGIN
	DELETE FROM EmployeesProjects
	      WHERE EmployeeID IN 
	(
		SELECT EmployeeID
		  FROM Employees 
		 WHERE DepartmentID = @departmentId
	)

	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	UPDATE Employees
	   SET ManagerID = NULL
	 WHERE ManagerID IN
	 (
		SELECT EmployeeID
		  FROM Employees
		 WHERE DepartmentID = @departmentId
	 )

	 UPDATE Departments
	    SET ManagerID = NULL
	  WHERE ManagerID IN
	(
		SELECT EmployeeID
		  FROM Employees
		 WHERE DepartmentID = @departmentId
	)

	DELETE FROM Employees
	      WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	      WHERE DepartmentID = @departmentId

	SELECT COUNT (*)
	  FROM Employees
	 WHERE DepartmentID = @departmentId
END
GO

--09.Find Full Name
USE Bank
GO

CREATE PROCEDURE usp_GetHoldersFullName AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name]
	FROM AccountHolders
END
GO

--10.People with Balance Higher Than
CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan (@value DECIMAL(14,2)) AS
BEGIN
	WITH CTE_TotalBalances(AccountHolderId) AS(
		SELECT AccountHolderId
		 FROM Accounts
	 GROUP BY AccountHolderId
       HAVING SUM(Balance) > @value
	)
	
	SELECT ah.FirstName, ah.LastName
	  FROM AccountHolders AS ah
	  JOIN CTE_TotalBalances AS cci
	    ON cci.AccountHolderId = ah.Id
  ORDER BY ah.LastName, ah.FirstName
END
GO

--11.Future Value Function
CREATE FUNCTION ufn_CalculateFutureValue (@sum DECIMAL(18, 4), @interestRate FLOAT, @yearsCount INT)
RETURNS DECIMAL (18, 4)
AS
BEGIN
	DECLARE @result DECIMAL (18, 4);

	SET @result = @sum * (POWER(1 + @interestRate, @yearsCount));

	RETURN @result;
END
GO

--12.Calculating Interest
CREATE PROCEDURE usp_CalculateFutureValueForAccount (@accountId INT, @interestRate DECIMAL (14, 2)) AS
BEGIN
	SELECT a.Id AS AcacountId, 
		   ah.FirstName, ah.LastName, 
		   a.Balance, 
		   dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) AS [Balance in 5 years]
	  FROM AccountHolders AS ah
	  JOIN Accounts AS a
	    ON a.AccountHolderId = ah.Id
	 WHERE a.Id = @accountId
END
GO

--13.Scalar Function: Cash in User Games Odd Rows
USE Diablo
GO

CREATE FUNCTION ufn_CashInUsersGames (@gameName VARCHAR(50))
RETURNS TABLE
AS
RETURN (
	SELECT SUM(t.Cash) AS TotalCash
	  FROM (
		SELECT g.Id, ug.Cash, ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS [Row]
		  FROM Games AS g
		  JOIN UsersGames AS ug
		    ON ug.GameId = g.Id
		 WHERE g.[Name] = @gameName) AS t
	WHERE t.[Row] % 2 = 1
)
GO

--14.Create Table Logs
CREATE TABLE Logs(
	LogId INT NOT NULL IDENTITY,
	AccountId INT NOT NULL,
	OldSum DECIMAL(14,2) NOT NULL,
	NewSum DECIMAL (14, 2) NOT NULL

	CONSTRAINT PK_Logs
	PRIMARY KEY (LogId)

	CONSTRAINT FK_Logs_Accounts
	FOREIGN KEY (AccountId)
	REFERENCES Accounts (Id)
)
GO

CREATE TRIGGER tr_AccountsUpdate ON Accounts AFTER UPDATE
AS
BEGIN
	INSERT Logs(AccountId, OldSum, NewSum)
	SELECT inserted.ID, deleted.Balance, inserted.Balance
	  FROM deleted, inserted
END
GO

--15.Create Table Emails
CREATE TABLE NotificationEmails (
	Id INT NOT NULL IDENTITY,
	Recipient INT NOT NULL,
	[Subject] NVARCHAR(50) NOT NULL,
	Body NVARCHAR(256) NOT NULL

	CONSTRAINT PK_NotificationEmails
	PRIMARY KEY (Id)

	CONSTRAINT FK_EmailNotifications_Accounts
	FOREIGN KEY (Recipient)
	REFERENCES Accounts (Id)
)
GO

CREATE TRIGGER tr_EmailNotification ON Logs AFTER INSERT
AS
BEGIN
	INSERT NotificationEmails(Recipient, [Subject], Body)
	SELECT inserted.AccountId,
		   CONCAT('Balance change for account: ', inserted.AccountId),
		   CONCAT('On ', GETDATE(), ' your balance was changed from ', inserted.OldSum, ' to ', inserted.NewSum, '.')
	FROM inserted
END
GO

--16.Deposit Money
CREATE PROCEDURE usp_DepositMoney (@accountId INT, @moneyAmount DECIMAL (18, 4)) 
AS
BEGIN
	IF (@moneyAmount >= 0)
	BEGIN
		UPDATE Accounts
		   SET Balance += @moneyAmount
		 WHERE Id = @accountId
	END
END
GO

--17.Withdraw Money
CREATE PROCEDURE usp_WithdrawMoney (@accountId INT, @moneyAmount DECIMAL (18, 4))
AS
BEGIN
	IF(@moneyAmount >= 0)
	BEGIN
		UPDATE Accounts
		   SET Balance -= @moneyAmount
		 WHERE Id = @accountId
	END
END
GO

--18.Money Transfer
CREATE PROCEDURE usp_TransferMoney(@senderId INT, @receiverId INT, @amount DECIMAL(18, 4))
AS
BEGIN
	IF(@amount >= 0)
	BEGIN
		UPDATE Accounts
		   SET Balance -= @amount
		 WHERE Id = @senderId

		UPDATE Accounts
		   SET Balance += @amount
		 WHERE Id = @receiverId
	END
END
GO

--20.Massive Shopping
DECLARE @userId INT = (SELECT Id 
                         FROM Users 
						WHERE Username = 'Stamat')

DECLARE @gameId INT  = (SELECT Id 
                          FROM Games 
						 WHERE [Name] = 'Safflower')

DECLARE @userGameId INT = (SELECT Id 
							 FROM UsersGames 
							WHERE UserId = @userId AND GameId = @gameId)

BEGIN TRY							
BEGIN TRANSACTION
	UPDATE UsersGames
	   SET Cash -= (SELECT SUM(Price) 
    			      FROM Items 
      			     WHERE MinLevel IN (11, 12))
    WHERE Id = @userGameId

	DECLARE @userCash DECIMAL (14, 2) = (SELECT Cash 
										   FROM UsersGames 
										  WHERE Id = @userGameId)

	IF(@userCash < 0)
	BEGIN
		ROLLBACK
	END

	INSERT INTO UserGameItems
	     SELECT Id, @userGameId
	       FROM Items
	      WHERE MinLevel IN (11, 12)
COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

BEGIN TRY
BEGIN TRANSACTION
	UPDATE UsersGames
	   SET Cash -= (SELECT SUM(Price) 
    			      FROM Items 
      			     WHERE MinLevel BETWEEN 19 AND 21)
    WHERE Id = @userGameId

	SET @userCash  = (SELECT Cash 
					    FROM UsersGames 
					   WHERE Id = @userGameId)

	IF(@userCash < 0)
	BEGIN
		ROLLBACK
	END

	INSERT INTO UserGameItems
	     SELECT Id, @userGameId
	       FROM Items
	      WHERE MinLevel BETWEEN 19 AND 21
COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

  SELECT i.[Name]
    FROM Items AS i
    JOIN UserGameItems AS u
      ON u.ItemId = i.Id
   WHERE u.UserGameId = @userGameId
ORDER BY i.[Name]
GO

--21.Employees with Three Projects
CREATE PROCEDURE usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN
	DECLARE @employeeProjectsCount INT = (SELECT COUNT(ProjectID)
										    FROM EmployeesProjects
										   WHERE EmployeeID = @emloyeeId
										GROUP BY EmployeeID)
	IF(@employeeProjectsCount >= 3)
	BEGIN
		RAISERROR('The employee has too many projects!', 16, 1)
		ROLLBACK
	END
	ELSE
	BEGIN
		INSERT INTO EmployeesPRojects
		VALUES
		(@emloyeeId, @projectID)
	END
END
GO

--22.Delete Employees
CREATE TABLE Deleted_Employees(
	EmployeeId INT NOT NULL IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(50),
	JobTitle NVARCHAR(50) NOT NULL,
	DepartmentId INT NOT NULL,
	Salary DECIMAL(14, 2) NOT NULL

	CONSTRAINT PK_Deleted_Employees
	PRIMARY KEY (EmployeeId)

	CONSTRAINT FK_Deleted_Employees_Departments
	FOREIGN KEY (DepartmentId)
	REFERENCES Departments (DepartmentID)
)
GO

CREATE TRIGGER tr_FireEmployee ON Employees AFTER DELETE
AS
BEGIN
	INSERT Deleted_Employees (FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
	SELECT deleted.FirstName, deleted.LastName, deleted.MiddleName, deleted.JobTitle, deleted.DepartmentId, deleted.Salary
	FROM deleted
END
GO