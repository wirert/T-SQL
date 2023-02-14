CREATE DATABASE Movies;

USE Movies;

-- In Judge should paste without above to pass

CREATE TABLE Directors 
(
	Id INT PRIMARY KEY IDENTITY NOT NULL
	,DirectorName NVARCHAR(200) NOT NULL
	,Notes NVARCHAR(MAX)
);

INSERT INTO Directors
	VALUES
		('Greenaway', NULL),
		('Judorowski', NULL),
		('Ethan Coen', NULL),
		('Тарковки', NULL),
		('Wim Wenders', NULL);


CREATE TABLE Genres 
(
	Id INT PRIMARY KEY IDENTITY NOT NULL
	,GenreName NVARCHAR(100) NOT NULL
	,Notes NVARCHAR(MAX)
);

INSERT INTO Genres
	VALUES
		('Drama', NULL),
		('Comedy', NULL),
		('Fantasy', NULL),
		('Documentary', NULL),
		('Action', NULL);

CREATE TABLE Categories 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL
		,CategoryName NVARCHAR(100) NOT NULL
		,Notes NVARCHAR(MAX)
	);

INSERT INTO Categories
	VALUES
		('Category 1', NULL),
		('Category 2', NULL),
		('Category 3', NULL),
		('Category 4', NULL),
		('Category 5', NULL);

CREATE TABLE Movies 
	(
		Id INT PRIMARY KEY IDENTITY NOT NULL
		,Title NVARCHAR(200) NOT NULL
		,DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL
		,CopyrightYear SMALLINT
		,[Length] TIME
		,GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL
		,CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL
		,Rating FLOAT
		,Notes NVARCHAR(MAX)
	);

INSERT INTO Movies
	VALUES
		('Z and two O', 1, NULL, NULL, 1, 1, 9.00, NULL),
		('Santa Sangre', 2, 1989, '02:03', 1, 3, 8.99, NULL),
		('The Salt of the Earth', 5, 2014, NULL, 4, 1, 9.44, NULL),
		('Зеркало', 4, NULL, NULL, 1, 1, 9.67, NULL),
		('Hail, Caesar!', 3, 2016, NULL, 1, 1, 6.30, NULL);