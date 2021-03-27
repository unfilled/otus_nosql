SET STATISTICS TIME, IO ON;

--1
SELECT COUNT(*)
FROM test;
/*
1. COLD 
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 421 ms.

2. WARM
 SQL Server Execution Times:
   CPU time = 32 ms,  elapsed time = 42 ms.
*/

--2
SELECT TOP 10 starts, COUNT(*) as cnt
FROM test
GROUP BY starts
ORDER BY cnt DESC;

/*
1.
 SQL Server Execution Times:
   CPU time = 1455 ms,  elapsed time = 537 ms.

2.
 SQL Server Execution Times:
   CPU time = 1469 ms,  elapsed time = 546 ms.
*/

--3
SELECT TOP 10 userid, SUM(premium) AS summary, SUM(payout)/NULLIF(SUM(cases), 0) average_payout
FROM test
GROUP BY userid
ORDER BY average_payout DESC;

/*
1.
 SQL Server Execution Times:
   CPU time = 5172 ms,  elapsed time = 4122 ms.

2.
 SQL Server Execution Times:
   CPU time = 5250 ms,  elapsed time = 1864 ms.
*/

--4
SELECT TOP 10 filial, SUM(CAST(premium AS bigint)), CAST(SUM(CAST(premium AS bigint)) AS float) * 100 / SUM(SUM(CAST(premium AS bigint))) OVER ()  AS pctg
FROM test
GROUP BY filial
ORDER BY pctg DESC

--5
SELECT TOP 10 filial, SUM(CAST(premium AS bigint)) - SUM(CAST(payout AS bigint))
FROM test
GROUP BY filial
ORDER BY 2 DESC