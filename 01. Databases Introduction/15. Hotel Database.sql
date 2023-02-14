CREATE DATABASE Hotel;
USE Hotel;

CREATE TABLE Employees 
	(
		Id SMALLINT PRIMARY KEY IDENTITY NOT NULL, 
		FirstName VARCHAR(30) NOT NULL, 
		LastName VARCHAR(30) NOT NULL,
		Title VARCHAR(30) NOT NULL, 
		Notes VARCHAR(MAX)
	);

INSERT INTO Employees
	VALUES
		('Pesho', 'Peshev', 'Porter', NULL),
		('Penka', 'Pesheva', 'chambermaid', NULL),
		('Stanka', 'Gosheva', 'Manager', NULL);

CREATE TABLE Customers 
	(
		AccountNumber INT PRIMARY KEY IDENTITY NOT NULL, 
		FirstName VARCHAR(30) NOT NULL, 
		LastName VARCHAR(30) NOT NULL,
		PhoneNumber VARCHAR(20) NOT NULL, 
		EmergencyName VARCHAR(30), 
		EmergencyNumber INT, 
		Notes VARCHAR(MAX)
	);

INSERT INTO Customers
	VALUES
		('SDF', 'Dadfv', '+001/0989979', NULL,NULL,NULL),
		('Asen', 'Dadev', '001/555599794', NULL,NULL,NULL),
		('Sasho', 'Punchev', '09899795664', NULL,NULL,NULL);

CREATE TABLE RoomStatus 
	(
		RoomStatus VARCHAR(20) PRIMARY KEY NOT NULL, 
		Notes VARCHAR(1500)
	);

INSERT INTO RoomStatus
	VALUES
		('Free', NULL),
		('Occupied', NULL),
		('Unknown', NULL);

CREATE TABLE RoomTypes 
	(
		RoomType VARCHAR(20) PRIMARY KEY NOT NULL, 
		Notes VARCHAR(1500)
	);

INSERT INTO RoomTypes
	VALUES
		('Single', NULL),
		('Double', NULL),
		('Appartment', NULL);

CREATE TABLE BedTypes 
	(
		BedType VARCHAR(20) PRIMARY KEY NOT NULL, 
		Notes VARCHAR(1500)
	);

INSERT INTO BedTypes
	VALUES
		('Small', NULL),
		('Big', NULL),
		('Child', NULL);

CREATE TABLE Rooms 
	(
		RoomNumber SMALLINT PRIMARY KEY IDENTITY NOT NULL, 
		RoomType VARCHAR(20) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL, 
		BedType VARCHAR(20) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL, 
		Rate SMALLMONEY NOT NULL, 
		RoomStatus VARCHAR(20) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL, 
		Notes VARCHAR(1500)
	);

INSERT INTO Rooms
	VALUES
		('Single', 'Big', 100, 'Free', NULL ),
		('Double', 'Small', 180, 'Occupied', NULL ),
		('Appartment', 'Big', 300, 'Free', NULL );

CREATE TABLE Payments 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL, 
		EmployeeId SMALLINT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
		PaymentDate DATE NOT NULL, 
		AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL, 
		FirstDateOccupied DATE NOT NULL, 
		LastDateOccupied DATE NOT NULL, 
		TotalDays TINYINT NOT NULL,
		AmountCharged SMALLMONEY NOT NULL, 
		TaxRate SMALLMONEY NOT NULL, 
		TaxAmount SMALLMONEY NOT NULL,
		PaymentTotal SMALLMONEY NOT NULL,  
		Notes VARCHAR(1500)
	);

INSERT INTO Payments
	VALUES
		(1, '2023-01-30', 1, '2023-01-29', '2023-01-30', 2, 50, 20, 10, 60, NULL),
		(2, '2023-01-30', 1, '2023-01-28', '2023-01-30', 3, 150, 20, 30, 180, NULL),
		(1, '2023-01-25', 1, '2023-01-20', '2023-01-25', 5, 500, 20, 100, 600, NULL);

CREATE TABLE Occupancies 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL,  
		EmployeeId SMALLINT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
		DateOccupied DATE NOT NULL, 
		AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
		RoomNumber SMALLINT FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL, 
		RateApplied SMALLMONEY NOT NULL, 
		PhoneCharge SMALLMONEY NOT NULL, 
		Notes VARCHAR(1500)
	);

INSERT INTO Occupancies
	VALUES
		(1, '2023-01-22', 1, 3, 50, 5, NULL),
		(2, '2023-01-27', 3, 1, 150, 1.44, NULL),
		(3, '2023-01-15', 2, 2, 50, 5, NULL);
