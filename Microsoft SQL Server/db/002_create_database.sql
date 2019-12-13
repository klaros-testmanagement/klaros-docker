if not exists(SELECT 1 FROM sys.databases WHERE name = N'@@DATABASE_NAME@@')
begin
	CREATE DATABASE [@@DATABASE_NAME@@] Collate SQL_Latin1_General_CP1_CI_AS
	ALTER DATABASE [@@DATABASE_NAME@@] MODIFY FILE (NAME = '@@DATABASE_NAME@@', SIZE = 500 MB, FILEGROWTH = 10%)
	ALTER DATABASE [@@DATABASE_NAME@@] MODIFY FILE (NAME = '@@DATABASE_NAME@@_log', SIZE = 500 MB, FILEGROWTH = 10%)
	ALTER DATABASE [@@DATABASE_NAME@@] SET AUTO_SHRINK OFF WITH NO_WAIT
	ALTER DATABASE [@@DATABASE_NAME@@] SET AUTO_CREATE_STATISTICS ON WITH NO_WAIT
	ALTER DATABASE [@@DATABASE_NAME@@] SET AUTO_UPDATE_STATISTICS ON WITH NO_WAIT
	ALTER DATABASE [@@DATABASE_NAME@@] SET AUTO_UPDATE_STATISTICS_ASYNC OFF WITH NO_WAIT
	ALTER DATABASE [@@DATABASE_NAME@@] SET RECOVERY SIMPLE
	ALTER DATABASE [@@DATABASE_NAME@@] SET COMPATIBILITY_LEVEL = 130
end
GO