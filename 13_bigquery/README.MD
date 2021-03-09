# 13 Google BigQuery

Была создана бесплатная УЗ в Google Cloud, первый проект был создан автоматически. В BigQuery был создан пустой датасет test и в нём были созданы две таблицы - hits и visits из ДЗ 11 по (Clickhouse)[https://github.com/unfilled/otus_nosql/tree/master/09_Clickhouse].

Для этого были загружены публичные датасеты кликхауса:
```
https://datasets.clickhouse.tech/hits/tsv/hits_v1.tsv.xz
https://datasets.clickhouse.tech/visits/tsv/visits_v1.tsv.xz
```

Файлы были разархивированы в TSV и загружены сначала в Cloud Storage, а затем в BigQuery (Create Table, Gogle Cloud Storage, CSV, Auto-detect Schema and input parameters, Advanced -> Delimeter "TAB", Ignore unknown values, Allow jagged rows).
Предварительная загрузка в Cloud Storage потребовалась, поскольку Big Query откзывается загружать напрямую с ПК файлы размером больше 10 МБ.

Изначально, я планировал повторить запросы из задания по кликхаусу, чтобы посмотреть кто будет быстрее их выполнять, но после подготовки таблицы, bigquery отказался загружать в неё данные, выдавая ошибку `Cannot load CSV data with a nested schema`, поэтому пришлось использовать автосоздание схемы, что привело к тому, что все столбцы приняли имена `тип_номер_поля`.
В связи с этим, запросы использовались похожие по структуре, но с произвольными полями.

```sql
SELECT COUNT(*) FROM `peak-study-307111.test.hits`
--Query complete (0.3 sec elapsed, 0 B processed) - видимо взял из метаданных

SELECT COUNT(*) FROM `peak-study-307111.test.visits`
--Query complete (0.4 sec elapsed, 0 B processed)

SELECT
    string_field_5 AS URL,
    COUNT(DISTINCT string_field_17) AS AvgDuration
FROM `peak-study-307111.test.visits`
GROUP BY string_field_5
ORDER BY AvgDuration DESC
LIMIT 100;
--Query complete (2.1 sec elapsed, 68.2 MB processed)

SELECT COUNT(DISTINCT int64_field_40)
FROM `peak-study-307111.test.hits`;
--Query complete (0.6 sec elapsed, 66.2 MB processed)

SELECT
  string_field_2,
  SUM(int64_field_1) AS Sum1,
  AVG(int64_field_0) AS Avg1
FROM `peak-study-307111.test.hits`
GROUP BY string_field_2
ORDER BY Sum1 ASC, Avg1 DESC
LIMIT 100;
Query complete (3.5 sec elapsed, 786.3 MB processed)

SELECT
  MIN(int64_field_0) AS Min1,
  MAX(int64_field_0) AS Max1
FROM `peak-study-307111.test.hits`
--Query complete (0.4 sec elapsed, 66.2 MB processed)

SELECT
  MIN(int64_field_0) AS Min1,
  MAX(int64_field_0) AS Max1,
  AVG(int64_field_0) AS Avg1
FROM `peak-study-307111.test.hits`
--Query complete (0.4 sec elapsed, 66.2 MB processed)

SELECT
  MIN(int64_field_0) AS Min1,
  MAX(int64_field_0) AS Max1,
  AVG(int64_field_0) AS Avg1
FROM `peak-study-307111.test.hits`
--Query complete (0.0 sec elapsed, cached)
```

Интересно, что как показывают последние три запроса, BigQuery использует кэширование именно результатов запросов - все запросы используют только один столбец одной таблицы, выполнялись подряд. Если он и кэширует прочитанные данные, он не учитывает время на "чтение" в оперативную память при выводе результата. Все запросы из списка выше, при повторном выполнении выдают результат мгновненно с `Query complete (0.0 sec elapsed, cached)`. 

Датасеты достаточно большие: hits 8.76 GB, visits: 2.27 GB. Размер примерно совпадает с размером исходных TSV-файлов. При этом, для запросов читаются данные только нужных столбцов (...MB processed у каждого запроса небольшие) - под капотом используется колоночное хранение, как и в кликхаусе, но, видимо, без сжатия.

В целом, если сравнивать скорость выполнения с кликахусом, кликахаус, установленный локально на домашнем ноутбуке с 12 ГБ ОЗУ на обычном SATA SSD, возвращал результаты "похожих" запросов примерно с той же скоростью - он лучше жмёт данные и ему приходится читать меньше.