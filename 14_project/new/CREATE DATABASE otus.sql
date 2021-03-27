USE master;
GO

CREATE DATABASE otus
ON (
    NAME = otus_1,
    FILENAME = 'D:\SQLServer\NINE\otus_1.mdf',
    SIZE = 10240MB,
    FILEGROWTH = 512MB
), (
    NAME = otus_2,
    FILENAME = 'D:\SQLServer\NINE\otus_2.ndf',
    SIZE = 10240MB,
    FILEGROWTH = 512MB
), (
    NAME = otus_3,
    FILENAME = 'D:\SQLServer\NINE\otus_3.ndf',
    SIZE = 10240MB,
    FILEGROWTH = 512MB
), (
    NAME = otus_4,
    FILENAME = 'D:\SQLServer\NINE\otus_4.ndf',
    SIZE = 10240MB,
    FILEGROWTH = 512MB
)
LOG ON (
    NAME = otus_log,
    FILENAME = 'D:\SQLServer\NINE\otus_log.ldf',
    SIZE = 8192MB,
    FILEGROWTH = 256MB
)
GO

ALTER DATABASE otus SET RECOVERY SIMPLE;
GO

ALTER DATABASE otus SET DELAYED_DURABILITY = FORCED;
GO

USE otus;
GO 

CREATE TABLE test (
    id              uniqueidentifier,
    someuuid        uniqueidentifier,
    starts          date,
    userid          int,
    filial          varchar(200),
    region          varchar(10),
    correlation_id  uniqueidentifier,
    company         varchar(500),
    card_provider   varchar(100),
    license_plate   varchar(20),
    md5             varchar(50),
    premium         int,
    cases           int,
    payout          int,
    job             varchar(300),
    insurer_company varchar(300),
    ssn             char(11),
    residence       varchar(500),
    blood_group     varchar(10),
    username        varchar(200),
    name            varchar(500),
    sex             char(2),
    address         varchar(1000),
    mail            varchar(500),
    birthdate       date,
    Make            varchar(500),
    Model           varchar(500),
    Category        varchar(100),
    Year            int
);
GO

EXEC sp_spaceused 'test';
GO
/*
name	rows	    reserved	data	    index_size	unused
test	20000000    8429088 KB	8427992 KB	32 KB	    1064 KB
*/

CREATE CLUSTERED COLUMNSTORE INDEX ccix_test ON test;
GO

EXEC sp_spaceused 'test';
GO

/*
name	rows	    reserved	data	    index_size	unused
test	20000000    4936480 KB	4936280 KB	0 KB	    200 KB
*/
