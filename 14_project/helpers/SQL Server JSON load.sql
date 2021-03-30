USE otus;
GO

SET NOCOUNT ON;

DECLARE @JSON varchar(max);
SELECT @JSON=BulkColumn
FROM OPENROWSET (BULK 'E:\temp\data_1250000_1.json', SINGLE_CLOB) as import

INSERT INTO test (
    id              ,
    someuuid        ,
    starts          ,
    userid          ,
    filial          ,
    region          ,
    correlation_id  ,
    company         ,
    card_provider   ,
    license_plate   ,
    md5             ,
    premium         ,
    cases           ,
    payout          ,
    job             ,
    insurer_company ,
    ssn             ,
    residence       ,
    blood_group     ,
    username        ,
    name            ,
    sex             ,
    address         ,
    mail            ,
    birthdate       ,
    Make            ,
    Model           ,
    Category        ,
    Year            
)
SELECT 
    top_level.id,
    top_level.someuuid,
    top_level.starts,
    top_level.userid,
    top_level.filial,
    top_level.region,
    top_level.correlation_id,
    top_level.company,
    top_level.card_provider,
    top_level.license_plate,
    top_level.md5,
    top_level.premium,
    top_level.cases,
    top_level.payout,
    insurer.job,
    insurer.company,
    insurer.ssn,
    insurer.residence,
    insurer.blood_group,
    insurer.username,
    insurer.name,
    insurer.sex,
    insurer.address,
    insurer.mail,
    insurer.birthdate,
    vehicle.Make,
    vehicle.Model,
    vehicle.Category,
    vehicle.Year
FROM OPENJSON (@JSON)
WITH (
    id uniqueidentifier,
    someuuid uniqueidentifier,
    starts date,
    userid int,
    filial varchar(200),
    region varchar(10),
    correlation_id uniqueidentifier,
    company varchar(500),
    card_provider varchar(100),
    license_plate varchar(20),
    md5 varchar(50),
    insurer nvarchar(max) AS json,
    vehicle nvarchar(max) AS json,
    premium int,
    cases int,
    payout int
) top_level
CROSS APPLY OPENJSON(top_level.insurer)
WITH (
    job varchar(300),
    company varchar(300),
    ssn char(11),
    residence varchar(500),
    blood_group varchar(10),
    username varchar(200),
    name varchar(500),
    sex char(2),
    address varchar(1000),
    mail varchar(500),
    birthdate date
) insurer
CROSS APPLY OPENJSON (top_level.vehicle)
WITH (
    Make varchar(500),
    Model varchar(500),
    Category varchar(100),
    Year int
) vehicle;

GO
