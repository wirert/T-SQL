CREATE TABLE [People] 
(
	Id		BIGINT PRIMARY KEY IDENTITY NOT NULL,
	[Name]	NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX) CHECK(Picture <= 2000000),
	Height	REAL,
	[Weight] REAL,
	Gender	CHAR(1) CHECK (Gender = 'm' OR Gender = 'f') NOT NULL,
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
);

INSERT INTO [People] VALUES 
	('Pesho', NULL, 172.444, 80.2345, 'm', '1999/12/31', NULL)
	,('Pesho1', NULL, 170, 80.2345, 'm', '1977-12-31', NULL)
	,('Гошо', NULL, 180, NULL, 'm', '2003-12-31',NULL)
	,('Pesho3', NULL, NULL, NULL, 'm', '1988-12-31',NULL)
	,('Penka', NULL, NULL, NULL, 'f', '1966-12-31',NULL)