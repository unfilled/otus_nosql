USE otus;
GO
--1
SELECT COUNT(*) 
FROM test;
/*
1.
 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 61 ms.

2.
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 7 ms.
*/

--2
SELECT TOP 10 starts, COUNT(*) as cnt
FROM test
GROUP BY starts
ORDER BY cnt DESC;

/*
1.  SQL Server Execution Times:
   CPU time = 624 ms,  elapsed time = 230 ms.

2. SQL Server Execution Times:
   CPU time = 607 ms,  elapsed time = 104 ms.
*/

--3.
SELECT TOP 10 userid, SUM(premium) AS summary, SUM(payout)/NULLIF(SUM(cases), 0) average_payout
FROM test
GROUP BY userid
ORDER BY average_payout DESC;

/*
1. SQL Server Execution Times:
   CPU time = 2515 ms,  elapsed time = 988 ms.

2. SQL Server Execution Times:
   CPU time = 2485 ms,  elapsed time = 658 ms.

*/

--4.
SELECT TOP 10 
    filial, 
    SUM(CAST(premium AS bigint)), 
    CAST(SUM(CAST(premium AS bigint)) AS float) * 100 
        / SUM(SUM(CAST(premium AS bigint))) OVER ()  AS pctg
FROM test
GROUP BY filial
ORDER BY pctg DESC

/*
1. SQL Server Execution Times:
   CPU time = 9452 ms,  elapsed time = 1729 ms.

2. SQL Server Execution Times:
   CPU time = 9206 ms,  elapsed time = 1409 ms

*/

--5
SELECT TOP 10 filial, SUM(CAST(premium AS bigint)) - SUM(CAST(payout AS bigint))
FROM test
GROUP BY filial
ORDER BY 2 DESC

/*
1. SQL Server Execution Times:
   CPU time = 12360 ms,  elapsed time = 2380 ms.

2.  SQL Server Execution Times:
   CPU time = 10484 ms,  elapsed time = 1533 ms.
*/

--6
SELECT TOP 10 *
FROM test;

/*
1... SQL Server Execution Times:
   CPU time = 313 ms,  elapsed time = 313 ms.

2...  SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 14 ms.

*/

--7 выбираем 10 филиалов, совершающих больше всего выплат и в каждом выводим по 10 сотрудников, собравших больше всего премий
SELECT filial, userid, premium
FROM
(
    SELECT
        filial,
        userid, 
        SUM(CAST(premium AS bigint)) AS premium,
        ROW_NUMBER() OVER (PARTITION BY filial ORDER BY SUM(CAST(premium AS bigint)) DESC) rn
    FROM test
    WHERE filial IN (
        SELECT TOP 10 filial
        FROM test
        GROUP BY filial 
        ORDER BY SUM(CAST(payout AS bigint)) DESC
    )
    GROUP BY filial, userid
)t
WHERE rn <= 10
ORDER BY filial, userid, premium DESC

/*
1. SQL Server Execution Times:
   CPU time = 27749 ms,  elapsed time = 4427 ms.

2. SQL Server Execution Times:
   CPU time = 22234 ms,  elapsed time = 3228 ms..
*/

--8

SELECT 
    card_provider,
    COUNT(*) AS payments,
    SUM(CAST(premium AS bigint)) AS sum,
    SUM(CAST(premium AS float)) / COUNT(*)  AS average_payment
FROM test
GROUP BY card_provider
ORDER BY average_payment DESC

/*
1   SQL Server Execution Times:
   CPU time = 736 ms,  elapsed time = 346 ms.

2   SQL Server Execution Times:
   CPU time = 594 ms,  elapsed time = 135 ms.
*/

--9 Количество договоров и процентное соотношение по кол-ву страховых случаев по полам
SELECT 
    sex,
    COUNT(*) AS contracts,
    SUM(cases) * 100. / SUM(SUM(cases)) OVER() AS cases_pctg
FROM test
GROUP BY sex
ORDER BY cases_pctg DESC

/*
1. SQL Server Execution Times:
   CPU time = 156 ms,  elapsed time = 115 ms.

2. SQL Server Execution Times:
   CPU time = 233 ms,  elapsed time = 62 ms.
*/

--10 Поиск по уникальному id B6FFE30D-F1B7-4DFB-8CA0-1C62CE2D8619
SELECT COUNT(*)
FROM test
WHERE id = 'B6FFE30D-F1B7-4DFB-8CA0-1C62CE2D8619'

/*
1. SQL Server Execution Times:
   CPU time = 955 ms,  elapsed time = 894 ms.

2. SQL Server Execution Times:
   CPU time = 703 ms,  elapsed time = 138 ms.
*/

--11. Поиск по неуникальной строке (100 записей) username lholloway
SELECT COUNT(*)
FROM test
WHERE username = 'lholloway'

/*
1. SQL Server Execution Times:
   CPU time = 7046 ms,  elapsed time = 1403 ms.

2. SQL Server Execution Times:
   CPU time = 6999 ms,  elapsed time = 984 ms.
*/

--12. Количество договоров сотрудника

SELECT COUNT(*)
FROM test
WHERE userid = 7171
   
/*
1. SQL Server Execution Times:
   CPU time = 78 ms,  elapsed time = 86 ms.

2. SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 8 ms.
*/

--13 COUNT DISTINCT int

SELECT COUNT(DISTINCT userid)
FROM test
/*
1. SQL Server Execution Times:
   CPU time = 453 ms,  elapsed time = 457 ms.

2.  SQL Server Execution Times:
   CPU time = 453 ms,  elapsed time = 464 ms.
*/

