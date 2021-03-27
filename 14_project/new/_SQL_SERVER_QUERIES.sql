DBCC DROPCLEANBUFFERS
GO

SET STATISTICS TIME, IO ON;
GO

SELECT Category, Make, Model, overall_cases
FROM
(
    SELECT Category, Make, Model, SUM(cases) AS overall_cases, ROW_NUMBER() OVER (PARTITION BY Category ORDER BY SUM(cases) DESC) AS rn
    FROM test
    GROUP BY Category, Make, Model
)t
WHERE rn < 3
ORDER BY Category ASC, overall_cases DESC


SELECT * FROM (

SELECT Category, Make, Model, overall_cases, ROW_NUMBER() OVER (PARTITION BY Category ORDER BY overall_cases DESC) AS rn
FROM
(
    SELECT Category, Make, Model, SUM(cases) AS overall_cases
    FROM test
    GROUP BY Category, Make, Model
)t
)x
WHERE rn < 3

SELECT COUNT(*)
FROM(
    SELECT Category, Make, Model
    FROM test
    GROUP BY Category, Make, Model
)t