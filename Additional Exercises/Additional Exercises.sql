--1. Number of Users for Email Provider 
  SELECT [Email Provider]
		,COUNT(*)
	  AS [Number Of Users]
    FROM(
		  SELECT * 
				,SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email))
			  AS [Email Provider]
			FROM Users
		)
	  AS EmailProviderSubquery
GROUP BY [Email Provider]
ORDER BY [Number Of Users] DESC,
		 [Email Provider]

--02. All Users in Games
  SELECT g.[Name] AS Game
		,gt.[Name] AS [Game Type]
		,u.Username
		,ug.[Level]
		,ug.Cash
		,c.[Name] AS [Character]
	FROM Games AS g
	JOIN UsersGames AS ug
	  ON g.Id = ug.GameId
	JOIN Users AS u
	  ON u.Id = ug.UserId
	JOIN GameTypes AS gt
	  ON gt.Id = g.GameTypeId
	JOIN Characters AS c
	  ON c.Id = ug.CharacterId
ORDER BY [Level] DESC, Username, Game

--03. Users in Games with Their Items 
  SELECT u.Username
		,g.Name AS Game
		,COUNT(i.Id) AS [Items Count]
		,SUM(i.Price) AS [Items Price]
	FROM Users AS u
	JOIN UsersGames AS ug ON u.Id = ug.UserId
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN UserGameItems AS ugi ON ug.Id = ugi.UserGameId
	JOIN Items AS i ON i.Id = ugi.ItemId
GROUP BY u.Username, g.Name
  HAVING COUNT(i.Id) >= 10
ORDER BY [Items Count] DESC, [Items Price] DESC, Username

--04. *User in Games with Their Statistics
  SELECT u.Username
		,g.[Name] 
	  AS Game
		,MAX(c.Name) 
	  AS [Character]
		,SUM(si.Strength) + MAX(sgt.Strength) + MAX(sc.Strength) 
	  AS Strength
	    ,SUM(si.Defence) + MAX(sgt.Defence) + MAX(sc.Defence) 
	  AS Defence
	    ,SUM(si.Speed) + MAX(sgt.Speed) + MAX(sc.Speed) 
	  AS Speed
	    ,SUM(si.Mind) + MAX(sgt.Mind) + MAX(sc.Mind) 
	  AS Mind
	    ,SUM(si.Luck) + MAX(sgt.Luck) + MAX(sc.Luck) 
	  AS Luck
	FROM UsersGames AS ug
	JOIN Users AS u ON u.Id = ug.UserId
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN Characters AS c ON c.Id = ug.CharacterId
	JOIN [Statistics] AS sc ON sc.Id = c.StatisticId
	JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
	JOIN [Statistics] AS sgt ON gt.BonusStatsId = sgt.Id
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
	JOIN [Statistics] AS si ON i.StatisticId = si.Id
GROUP BY u.Username, g.Name
ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC

--05. All Items with Greater than Average Statistics
  SELECT i.Name
		,i.Price
		,i.MinLevel
		,s.Strength
		,s.Defence
		,s.Speed
		,s.Luck
		,s.Mind		
	FROM Items AS i
	JOIN [Statistics] AS s ON i.StatisticId = s.Id
   WHERE Speed >(SELECT AVG(Speed) 
				   FROM [Statistics])
	 AND Luck > (SELECT AVG(Luck) 
				   FROM [Statistics])
	 AND Mind > (SELECT AVG(Mind) 
				   FROM [Statistics])
ORDER BY [Name]

--06. Display All Items about Forbidden Game Type 
   SELECT i.[Name] 
	   AS Item
		 ,i.Price
		 ,i.MinLevel
		 ,gt.[Name]
	   AS [Forbidden Game Type]
	 FROM Items AS i
LEFT JOIN GameTypeForbiddenItems AS gtfi ON gtfi.ItemId = i.Id
LEFT JOIN GameTypes AS gt ON gt.Id = gtfi.GameTypeId
 ORDER BY [Forbidden Game Type] DESC, Item

--07. Buy Items for User in Game
DECLARE @user_Id INT = (SELECT Id FROM Users WHERE Username = 'Alex')
DECLARE @game_Id INT = (SELECT Id FROM Games WHERE Name = 'Edinburgh')
DECLARE @userGame_Id INT = (SELECT Id FROM UsersGames WHERE UserId = @user_Id AND GameId = @game_Id)

DECLARE @item1_Id INT = (SELECT Id FROM Items WHERE Name = 'Blackguard')
DECLARE @item2_Id INT = (SELECT Id FROM Items WHERE Name = 'Bottomless Potion of Amplification')
DECLARE @item3_Id INT = (SELECT Id FROM Items WHERE Name = 'Eye of Etlich (Diablo III)')
DECLARE @item4_Id INT = (SELECT Id FROM Items WHERE Name = 'Gem of Efficacious Toxin')
DECLARE @item5_Id INT = (SELECT Id FROM Items WHERE Name = 'Golden Gorget of Leoric')
DECLARE @item6_Id INT = (SELECT Id FROM Items WHERE Name = 'Hellfire Amulet')

