--1
SELECT COUNT(id) 
FROM otus.test2;
/*
1. Elapsed: 0.185 sec. Processed 20.00 million rows, 40.00 MB (107.87 million rows/s., 215.74 MB/s.)

2. Elapsed: 0.019 sec. Processed 20.00 million rows, 40.00 MB (1.03 billion rows/s., 2.05 GB/s.)
*/

--2
SELECT starts, COUNT(*) as cnt
FROM otus.test2
GROUP BY starts
ORDER BY cnt DESC
LIMIT 10;

/*
1. Elapsed: 0.049 sec. Processed 20.00 million rows, 40.00 MB (411.80 million rows/s., 823.61 MB/s.)

2. Elapsed: 0.049 sec. Processed 20.00 million rows, 40.00 MB (409.23 million rows/s., 818.45 MB/s.)
*/

--3.
SELECT userid, SUM(premium) AS summary, SUM(payout)/NULLIF(SUM(cases), 0) average_payout
FROM otus.test2
GROUP BY userid
ORDER BY average_payout DESC
LIMIT 10;

/*
1. Elapsed: 0.348 sec. Processed 20.00 million rows, 320.00 MB (57.45 million rows/s., 919.21 MB/s.)

2. Elapsed: 0.372 sec. Processed 20.00 million rows, 320.00 MB (53.82 million rows/s., 861.06 MB/s.)

*/
--Set allow_experimental_window_functions = 1
--4.
SELECT filial, premium_sum, premium_sum*100./pct AS pctg
    FROM
    (
    SELECT 
        filial, 
        SUM(premium) premium_sum, 
        SUM(SUM(premium)) OVER() AS pct
    FROM otus.test2
    GROUP BY filial    
    )x
ORDER BY pctg DESC
LIMIT 10;

/*
1.  Elapsed: 0.574 sec. Processed 20.00 million rows, 500.97 MB (34.83 million rows/s., 872.41 MB/s.)

2. Elapsed: 0.565 sec. Processed 20.00 million rows, 500.97 MB (35.37 million rows/s., 886.05 MB/s.)

*/

--5
SELECT 
    filial, 
    SUM(premium) - SUM(payout) t
FROM otus.test2
GROUP BY filial
ORDER BY t DESC
LIMIT 10;

/*
1. Elapsed: 0.698 sec. Processed 20.00 million rows, 580.97 MB (28.65 million rows/s., 832.25 MB/s.)

2. Elapsed: 0.709 sec. Processed 20.00 million rows, 580.97 MB (28.22 million rows/s., 819.83 MB/s.)
*/

--6
SELECT TOP 10 *
FROM otus.test2;

/*
1... 10 rows in set. Elapsed: 0.175 sec.

2... 10 rows in set. Elapsed: 0.015 sec.
*/

--7 выбираем 10 филиалов, совершающих больше всего выплат и в каждом выводим по 10 сотрудников, собравших больше всего премий
SELECT filial, userid, pr
FROM
(
    SELECT
        filial,
        userid, 
        SUM(premium) AS pr,
        row_number() OVER (PARTITION BY filial ORDER BY pr DESC) rn
    FROM otus.test2
    WHERE filial IN (
        SELECT filial
        FROM otus.test2
        GROUP BY filial 
        ORDER BY SUM(payout) DESC
        LIMIT 10
    )
    GROUP BY filial, userid
)t
WHERE rn <= 10
ORDER BY filial, userid, pr DESC;

/*
1. Elapsed: 1.306 sec. Processed 20.00 million rows, 580.97 MB (15.31 million rows/s., 444.70 MB/s.).

2.Elapsed: 0.870 sec. Processed 20.00 million rows, 580.96 MB (22.98 million rows/s., 667.59 MB/s.)
*/

--8

SELECT 
    card_provider,
    COUNT(*) AS payments,
    SUM(premium) AS sum,
    SUM(premium) / COUNT(*)  AS average_payment
FROM otus.test2
GROUP BY card_provider
ORDER BY average_payment DESC;

/*
1  Elapsed: 0.519 sec. Processed 20.00 million rows, 520.00 MB (38.54 million rows/s., 1.00 GB/s.)

2  Elapsed: 0.235 sec. Processed 20.00 million rows, 520.00 MB (85.13 million rows/s., 2.21 GB/s.)
*/

--9 Количество договоров и процентное соотношение по кол-ву страховых случаев по полам
SELECT sex, contracts, cases_by_sex * 100. / cases_overall as cases_pctg
FROM
(
    SELECT 
        sex,
        COUNT(*) AS contracts,
        SUM(cases) as cases_by_sex,
        SUM(SUM(cases)) OVER() AS cases_overall
    FROM otus.test2
    GROUP BY sex
)x
ORDER BY cases_pctg DESC;

