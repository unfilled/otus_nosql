USE otus;
GO


DECLARE @sql varchar(8000);
SELECT @sql  = 'bcp otus.dbo.test out E:\Temp\otus.tsv -c -r '+'0x0A' + ' -T -F 10 -S '+ @@servername 
EXEC master..xp_cmdshell @sql

--'B27F7617-3ECC-4406-B717-597A78185450'

DECLARE @sql varchar(8000);
SELECT @sql  = 'bcp "

" queryout E:\Temp\otus3.tsv -c -r '+'0x0A' + ' -T -S '+ @@servername 
EXEC master..xp_cmdshell @sql