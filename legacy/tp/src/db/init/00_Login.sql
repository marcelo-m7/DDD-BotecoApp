USE master;
GO

CREATE LOGIN boteco_user WITH PASSWORD = 'SenhaForte123!';
GO

USE Boteco_PRO;
GO

CREATE USER boteco_user FOR LOGIN boteco_user;
EXEC sp_addrolemember 'db_owner', 'boteco_user';
GO
