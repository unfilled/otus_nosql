--DBCC SHRINKDATABASE(otus, 0)

SELECT *
FROM test
WHERE id = 'EF2B69E3-B2BB-40CC-A706-382A4EA49017'


UPDATE test 
SET residence = REPLACE(REPLACE(residence, CHAR(13), ''), CHAR(10), ''), 
  address = REPLACE(REPLACE(address, CHAR(13), ''), CHAR(10), '')
WHERE id = 'B27F7617-3ECC-4406-B717-597A78185450'

80918 Betty Trafficway Apt. 296 Mollyside, VA 76991

select * from sys.databases