/*
1. Elapsed: 0.486 sec. Processed 20.00 million rows, 120.00 MB (41.13 million rows/s., 246.76 MB/s.)

2. Elapsed: 0.125 sec. Processed 20.00 million rows, 120.00 MB (159.88 million rows/s., 959.31 MB/s.)
*/

--10 Поиск по уникальному id B6FFE30D-F1B7-4DFB-8CA0-1C62CE2D8619
SELECT COUNT(*)
FROM otus.test2
WHERE id = 'B6FFE30D-F1B7-4DFB-8CA0-1C62CE2D8619';

/*
1. Elapsed: 1.315 sec. Processed 20.00 million rows, 320.00 MB (15.20 million rows/s., 243.27 MB/s.)

2. Elapsed: 0.187 sec. Processed 20.00 million rows, 320.00 MB (107.02 million rows/s., 1.71 GB/s.)
*/

--11. Поиск по неуникальной строке (100 записей) username lholloway
SELECT COUNT(*)
FROM otus.test2
WHERE username = 'lholloway';

/*
1. Elapsed: 0.237 sec. Processed 20.00 million rows, 376.57 MB (84.50 million rows/s., 1.59 GB/s.)

2. Elapsed: 0.137 sec. Processed 20.00 million rows, 376.57 MB (145.86 million rows/s., 2.75 GB/s.)
*/

--12. Количество договоров сотрудника

SELECT COUNT(*)
FROM otus.test2
WHERE userid = 7171;
   
/*
1.  Elapsed: 0.115 sec. Processed 20.00 million rows, 80.00 MB (174.19 million rows/s., 696.76 MB/s.)

2. Elapsed: 0.039 sec. Processed 20.00 million rows, 80.00 MB (519.07 million rows/s., 2.08 GB/s.)
*/

--13 COUNT DISTINCT int

SELECT COUNT(DISTINCT userid)
FROM otus.test2;
/*
1. Elapsed: 0.206 sec. Processed 20.00 million rows, 80.00 MB (97.01 million rows/s., 388.04 MB/s.)

2. Elapsed: 0.092 sec. Processed 20.00 million rows, 80.00 MB (217.42 million rows/s., 869.68 MB/s.)
*/

--14 COUNT DISTINCT long string

SELECT COUNT(DISTINCT address)
FROM otus.test2;

/*
1. Elapsed: 9.116 sec. Processed 20.00 million rows, 1.03 GB (2.19 million rows/s., 113.45 MB/s.)

2. Elapsed: 4.378 sec. Processed 20.00 million rows, 1.03 GB (4.57 million rows/s., 236.20 MB/s.)
*/

--15
SELECT MIN(starts), MAX(starts)
FROM otus.test2;

/*
1. Elapsed: 0.046 sec. Processed 20.00 million rows, 40.00 MB (430.68 million rows/s., 861.35 MB/s.)

2. Elapsed: 0.061 sec. Processed 20.00 million rows, 40.00 MB (327.66 million rows/s., 655.31 MB/s.)
*/

--16
SELECT userid, COUNT(*)
FROM otus.test2
WHERE userid <> 101
GROUP BY userid
ORDER BY COUNT(*) DESC
LIMIT 10;

/*
1.  Elapsed: 0.179 sec. Processed 20.00 million rows, 80.00 MB (111.61 million rows/s., 446.46 MB/s.)

2. Elapsed: 0.173 sec. Processed 20.00 million rows, 80.00 MB (115.79 million rows/s., 463.18 MB/s.)
*/

--17.
SELECT region, COUNT(DISTINCT userid) AS u
FROM otus.test2
GROUP BY region
ORDER BY u DESC
LIMIT 10;
   
/*
1. Elapsed: 0.540 sec. Processed 20.00 million rows, 300.00 MB (37.03 million rows/s., 555.40 MB/s.)

2. Elapsed: 0.389 sec. Processed 20.00 million rows, 300.00 MB (51.46 million rows/s., 771.84 MB/s.)
*/

--18
SELECT userid, insurer_company, COUNT(*)
FROM otus.test2
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC
LIMIT 10;
/*
1. Elapsed: 9.076 sec. Processed 20.00 million rows, 590.66 MB (2.20 million rows/s., 65.08 MB/s.)

2. Elapsed: 5.165 sec. Processed 20.00 million rows, 590.66 MB (3.87 million rows/s., 114.35 MB/s.)
*/

--19

