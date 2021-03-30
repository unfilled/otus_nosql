USE otus;
GO


DECLARE @sql varchar(8000);
SELECT @sql  = 'bcp otus.dbo.test out E:\Temp\otus.tsv -c -r '+'0x0A' + ' -T -F 10 -S '+ @@servername 
EXEC master..xp_cmdshell @sql

