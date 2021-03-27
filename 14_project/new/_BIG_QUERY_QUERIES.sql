USE otus;
GO
--1
SELECT COUNT(*) 
FROM `otus-clickhouse-comparsion.otus.test` ;
/*
1. Query complete (0.4 sec elapsed, 0 B processed)

2. Query complete (0.0 sec elapsed, cached)
*/

--2
SELECT starts, COUNT(*) as cnt
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY starts
ORDER BY cnt DESC
LIMIT 10;

/*
1. Query complete (0.7 sec elapsed, 152.6 MB processed)

2. Query complete (0.0 sec elapsed, cached)
*/

--3.
SELECT userid, SUM(premium) AS summary, SUM(payout)/NULLIF(SUM(cases), 0) average_payout
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY userid
ORDER BY average_payout DESC
LIMIT 10;

/*
1. Query complete (1.3 sec elapsed, 610.4 MB processed)

2. Query complete (0.0 sec elapsed, cached)

*/

--4.
SELECT  
    filial, 
    SUM(premium), 
    CAST(SUM(premium) AS float) * 100 
        / SUM(SUM(premium)) OVER ()  AS pctg
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY filial
ORDER BY pctg DESC
LIMIT 10;

/*
1. Query complete (2.1 sec elapsed, 420.5 MB processed)

2. SQL Server Execution Times:
   CPU time = 9206 ms,  elapsed time = 1409 ms

*/

--5
SELECT filial, SUM(premium) - SUM(payout)
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY filial
ORDER BY 2 DESC
LIMIT 10;

/*
1. Query complete (2.7 sec elapsed, 573.1 MB processed)

*/

--6
SELECT *
FROM `otus-clickhouse-comparsion.otus.test` 
LIMIT 10;

/*
1... Query complete (1.0 sec elapsed, 9.3 GB processed)

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
        SUM(premium) AS premium,
        ROW_NUMBER() OVER (PARTITION BY filial ORDER BY SUM(premium) DESC) rn
    FROM `otus-clickhouse-comparsion.otus.test` 
    WHERE filial IN (
        SELECT  filial
        FROM `otus-clickhouse-comparsion.otus.test` 
        GROUP BY filial 
        ORDER BY SUM(payout) DESC
        LIMIT 10
    )
    GROUP BY filial, userid
)t
WHERE rn <= 10
ORDER BY filial, userid, premium DESC;
/*
1. Query complete (3.1 sec elapsed, 725.7 MB processed)

Slot time consumed 
44.856 sec
*/

--8

SELECT 
    card_provider,
    COUNT(*) AS payments,
    SUM(premium) AS sum,
    SUM(premium)*1.0 / COUNT(*)  AS average_payment
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY card_provider
ORDER BY average_payment DESC;

/*
1 Query complete (0.8 sec elapsed, 438.7 MB processed)

Slot time consumed 
6.158 sec
*/

--9 Количество договоров и процентное соотношение по кол-ву страховых случаев по полам
SELECT 
    sex,
    COUNT(*) AS contracts,
    SUM(cases) * 100. / SUM(SUM(cases)) OVER() AS cases_pctg
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY sex
ORDER BY cases_pctg DESC;

/*
1. Query complete (1.4 sec elapsed, 228.9 MB processed)

2. Slot time consumed 
5.514 sec
*/

--10 Поиск по уникальному id B6FFE30D-F1B7-4DFB-8CA0-1C62CE2D8619
SELECT COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE id = 'B6FFE30D-F1B7-4DFB-8CA0-1C62CE2D8619';

/*
1.Query complete (1.0 sec elapsed, 724.8 MB processed)

Slot time consumed 
11.836 sec
*/

--11. Поиск по неуникальной строке (100 записей) username lholloway
SELECT COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE username = 'lholloway';

/*
1. Query complete (0.7 sec elapsed, 225.6 MB processed)

Slot time consumed 
3.899 sec
*/

--12. Количество договоров сотрудника

SELECT COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE userid = 7171;
   
/*
1. Query complete (0.4 sec elapsed, 152.6 MB processed)

2. Slot time consumed 
0.751 sec
*/

--13 COUNT DISTINCT int

SELECT COUNT(DISTINCT userid)
FROM `otus-clickhouse-comparsion.otus.test`;
/*
1. Query complete (0.6 sec elapsed, 152.6 MB processed)

2. Slot time consumed 
5.148 sec
*/

--14 COUNT DISTINCT long string