--14 COUNT DISTINCT long string

SELECT COUNT(DISTINCT address)
FROM test

/*
1. SQL Server Execution Times:
   CPU time = 56030 ms,  elapsed time = 12064 ms.

2. SQL Server Execution Times:
   CPU time = 53109 ms,  elapsed time = 11266 ms.
*/

--15
SELECT MIN(starts), MAX(starts)
FROM test

/*
1. SQL Server Execution Times:
   CPU time = 172 ms,  elapsed time = 313 ms.

2.  SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 51 ms.
*/

--16
SELECT TOP 10 userid, COUNT(*)
FROM test
WHERE userid <> 101
GROUP BY userid
ORDER BY COUNT(*) DESC

/*
1.  SQL Server Execution Times:
   CPU time = 640 ms,  elapsed time = 264 ms.

2. SQL Server Execution Times:
   CPU time = 704 ms,  elapsed time = 164 ms.
*/

--17.
SELECT TOP 10 region, COUNT(DISTINCT userid) AS u
FROM test
GROUP BY region
ORDER BY u DESC
   
/*
1. SQL Server Execution Times:
   CPU time = 6080 ms,  elapsed time = 1104 ms.

2. SQL Server Execution Times:
   CPU time = 6077 ms,  elapsed time = 884 ms.
*/

--18
SELECT TOP 10 userid, insurer_company, COUNT(*)
FROM test
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC
/*
1. SQL Server Execution Times:
   CPU time = 37562 ms,  elapsed time = 7133 ms.

2. SQL Server Execution Times:
   CPU time = 44390 ms,  elapsed time = 7440 ms.
*/

--19

SELECT TOP 10 userid, insurer_company, COUNT(*)
FROM test
WHERE insurer_company NOT LIKE 'Smith%'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC

/*
1. SQL Server Execution Times:
   CPU time = 71218 ms,  elapsed time = 20891 ms.

2.  SQL Server Execution Times:
   CPU time = 60046 ms,  elapsed time = 10332 ms.
*/

--20 
SELECT TOP 10 userid, insurer_company, COUNT(*)
FROM test
WHERE insurer_company LIKE 'Smith%'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC

/*
1.  SQL Server Execution Times:
   CPU time = 15000 ms,  elapsed time = 2949 ms.

2.   SQL Server Execution Times:
   CPU time = 16936 ms,  elapsed time = 2551 ms.
*/

--21.
SELECT TOP 10 userid, insurer_company, COUNT(*)
FROM test
WHERE insurer_company = 'Smith Inc'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC

/*
1.  SQL Server Execution Times:
   CPU time = 11875 ms,  elapsed time = 2493 ms.

2. SQL Server Execution Times:
   CPU time = 7703 ms,  elapsed time = 1155 ms.
*/

--22. Количество действующих договоров

SELECT COUNT(*)
FROM test
WHERE DATEDIFF(DAY, starts, CURRENT_TIMESTAMP) < 366

/*
1. SQL Server Execution Times:
   CPU time = 3047 ms,  elapsed time = 3185 ms.

2.  SQL Server Execution Times:
   CPU time = 2828 ms,  elapsed time = 2825 ms..
*/

--22.1
SELECT COUNT(*)
FROM test
WHERE starts > DATEADD(DAY, -366, CURRENT_TIMESTAMP)

/* SARGable matters
1.
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 48 ms.

2. SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 18 ms.
*/

--23
SELECT 
    sex,
    SUM(CASE WHEN DATEDIFF(YEAR, birthdate, CURRENT_TIMESTAMP) < 20 THEN cases ELSE 0 END) * 100. / SUM(cases) AS young,
    SUM(CASE WHEN DATEDIFF(YEAR, birthdate, CURRENT_TIMESTAMP) >= 20 AND DATEDIFF(YEAR, birthdate, CURRENT_TIMESTAMP) < 40 THEN cases ELSE 0 END) * 100. / SUM(cases) AS mid,
    SUM(CASE WHEN DATEDIFF(YEAR, birthdate, CURRENT_TIMESTAMP) >= 40 THEN cases ELSE 0 END) * 100. / SUM(cases) AS old    
FROM test
GROUP BY sex

/*
1.  SQL Server Execution Times:
   CPU time = 17328 ms,  elapsed time = 2755 ms.

2.  SQL Server Execution Times:
   CPU time = 15937 ms,  elapsed time = 2330 ms.
*/

--24 Средний возраст машин, попадющих в ДТП чаще других
SELECT AVG(DATEPART(YEAR, CURRENT_TIMESTAMP) - Year)
FROM test
WHERE cases = (
    SELECT MAX(cases)       
    FROM test
)

/*
1. SQL Server Execution Times:
   CPU time = 361 ms,  elapsed time = 148 ms.

2. SQL Server Execution Times:
   CPU time = 170 ms,  elapsed time = 51 ms.
*/

--25 TOP 2 самых аварийных марки модели в своей категории

SELECT Category, Make, Model, overall_cases
FROM
(
    SELECT Category, Make, Model, SUM(cases) AS overall_cases, ROW_NUMBER() OVER (PARTITION BY Category ORDER BY SUM(cases) DESC) AS rn
    FROM test
    GROUP BY Category, Make, Model
)t
WHERE rn < 3

/*
1. SQL Server Execution Times:
   CPU time = 594436 ms,  elapsed time = 115748 ms.

2. SQL Server Execution Times:
   CPU time = 593858 ms,  elapsed time = 115358 ms.
*/

