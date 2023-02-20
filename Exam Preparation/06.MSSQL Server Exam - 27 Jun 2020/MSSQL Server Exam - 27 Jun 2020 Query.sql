CREATE DATABASE WMS
GO 
USE WMS
GO

--01. DDL
CREATE TABLE Clients
	  (
		ClientId INT PRIMARY KEY IDENTITY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL,
		Phone CHAR(12) NOT NULL 
	CHECK (LEN(Phone) = 12)
	  )

CREATE TABLE Mechanics
	(
		MechanicId INT PRIMARY KEY IDENTITY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL,
		Address VARCHAR(255) NOT NULL
	)

CREATE TABLE Models
	(
		ModelId INT PRIMARY KEY IDENTITY,
		Name VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Jobs
	(
		JobId INT PRIMARY KEY IDENTITY,
		ModelId INT NOT NULL FOREIGN KEY REFERENCES Models(ModelId),
		Status VARCHAR(11) NOT NULL DEFAULT 'Pending' 
    CHECK (Status IN ('Pending', 'In Progress', 'Finished')),
		ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(ClientId),
		MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
		IssueDate DATE NOT NULL,
		FinishDate DATE
	)

CREATE TABLE Orders
	(
		OrderId INT PRIMARY KEY IDENTITY,
		JobId INT NOT NULL FOREIGN KEY REFERENCES Jobs(JobId),
		IssueDate DATE,
		Delivered BIT NOT NULL DEFAULT 0
	)

CREATE TABLE Vendors
	(
		VendorId INT PRIMARY KEY IDENTITY,
		Name VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Parts
	(
		PartId INT PRIMARY KEY IDENTITY,
		SerialNumber VARCHAR(50) UNIQUE NOT NULL,
		Description VARCHAR(255),
		Price DECIMAL(6,2) NOT NULL 
	CHECK (Price > 0 AND Price <= 9999.99),
		VendorId INT NOT NULL FOREIGN KEY REFERENCES Vendors(VendorId),
		StockQty INT NOT NULL DEFAULT 0 
	CHECK (StockQty >= 0)
	)

CREATE TABLE OrderParts
	(
		OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
		PartId INT FOREIGN KEY REFERENCES Parts(PartId),
		Quantity INT NOT NULL DEFAULT 1 
	CHECK (Quantity > 0),
		PRIMARY KEY (OrderId, PartId)
	)

CREATE TABLE PartsNeeded
	(
		JobId INT FOREIGN KEY REFERENCES Jobs(JobId),
		PartId INT FOREIGN KEY REFERENCES Parts(PartId),
		Quantity INT NOT NULL DEFAULT 1 
	CHECK (Quantity > 0),
		PRIMARY KEY (JobId, PartId)
	)

--02. Insert
INSERT INTO Clients
	 VALUES
		('Teri', 'Ennaco','570-889-5187'),
		('Merlyn', 'Lawler','201-588-7810'),
		('Georgene', 'Montezuma','925-615-5185'),
		('Jettie', 'Mconnell','908-802-3564'),
		('Lemuel', 'Latzke','631-748-6479'),
		('Melodie', 'Knipp','805-690-1682'),
		('Candida', 'Corbley','908-275-8357')

INSERT INTO Parts (SerialNumber, Description, Price, VendorId)
	 VALUES
		('WP8182119', 'Door Boot Seal', 117.86, 2),
		('W10780048', 'Suspension Rod', 42.81, 1),
		('W10841140', 'Silicone Adhesive', 6.77, 4),
		('WPY055980', 'High Temperature Adhesive', 13.94, 3)

--03. Update
UPDATE Jobs
   SET MechanicId = 3
 WHERE Status = 'Pending'

UPDATE Jobs
   SET Status = 'In Progress'
 WHERE Status = 'Pending'

--04. Delete
DELETE FROM OrderParts
	  WHERE OrderId = 19

DELETE FROM Orders
	  WHERE OrderId = 19

--05. Mechanic Assignments
  SELECT CONCAT(FirstName, ' ', LastName)
	  AS Mechanic,
	     j.Status,
		 j.IssueDate
	FROM Mechanics AS m
	JOIN Jobs AS j ON j.MechanicId = m.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

--06. Current Clients 
  SELECT CONCAT(FirstName, ' ', LastName)
	  AS Client,
		 DATEDIFF(DAY, j.IssueDate, '2017-04-24')
	  AS [Days going],
		 j.Status
	FROM Clients AS c
	JOIN Jobs AS j ON c.ClientId = j.ClientId
   WHERE j.Status <> 'Finished'
ORDER BY [Days going] DESC, c.ClientId

--07. Mechanic Performance
  SELECT CONCAT(FirstName, ' ', LastName)
	  AS Mechanic,
	     AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate))
	  AS [Average Days]
	FROM Mechanics AS m
	JOIN Jobs AS j ON m.MechanicId = j.MechanicId
   WHERE j.IssueDate IS NOT NULL
