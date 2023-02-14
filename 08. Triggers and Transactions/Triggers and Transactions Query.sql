--01. Create Table Logs
CREATE TABLE Logs 
	(	
		LogId INT PRIMARY KEY IDENTITY, 
		AccountId INT NOT NULL, 
		OldSum MONEY NOT NULL, 
		NewSum MONEY NOT NULL
	) 
GO

CREATE TRIGGER tr_addlogwhenupdateaccaunt
ON Accounts FOR UPDATE
AS
BEGIN
	INSERT INTO Logs
		 SELECT i.Id,
				d.Balance,
				i.Balance
		   FROM inserted AS i
		   JOIN deleted AS d ON i.Id = d.Id
		  WHERE i.Balance <> d.Balance
END
GO

--02. Create Table Emails
CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY, 
	Recipient INT NOT NULL, 
	Subject VARCHAR(50) NOT NULL, 
	Body VARCHAR(200) NOT NULL
)
GO

CREATE TRIGGER tr_addemailwhenlog
ON Logs FOR INSERT
AS
BEGIN
	INSERT INTO NotificationEmails
		 SELECT AccountId,
				CONCAT('Balance change for account: ', AccountId),
				CONCAT('On ', GETDATE(), ' your balance was changed from ', OldSum, ' to ', NewSum, '.')
		   FROM inserted
END
GO

--03. Deposit Money
CREATE PROC usp_DepositMoney 
 @accountId INT, @moneyAmount MONEY
AS
BEGIN
	UPDATE Accounts
	   SET Balance += @moneyAmount
	 WHERE Id = @accountId AND @moneyAmount > 0
END
GO

--04. Withdraw Money Procedure
CREATE PROC usp_WithdrawMoney
 @AccountId INT, @MoneyAmount MONEY
AS
BEGIN
	UPDATE Accounts
	   SET Balance -= @moneyAmount
	 WHERE Id = @AccountId AND @MoneyAmount > 0 AND Balance >= @MoneyAmount
END
GO

--05. Money Transfer
CREATE OR ALTER PROC usp_TransferMoney
 @SenderId INT, @ReceiverId INT, @Amount MONEY
AS
BEGIN TRANSACTION
	DECLARE @count INT
	EXEC usp_WithdrawMoney @SenderId, @Amount;
	SET @count = @@ROWCOUNT
	EXEC usp_DepositMoney @ReceiverId, @Amount;
	SET @count += @@ROWCOUNT

	IF @@ROWCOUNT <> 2
	BEGIN
	 ROLLBACK
	 RETURN
	END
COMMIT
GO

USE
Diablo
GO
--06. *Massive Shopping


USE
SoftUni
GO
--07. Employees with Three Projects
CREATE PROC usp_AssignProject
 @emloyeeId INT, @projectID INT
AS
BEGIN
 BEGIN TRANSACTION
  INSERT INTO EmployeesProjects
	   VALUES (@emloyeeId, @projectID)

  DECLARE @numProjects INT = (SELECT COUNT(*) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId);
  IF @numProjects > 3
	BEGIN
		ROLLBACK
		RAISERROR('The employee has too many projects!', 16, 1);
		RETURN
	END
 COMMIT
END

GO
--09. Delete Employees
CREATE TABLE Deleted_Employees
 (
	EmployeeId INT PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50),
	JobTitle VARCHAR(50) NOT NULL,
	DepartmentId INT NOT NULL,
	Salary MONEY NOT NULL
 )
GO

CREATE TRIGGER tr_AddEmployeeToTableWhenDelete
ON [Employees] FOR DELETE
AS
INSERT INTO [Deleted_Employees]
	 SELECT 
			[FirstName],
			[LastName],
			[MiddleName],
			[JobTitle],
			[DepartmentID],
			[Salary]
	   FROM [deleted]
GO
