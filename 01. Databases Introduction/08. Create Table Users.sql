CREATE TABLE Users
(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX) CHECK(ProfilePicture <= 900000),
	LastLoginTime DATETIME2,
	IsDeleted VARCHAR(5) CHECK (IsDeleted = 'true' OR IsDeleted = 'false')
);

INSERT INTO Users
	VALUES
		('User 1', 'pass1', NULL, NULL, 'false'),
		('User 2', 'pass2', NULL, NULL, NULL),
		('User 3', 'pass3', NULL, NULL, 'true'),
		('User 4', 'pass4', NULL, NULL, 'false'),
		('User 5', 'pass6', NULL, NULL, 'true')