GROUP BY FirstName, LastName, m.MechanicId
ORDER BY m.MechanicId

--08. Available Mechanics
   SELECT CONCAT(FirstName, ' ', LastName)
	   AS Available
	 FROM Mechanics AS m
LEFT JOIN Jobs AS j ON j.MechanicId = m.MechanicId
	WHERE j.JobId IS NULL OR j.FinishDate IS NOT NULL
 GROUP BY FirstName, LastName, m.MechanicId
 ORDER BY m.MechanicId

--09. Past Expenses
   SELECT j.JobId,
		  ISNULL(SUM(p.Price * op.Quantity), 0) 
	   AS Total
	 FROM Jobs AS j
LEFT JOIN Orders AS o ON o.JobId = j.JobId
LEFT JOIN OrderParts AS op ON op.OrderId = o.OrderId
LEFT JOIN Parts AS p ON p.PartId = op.PartId
    WHERE j.FinishDate IS NOT NULL
 GROUP BY j.JobId
 ORDER BY Total DESC, JobId

--10. Missing Parts
   SELECT p.PartId, 
	      p.Description,
		  SUM(pn.Quantity) AS Required,
		  SUM(p.StockQty) AS [In Stock],
		  ISNULL(SUM(oop.Quantity), 0) AS Ordered
	 FROM PartsNeeded AS pn
	 JOIN Parts AS p ON p.PartId = pn.PartId
	 JOIN Jobs AS j ON j.JobId = pn.JobId
LEFT JOIN (SELECT PartId,
				  Quantity
			 FROM OrderParts AS op 
			 JOIN Orders AS o ON o.OrderId = op.OrderId
			WHERE o.Delivered = 0)
	  AS oop ON oop.PartId = p.PartId
   WHERE Status <> 'Finished'
GROUP BY p.PartId, p.Description
  HAVING SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(oop.Quantity), 0)
ORDER BY PartId
GO

--11. Place Order
CREATE PROC usp_PlaceOrder 
	@jobId INT, 
	@partSN VARCHAR(50), 
	@quantity INT
AS
BEGIN	
	IF @jobId IN (SELECT JobId FROM Jobs WHERE Status = 'Finished')
		THROW 50011, 'This job is not active!', 1;
	IF @quantity <= 0
		THROW 50012, 'Part quantity must be more than zero!', 1;
	IF @jobId NOT IN (SELECT JobId FROM Jobs)
		THROW 50013, 'Job not found!', 1;
	IF @partSN NOT IN (SELECT SerialNumber FROM Parts)
		THROW 50014, 'Part not found!', 1;
	
	DECLARE @partId INT = (SELECT TOP 1 PartId FROM Parts WHERE SerialNumber = @partSN)

	IF @jobId NOT IN (SELECT JobId FROM Orders WHERE IssueDate IS NULL)
		BEGIN
			INSERT INTO Orders
				 VALUES (@jobId, NULL, 0)
			INSERT INTO OrderParts
				 VALUES ((SELECT TOP 1 OrderId FROM Orders WHERE JobId = @jobId),@partId, @quantity)
			RETURN
		END

	DECLARE @orderId INT = (SELECT TOP 1 OrderId FROM Orders WHERE JobId = @jobId)

	IF (SELECT TOP 1 IssueDate FROM Orders WHERE JobId = @jobId) IS NULL
		BEGIN
		IF @partId IN (SELECT PartId FROM OrderParts WHERE OrderId = @orderId)
			BEGIN
				UPDATE OrderParts
				   SET Quantity += @quantity
				 WHERE (SELECT TOP 1 PartId FROM OrderParts WHERE OrderId = @orderId) = @partId

				RETURN
			END

		INSERT INTO OrderParts
				 VALUES (@orderId, @partId, @quantity)
			RETURN
		END	
END
GO

--12. Cost of Order
CREATE FUNCTION udf_GetCost(@jobId INT)
RETURNS DECIMAL(8,2) AS
BEGIN
	RETURN ISNULL((SELECT SUM(p.Price * op.Quantity)
				     FROM Orders AS o
				     JOIN OrderParts AS op ON o.OrderId = op.OrderId
				     JOIN Parts AS p ON op.PartId = p.PartId	
				    WHERE JobId = @jobId		 
				  ), 0)
END