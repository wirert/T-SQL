CREATE DATABASE CarRental;

USE CarRental;

CREATE TABLE Categories 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL, 
		CategoryName VARCHAR(50) NOT NULL, 
		DailyRate SMALLMONEY NOT NULL, 
		WeeklyRate SMALLMONEY NOT NULL, 
		MonthlyRate SMALLMONEY NOT NULL, 
		WeekendRate SMALLMONEY NOT NULL,
	);

CREATE TABLE Cars 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL,  
		PlateNumber VARCHAR(MAX) NOT NULL, 
		Manufacturer VARCHAR(50) NOT NULL, 
		Model VARCHAR(30) NOT NULL, 
		CarYear SMALLINT, 
		CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL, 
		Doors TINYINT, 
		Picture IMAGE, 
		Condition VARCHAR(MAX), 
		Available BIT
	);

CREATE TABLE Employees 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL,  
		FirstName VARCHAR(30) NOT NULL, 
		LastName VARCHAR(30) NOT NULL, 
		Title VARCHAR(100) NOT NULL, 
		Notes VARCHAR(MAX) 
	);

CREATE TABLE Customers 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL,  
		DriverLicenceNumber INT NOT NULL, 
		FullName VARCHAR(150) NOT NULL, 
		[Address] VARCHAR(MAX) NOT NULL, 
		City VARCHAR(20) NOT NULL, 
		ZIPCode SMALLINT, 
		Notes VARCHAR(MAX)
	);

CREATE TABLE RentalOrders 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL,   
		EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
		CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL, 
		CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL,
		TankLevel TINYINT NOT NULL, 
		KilometrageStart INT NOT NULL, 
		KilometrageEnd INT NOT NULL, 
		TotalKilometrage INT NOT NULL, 
		StartDate DATE NOT NULL, 
		EndDate DATE NOT NULL, 
		TotalDays TINYINT NOT NULL, 
		RateApplied SMALLMONEY NOT NULL, 
		TaxRate SMALLMONEY NOT NULL, 
		OrderStatus VARCHAR(30) NOT NULL, 
		Notes VARCHAR(MAX)
	);

INSERT INTO Categories
	VALUES
		('Cheap', 100, 80, 50, 90),
		('Normal', 130, 100, 70, 90),
		('Lux', 200, 180, 150, 190)

INSERT INTO Cars
	VALUES
		('A5555KC', 'LADA', 'NIVA', NULL, 1, 5, NULL, NULL, 1),
		('EA6655OO', 'OPEL', 'SOMEOPEL', NULL, 2, 4, NULL, NULL, 1),
		('CB5555AE', 'LECSUS', 'SKUPMODEL', NULL, 3, 4, NULL, NULL, 0);


INSERT INTO Employees
	VALUES
		('Gosho', 'Goshev', 'Employee 1', NULL),
		('Pesho', 'Poshev', 'Employee 2', NULL),
		('Jo', 'Joev', 'Employee 3', NULL);

INSERT INTO Customers
	VALUES
		(12312434, 'Oncho Onchev', 'Adress 1', 'Asdfd', NULL, NULL),
		(99312434, 'I	DFA', 'Adress 2', 'Grad', NULL, NULL),
		(876112434, 'Geri Gerova', 'Adress 3', 'Ruse', NULL, NULL);

INSERT INTO RentalOrders
	VALUES
		(1, 1, 1, 50, 199, 350, 151100, '2023-01-01', '2023-02-02', 32, 50, 20, 'active', NULL),
		(2, 2, 2, 60, 199, 350, 25100, '2023-01-01', '2023-01-07', 5, 100, 20, 'active', NULL),
		(1, 3, 3, 80, 500, 999, 15600, '2023-01-01', '2023-01-02', 1, 200, 20, 'nonactive', NULL);