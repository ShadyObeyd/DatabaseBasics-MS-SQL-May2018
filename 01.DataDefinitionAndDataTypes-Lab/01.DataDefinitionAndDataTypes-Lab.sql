CREATE TABLE Clients(
 Id INT PRIMARY KEY IDENTITY,
 FirstName NVARCHAR(50) NOT NULL,
 LastName NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE AccountTypes(
 Id INT PRIMARY KEY IDENTITY,
 [Name] NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Accounts(
 Id INT PRIMARY KEY IDENTITY,
 AccountTypeId INT FOREIGN KEY REFERENCES AccountTypes(Id),
 Balance DECIMAL(15, 2) DEFAULT(0),
 ClientId INT FOREIGN KEY REFERENCES Clients(Id)
)
GO

INSERT INTO Clients (FirstName, LastName)
 VALUES
  ('Gosho', 'Ivanov'),
  ('Pesho', 'Petrov'),
  ('Ivan', 'Iliev'),
  ('Merry', 'Ivanova')
GO

INSERT INTO AccountTypes ([Name])
VALUES
('Checkings'),
('Savings')
GO

INSERT INTO Accounts(ClientId, AccountTypeId, Balance)
VALUES
(1, 1, 175),
(2, 1, 275.56),
(3, 1, 138.01),
(4, 1, 40.30),
(4, 2, 375.50)
GO

CREATE FUNCTION f_CalculateTotalBalance(@ClientId INT)
RETURNS DECIMAL (15, 2)
BEGIN
 DECLARE @result AS DECIMAL (15, 2) = (
   SELECT SUM(Balance)
   FROM Accounts WHERE ClientId = @ClientId
 )
 RETURN @result
END
GO

SELECT dbo.f_CalculateTotalBalance(4) AS Balance
GO

CREATE PROC p_AddAccount @ClientId INT, @AccountTypeId INT AS 
INSERT INTO Accounts(ClientId, AccountTypeId)
VALUES
(@ClientId, @AccountTypeId)
GO

p_AddAccount 2, 2
GO

SELECT * FROM Accounts
GO

CREATE PROC p_Deposit @AccountId INT, @Amount DECIMAL(15, 2) AS
UPDATE Accounts
SET Balance += @Amount
WHERE Id = @AccountId
GO

p_Deposit 6, 150.32
GO

CREATE PROC p_Withdraw @AccountId INT, @Ammount DECIMAL(15, 2) AS
BEGIN
 DECLARE @OldBalance DECIMAL(15, 2)
 SELECT @OldBalance = Balance FROM Accounts WHERE Id = @AccountId
 IF(@OldBalance - @Ammount >= 0)
 BEGIN
  UPDATE Accounts
  SET Balance -= @Ammount
  WHERE Id = @AccountId
 END
 ELSE
 BEGIN
  RAISERROR('Insufficient funds',10,1 )
 END
END
GO

p_Withdraw 6, 150.32
GO

CREATE TABLE Transactions(
 Id INT PRIMARY KEY IDENTITY,
 AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
 OldBalance DECIMAL(15, 2) NOT NULL,
 NewBalance DECIMAL (15, 2) NOT NULL,
 Amount AS NewBalance - OldBalance,
 [DateTime] DATETIME2
)
GO

CREATE TRIGGER tr_Transaction ON Accounts
AFTER UPDATE
AS
  INSERT INTO Transactions (AccountId, OldBalance, NewBalance, [DateTime])
  SELECT inserted.Id, deleted.Balance, inserted.Balance, GETDATE() FROM inserted
  JOIN deleted ON inserted.Id = deleted.Id
GO

p_Deposit 1, 25.00
GO

p_Deposit 1, 40.00
GO

p_Withdraw 2, 200.00
GO

p_Deposit 4, 180.00
GO

SELECT * FROM Transactions