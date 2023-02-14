BACKUP DATABASE SoftUni
		TO DISK = 'D:\Backup\softuni-backup.bak'

GO;

USE [master];

GO;

DROP DATABASE SoftUni

GO;

RESTORE DATABASE SoftUni
	   FROM DISK = 'D:\Backup\softuni-backup.bak'