SELECT COUNT(DISTINCT address)
FROM `otus-clickhouse-comparsion.otus.test` ;

/*
1. Query complete (3.6 sec elapsed, 852.8 MB processed)

Slot time consumed 
1 min 31.666 sec.
*/

--15
SELECT MIN(starts), MAX(starts)
FROM `otus-clickhouse-comparsion.otus.test` ;

/*
1.Query complete (0.5 sec elapsed, 152.6 MB processed)

2. Slot time consumed 
2.709 sec
*/

--16
SELECT userid, COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE userid <> 101
GROUP BY userid
ORDER BY COUNT(*) DESC
LIMIT 10;

/*
1. Query complete (0.7 sec elapsed, 152.6 MB processed)

2. Slot time consumed 
5.264 sec
*/

--17.
SELECT region, COUNT(DISTINCT userid) AS u
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY region
ORDER BY u DESC
LIMIT 10;

/*
1. Query complete (5.4 sec elapsed, 228.9 MB processed)

2. Slot time consumed 
58.509 sec
*/

--18
SELECT userid, insurer_company, COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC
LIMIT 10;
/*
1. Query complete (7.5 sec elapsed, 506.1 MB processed)

2. Slot time consumed 
1 min 30.427 sec
*/

--19

SELECT userid, insurer_company, COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE insurer_company NOT LIKE 'Smith%'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC
LIMIT 10;

/*
1. Query complete (6.0 sec elapsed, 506.1 MB processed)

2. Slot time consumed 
1 min 18.357 sec
*/

--20 
SELECT userid, insurer_company, COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE insurer_company LIKE 'Smith%'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC
LIMIT 10;

/*
1. Query complete (1.2 sec elapsed, 506.1 MB processed)

2. Slot time consumed 
7.588 sec
*/

--21.
SELECT userid, insurer_company, COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE insurer_company = 'Smith Inc'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC
LIMIT 10;

/*
1. Query complete (0.7 sec elapsed, 506.1 MB processed)

2. Slot time consumed 
6.412 sec
*/

--22. Количество действующих договоров

SELECT COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE date_diff(CURRENT_DATE, starts, DAY) < 366;

/*
1. Query complete (0.5 sec elapsed, 152.6 MB processed)

2. Slot time consumed 
2.704 sec
*/

--22.1
SELECT COUNT(*)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE starts > DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY);

/* SARGable matters
1.Query complete (0.4 sec elapsed, 152.6 MB processed)

2. Slot time consumed 
1.069 sec
*/

--23
SELECT 
    sex,
    SUM(CASE WHEN date_diff(CURRENT_DATE, birthdate, YEAR) < 20 THEN cases ELSE 0 END) * 100. / SUM(cases) AS young,
    SUM(CASE WHEN date_diff(CURRENT_DATE, birthdate, YEAR) >= 20 AND date_diff(CURRENT_DATE, birthdate, YEAR) < 40 THEN cases ELSE 0 END) * 100. / SUM(cases) AS mid,
    SUM(CASE WHEN date_diff(CURRENT_DATE, birthdate, YEAR) >= 40 THEN cases ELSE 0 END) * 100. / SUM(cases) AS old    
FROM `otus-clickhouse-comparsion.otus.test` 
GROUP BY sex;

/*
1. Query complete (2.4 sec elapsed, 381.5 MB processed)

2. Slot time consumed 
54.886 sec
*/

--24 Средний возраст машин, попадющих в ДТП чаще других
SELECT AVG(EXTRACT(YEAR FROM CURRENT_DATE) - Year)
FROM `otus-clickhouse-comparsion.otus.test` 
WHERE cases = (
    SELECT MAX(cases)       
    FROM `otus-clickhouse-comparsion.otus.test` 
)

/*
1. Query complete (0.6 sec elapsed, 305.2 MB processed)

2. Slot time consumed 
4.491 sec
*/

--25 TOP 2 самых аварийных марки модели в своей категории

SELECT Category, Make, Model, overall_cases
FROM
(
    SELECT Category, Make, Model, SUM(cases) AS overall_cases, ROW_NUMBER() OVER (PARTITION BY Category ORDER BY SUM(cases) DESC) AS rn
    FROM `otus-clickhouse-comparsion.otus.test` 
    GROUP BY Category, Make, Model
)t
WHERE rn < 3

/*
1. Query complete (1.1 sec elapsed, 829.7 MB processed)

2. Slot time consumed 
16.566 sec