SELECT userid, insurer_company, COUNT(*)
FROM otus.test2
WHERE insurer_company NOT LIKE 'Smith%'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC
LIMIT 10;
/*
1. Elapsed: 10.655 sec. Processed 20.00 million rows, 590.66 MB (1.88 million rows/s., 55.43 MB/s.)

2. Elapsed: 5.307 sec. Processed 20.00 million rows, 590.66 MB (3.77 million rows/s., 111.30 MB/s.)
*/

--20 
SELECT TOP 10 userid, insurer_company, COUNT(*)
FROM otus.test2
WHERE insurer_company LIKE 'Smith%'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC;

/*
1. Elapsed: 0.615 sec. Processed 20.00 million rows, 590.66 MB (32.54 million rows/s., 961.03 MB/s.)

2.  Elapsed: 0.359 sec. Processed 20.00 million rows, 590.66 MB (55.66 million rows/s., 1.64 GB/s.)
*/

--21.
SELECT TOP 10 userid, insurer_company, COUNT(*)
FROM otus.test2
WHERE insurer_company = 'Smith Inc'
GROUP BY userid, insurer_company
ORDER BY COUNT(*) DESC; 

/*
1. Elapsed: 0.431 sec. Processed 20.00 million rows, 590.66 MB (46.39 million rows/s., 1.37 GB/s.)

2. Elapsed: 0.341 sec. Processed 20.00 million rows, 590.66 MB (58.67 million rows/s., 1.73 GB/s.)
*/

--22. Количество действующих договоров

SELECT COUNT(*)
FROM otus.test2
WHERE dateDiff('day', starts, now()) < 366;

/*
1. 1 rows in set. Elapsed: 0.088 sec. Processed 20.00 million rows, 40.00 MB (226.41 million rows/s., 452.81 MB/s.)

2. Elapsed: 0.058 sec. Processed 20.00 million rows, 40.00 MB (344.54 million rows/s., 689.09 MB/s.)
*/

--22.1
SELECT COUNT(*)
FROM otus.test2
WHERE starts > date_sub(DAY, 366, now());

/* SARGable matters for Clickhouse too
1.Elapsed: 0.020 sec. Processed 4.25 million rows, 8.50 MB (213.34 million rows/s., 426.68 MB/s.)

2. Elapsed: 0.028 sec. Processed 4.25 million rows, 8.50 MB (149.01 million rows/s., 298.01 MB/s.)
*/

--23
SELECT 
    sex,
    SUM(CASE WHEN DATEDIFF(YEAR, birthdate, now()) < 20 THEN cases ELSE 0 END) * 100. / SUM(cases) AS young,
    SUM(CASE WHEN DATEDIFF(YEAR, birthdate, now()) >= 20 AND DATEDIFF(YEAR, birthdate, now()) < 40 THEN cases ELSE 0 END) * 100. / SUM(cases) AS mid,
    SUM(CASE WHEN DATEDIFF(YEAR, birthdate, now()) >= 40 THEN cases ELSE 0 END) * 100. / SUM(cases) AS old    
FROM otus.test2
GROUP BY sex;

/*
1. Elapsed: 0.423 sec. Processed 20.00 million rows, 160.00 MB (47.25 million rows/s., 377.98 MB/s.)

2. Elapsed: 0.352 sec. Processed 20.00 million rows, 160.00 MB (56.88 million rows/s., 455.07 MB/s.)
*/

--24 Средний возраст машин, попадющих в ДТП чаще других
SELECT AVG(toYear(now()) - Year)
FROM otus.test2
WHERE cases = (
    SELECT MAX(cases)       
    FROM otus.test2
);

/*
1. Elapsed: 0.252 sec. Processed 20.00 million rows, 160.00 MB (79.39 million rows/s., 635.13 MB/s.)

2. Elapsed: 0.168 sec. Processed 20.00 million rows, 160.00 MB (119.05 million rows/s., 952.41 MB/s.)
*/

--25 TOP 2 самых аварийных марки модели в своей категории

SELECT Category, Make, Model, overall_cases
FROM
(
    SELECT Category, Make, Model, SUM(cases) AS overall_cases, row_number() OVER (PARTITION BY Category ORDER BY SUM(cases) DESC) AS rn
    FROM otus.test2
    GROUP BY Category, Make, Model
)t
WHERE rn < 3;

/*
1. Elapsed: 1.449 sec. Processed 20.00 million rows, 1.21 GB (13.80 million rows/s., 834.93 MB/s.)

2. Elapsed: 1.300 sec. Processed 20.00 million rows, 1.21 GB (15.38 million rows/s., 930.37 MB/s.)
*/