DECLARE @totalCost MONEY = ( 
							SELECT SUM(Price) 
							  FROM Items 
							 WHERE Id IN (@item1_Id, @item2_Id, @item3_Id, @item4_Id, @item5_Id, @item6_Id)
						   )
UPDATE UsersGames
   SET Cash -= @totalCost
 WHERE Id = @userGame_Id

INSERT INTO UserGameItems
	 VALUES (@item1_Id, @userGame_Id),
			(@item2_Id, @userGame_Id),
			(@item3_Id, @userGame_Id),
			(@item4_Id, @userGame_Id),
			(@item5_Id, @userGame_Id),
			(@item6_Id, @userGame_Id)

  SELECT Username
		,g.Name
		,ug.Cash
		,i.Name AS [Item Name]
	FROM UsersGames AS ug
	JOIN Users AS u ON ug.UserId = u.Id
	JOIN Games AS g ON ug.GameId = g.Id
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
   WHERE g.Id = @game_Id
ORDER BY [Item Name]

GO
USE Geography
GO

--08. Peaks and Mountains
  SELECT p.PeakName
		,m.MountainRange AS Mountain
		,p.Elevation
	FROM Peaks AS p
	JOIN Mountains AS m ON p.MountainId = m.Id
ORDER BY p.Elevation DESC, p.PeakName

--09. Peaks with Mountain, Country and Continent
  SELECT p.PeakName
		,m.MountainRange AS Mountain
		,c.CountryName
		,ct.ContinentName
	FROM Peaks AS p
	JOIN Mountains AS m ON p.MountainId = m.Id
	JOIN MountainsCountries AS mc ON mc.MountainId = m.Id
	JOIN Countries AS c ON c.CountryCode = mc.CountryCode
	JOIN Continents AS ct ON ct.ContinentCode = c.ContinentCode
ORDER BY PeakName, CountryName

--10. Rivers by Country
   SELECT c.CountryName
		 ,ct.ContinentName
		 ,COUNT(r.Id) AS RiversCount
		 ,ISNULL(SUM(r.Length), 0) AS TotalLength
	 FROM Countries AS c
	 JOIN Continents AS ct ON c.ContinentCode = ct.ContinentCode
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
 GROUP BY c.CountryName,ct.ContinentName
 ORDER BY RiversCount DESC, TotalLength DESC, CountryName

--11. Count of Countries by Currency
    SELECT cr.CurrencyCode
  		  ,cr.[Description] AS Currency
  		  ,COUNT(c.CountryCode) AS NumberOfCountries
	  FROM Countries AS c
RIGHT JOIN Currencies AS cr ON cr.CurrencyCode = c.CurrencyCode
  GROUP BY cr.CurrencyCode, cr.[Description]
  ORDER BY NumberOfCountries DESC, [Description]

--12. Population and Area by Continent
   SELECT co.ContinentName
		 ,SUM(CAST(c.AreaInSqKm AS BIGINT)) AS CountriesArea
	  	 ,SUM(CAST(c.Population AS BIGINT)) AS CountriesPopulation
	 FROM Continents AS co
LEFT JOIN Countries AS c ON co.ContinentCode = c.ContinentCode
 GROUP BY co.ContinentName
 ORDER BY CountriesPopulation DESC

--13. Monasteries by Country
GO
CREATE TABLE Monasteries
			(
			 Id INT PRIMARY KEY IDENTITY, 
			 Name VARCHAR(100) NOT NULL, 
			 CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode) NOT NULL
			)
GO

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

ALTER TABLE Countries
		ADD IsDeleted BIT DEFAULT 0 NOT NULL

 UPDATE Countries
	SET IsDeleted = 1
  WHERE CountryCode IN (
					  SELECT c.CountryCode 
						FROM CountriesRivers AS cr
						JOIN Countries AS c ON c.CountryCode = cr.CountryCode
						JOIN Rivers AS r ON r.Id = cr.RiverId
					GROUP BY c.CountryCode
					 HAVING COUNT(r.Id) > 3
					   )

  SELECT m.[Name] AS Monastery
		,c.CountryName AS Country
	FROM Monasteries AS m
	JOIN Countries AS c ON m.CountryCode = c.CountryCode
   WHERE c.IsDeleted = 0
ORDER BY m.[Name]

--14. Monasteries by Continents and Countries
UPDATE Countries
   SET CountryName = 'Burma'
 WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries
	 VALUES ('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania'))

INSERT INTO Monasteries
	 VALUES ('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

   SELECT ct.ContinentName
		 ,c.CountryName
		 ,COUNT(m.CountryCode) AS MonasteriesCount		 
	 FROM Countries AS c
LEFT JOIN Continents AS ct ON ct.ContinentCode = c.ContinentCode
LEFT JOIN Monasteries AS m ON c.CountryCode = m.CountryCode  
    WHERE c.IsDeleted = 0
 GROUP BY ct.ContinentName, c.CountryName
 ORDER BY MonasteriesCount DESC, c.CountryName
