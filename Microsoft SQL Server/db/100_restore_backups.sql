/*

Skript zum automatischen wiederherstellen von Datenbankbackups.
Es werden alle *.bak Dateien aus dem Backupordner ausgelesen und verarbeitet.

ACHTUNG: Die Spalten für FileListOnlyColumns und FileHeaderColumns sind SQL Server spezifisch und
müssen ggf. angepasst werden.

 */

declare @BackupFolder nvarchar(255)
declare @BackupFile nvarchar(255)
declare @PathSeparator varchar(1)
declare @HasMemTables bit = 0
declare @SQL nvarchar(max)
declare @DatabaseName nvarchar(128)
declare @DataName nvarchar(128)
declare @LogName nvarchar(128)
declare @MemName nvarchar(128)
declare @InstanceDefaultDataPath nvarchar(266)
declare @InstanceDefaultLogPath nvarchar(266)

-- https://docs.microsoft.com/en-us/sql/t-sql/statements/restore-statements-filelistonly-transact-sql?view=sql-server-2017
-- First Column is missing here because we do the trick by creating the temp table in other context
declare @FileListOnlyColumns varchar(max) = '
PhysicalName    nvarchar(260),
Type    char(1),
FileGroupName   nvarchar(128),
Size    numeric(20,0),
MaxSize     numeric(20,0),
FileID  bigint,
CreateLSN   numeric(25,0),
DropLSN     numeric(25,0),
UniqueID    uniqueidentifier,
ReadOnlyLSN     numeric(25,0),
ReadWriteLSN    numeric(25,0),
BackupSizeInBytes   bigint,
SourceBlockSize     int,
FileGroupID     int,
LogGroupGUID    uniqueidentifier,
DifferentialBaseLSN     numeric(25,0),
DifferentialBaseGUID    uniqueidentifier,
IsReadOnly  bit,
IsPresent   bit,
TDEThumbprint   varbinary(32),
SnapshotURL     nvarchar(360)'

-- https://docs.microsoft.com/en-us/sql/t-sql/statements/restore-statements-headeronly-transact-sql?view=sql-server-2017
-- First Column is missing here because we do the trick by creating the temp table in other context
declare @FileHeaderColumns varchar(max) = 'BackupDescription    nvarchar(255),
BackupType  smallint,
ExpirationDate  datetime,
Compressed  bit,
Position    smallint,
DeviceType  tinyint,
UserName    nvarchar(128),
ServerName  nvarchar(128),
DatabaseName    nvarchar(128),
DatabaseVersion     int,
DatabaseCreationDate    datetime,
BackupSize  numeric(20,0),
FirstLSN    numeric(25,0),
LastLSN     numeric(25,0),
CheckpointLSN   numeric(25,0),
DatabaseBackupLSN   numeric(25,0),
BackupStartDate     datetime,
BackupFinishDate    datetime,
SortOrder   smallint,
CodePage    smallint,
UnicodeLocaleId     int,
UnicodeComparisonStyle  int,
CompatibilityLevel  tinyint,
SoftwareVendorId    int,
SoftwareVersionMajor    int,
SoftwareVersionMinor    int,
SoftwareVersionBuild    int,
MachineName     nvarchar(128),
Flags   int,
BindingID   uniqueidentifier,
RecoveryForkID  uniqueidentifier,
Collation   nvarchar(128),
FamilyGUID  uniqueidentifier,
HasBulkLoggedData   bit,
IsSnapshot  bit,
IsReadOnly  bit,
IsSingleUser    bit,
HasBackupChecksums  bit,
IsDamaged   bit,
BeginsLogChain  bit,
HasIncompleteMetaData   bit,
IsForceOffline  bit,
IsCopyOnly  bit,
FirstRecoveryForkID     uniqueidentifier,
ForkPointLSN    numeric(25,0),
RecoveryModel   nvarchar(60),
DifferentialBaseLSN     numeric(25,0),
DifferentialBaseGUID    uniqueidentifier,
BackupTypeDescription   nvarchar(60),
BackupSetGUID   uniqueidentifier,
CompressedBackupSize    bigint,
Containment     tinyint,
KeyAlgorithm    nvarchar(32),
EncryptorThumbprint     varbinary(20),
EncryptorType   nvarchar(32)'

IF OBJECT_ID('tempdb..#BackupFolderContent') IS NOT NULL
    DROP TABLE #BackupFolderContent

CREATE TABLE #BackupFolderContent (
    SubDirectory nvarchar(255),
    Depth smallint,
    FileFlag bit
)

IF OBJECT_ID('tempdb..#BackupContent') IS NOT NULL
    DROP TABLE #BackupContent

CREATE TABLE #BackupContent (
    LogicalName     nvarchar(128)
)

set @SQL = 'alter TABLE #BackupContent add ' + @FileListOnlyColumns
exec sp_executesql @SQL

IF OBJECT_ID('tempdb..#BackupHeader') IS NOT NULL
    DROP TABLE #BackupHeader

CREATE TABLE #BackupHeader (
    BackupName  nvarchar(128)
)

set @SQL = 'alter TABLE #BackupHeader add ' + @FileHeaderColumns
exec sp_executesql @SQL

select @PathSeparator = left(physical_name,1) from sys.master_files where name = 'master'

exec xp_instance_regread N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory', @BackupFolder out

Insert into #BackupFolderContent(SubDirectory, Depth, FileFlag)
EXEC master..xp_dirtree @BackupFolder, 1, 1

delete from #BackupFolderContent where SubDirectory not like '%.bak'
update #BackupFolderContent set SubDirectory = @BackupFolder + @PathSeparator + SubDirectory

select @InstanceDefaultDataPath = CONVERT(nvarchar, SERVERPROPERTY('InstanceDefaultDataPath'))
select @InstanceDefaultLogPath = CONVERT(nvarchar, SERVERPROPERTY('InstanceDefaultLogPath'))

declare curBackupFolderContent cursor for
    select SubDirectory from #BackupFolderContent

open curBackupFolderContent
FETCH NEXT FROM curBackupFolderContent into @BackupFile
WHILE @@Fetch_Status = 0
    BEGIN

        Insert Into #BackupContent
         exec ('RESTORE FILELISTONLY FROM DISK = N''' + @BackupFile + '''')

        Insert Into #BackupHeader
         exec ('RESTORE HEADERONLY FROM DISK = N''' + @BackupFile + '''')

        select @DatabaseName = DatabaseName from #BackupHeader
        select @HasMemTables = 1 from #BackupContent where Type = 'S'
        select @DataName = LogicalName from #BackupContent where Type = 'D'
        select @LogName = LogicalName from #BackupContent where Type = 'L'
        select @MemName = LogicalName from #BackupContent where Type = 'S'

        set @SQL = 'RESTORE DATABASE [' + @DatabaseName + ']
                    FROM DISK = N''' + @BackupFile + '''
                    WITH NOUNLOAD,  REPLACE,  STATS = 5,
                        MOVE ''' + @DataName + ''' TO ''' + @InstanceDefaultDataPath + @DataName + '.mdf'',
                        MOVE ''' + @LogName + ''' TO ''' + @InstanceDefaultDataPath + @LogName + '.ldf'''

        if (1 = @HasMemTables)
        begin
            set @SQL = @SQL + ', MOVE ''' + @MemName + ''' TO ''' + @InstanceDefaultDataPath + @MemName + ''''
        end

        --print @SQL
        exec (@SQL)

        FETCH NEXT FROM curBackupFolderContent into @BackupFile
    end
CLOSE curBackupFolderContent
DEALLOCATE curBackupFolderContent

