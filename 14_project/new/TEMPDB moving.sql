select * 
from sys.database_files

ALTER DATABASE tempdb
MODIFY FILE (
    NAME = tempdev,
    SIZE = 2048MB,
    FILEGROWTH = 256MB,
    FILENAME = 'C:\temp\tempdev.mdf'
);
GO

ALTER DATABASE tempdb
MODIFY FILE (
    NAME = temp2,
    SIZE = 2048MB,
    FILEGROWTH = 256MB,
    FILENAME = 'C:\temp\temp2.mdf'
);
GO

ALTER DATABASE tempdb
MODIFY FILE (
    NAME = temp3,
    SIZE = 2048MB,
    FILEGROWTH = 256MB,
    FILENAME = 'C:\temp\temp3.mdf'
);
GO

ALTER DATABASE tempdb
MODIFY FILE (
    NAME = temp4,
    SIZE = 2048MB,
    FILEGROWTH = 256MB,
    FILENAME = 'C:\temp\temp4.mdf'
);
GO


ALTER DATABASE tempdb
MODIFY FILE (
    NAME = templog,
    SIZE = 1024MB,
    FILEGROWTH = 128MB,
    FILENAME = 'C:\temp\templog.ldf'
);
GO