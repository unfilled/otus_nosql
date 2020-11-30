# 6 Cassandra-1

ОС: Windows 10 Home, включён WSL версия 2 по умолчанию.

Установлены Docker Desktop и Kubernetes (в настройках Docker Desktop).

Cassandra развёрнута с помощью [Helm-чарта bitnami](https://bitnami.com/stack/cassandra/helm)

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install test-cassandra-cluster -f D:\cassandra\values.yaml bitnami/cassandra
```

Поскольку по умолчанию разворачивается [stand-alone из одной реплики](https://github.com/bitnami/charts/tree/master/bitnami/cassandra/#parameters), в values.yaml указываю replicaCount = 3 и cluster.seedCount = 3. Также указано имя УЗ admin с паролем admin вместо УЗ cassandra с автогенерируемым паролем.

После запуска всех контейнеров, в CLI одного из них запускаю nodetool status:

```
--  Address    Load       Tokens       Owns    Host ID                               Rack
UN  10.1.0.17  323.82 KiB  256          ?       0421400f-7021-46b3-a45d-7586174c54a9  rack1
UN  10.1.0.19  327.54 KiB  256          ?       6c4b9c50-6a66-41f7-86ba-f94549cb4699  rack1
UN  10.1.0.18  317.97 KiB  256          ?       290db916-2a2d-432d-ab5b-5eaedfe835f9  rack1
```

Там же проверяю подключение с помощью cqlsh:
```
cqlsh -u admin -p admin test-cassandra-cluster
```

Для запуска cassandra-stress, в powershell выполняю:
```
kubectl run --namespace default test-cassandra-cluster-client --rm --tty -i --restart='Never' --image docker.io/bitnami/cassandra:3.11.9-debian-10-r0 -- bash
```
Запускается новый контейнер, проверяю в нём подключение cqlsh той же командой, всё ок.

Запускаю cassandra-stress, указываю адрес кластера и учётные данные, операция write, количество 1 млн:
```
/opt/bitnami/cassandra/tools/bin/cassandra-stress write n=1000000 -mode native cql3 user=admin password=admin -node test-cassandra-cluster
```
Результаты:
```
Running WRITE with 200 threads for 1000000 iteration

Results:
Op rate                   :    4,239 op/s  [WRITE: 4,239 op/s]
Partition rate            :    4,239 pk/s  [WRITE: 4,239 pk/s]
Row rate                  :    4,239 row/s [WRITE: 4,239 row/s]
Latency mean              :   46.9 ms [WRITE: 46.9 ms]
Latency median            :   30.4 ms [WRITE: 30.4 ms]
Latency 95th percentile   :  102.2 ms [WRITE: 102.2 ms]
Latency 99th percentile   :  198.8 ms [WRITE: 198.8 ms]
Latency 99.9th percentile : 1863.3 ms [WRITE: 1,863.3 ms]
Latency max               : 3579.8 ms [WRITE: 3,579.8 ms]
Total partitions          :  1,000,000 [WRITE: 1,000,000]
Total errors              :          0 [WRITE: 0]
Total GC count            : 0
Total GC memory           : 0.000 KiB
Total GC time             :    0.0 seconds
Avg GC time               :    NaN ms
StdDev GC time            :    0.0 ms
Total operation time      : 00:03:55
```

После теста nodetool status показывает:
```
--  Address    Load       Tokens       Owns    Host ID                               Rack
UN  10.1.0.17  56.06 MiB  256          ?       0421400f-7021-46b3-a45d-7586174c54a9  rack1
UN  10.1.0.19  55.1 MiB   256          ?       6c4b9c50-6a66-41f7-86ba-f94549cb4699  rack1
UN  10.1.0.18  54.9 MiB   256          ?       290db916-2a2d-432d-ab5b-5eaedfe835f9  rack1
```

Второй тест на чтение, количество операций 100 тысяч:
```
/opt/bitnami/cassandra/tools/bin/cassandra-stress read n=100000 -mode native cql3 user=admin password=admin -node test-cassandra-cluster
```
Результаты:
```
Running with 4 threadCount
Running READ with 4 threads for 100000 iteration

Results:
Op rate                   :      978 op/s  [READ: 978 op/s]
Partition rate            :      978 pk/s  [READ: 978 pk/s]
Row rate                  :      978 row/s [READ: 978 row/s]
Latency mean              :    4.0 ms [READ: 4.0 ms]
Latency median            :    2.3 ms [READ: 2.3 ms]
Latency 95th percentile   :   13.1 ms [READ: 13.1 ms]
Latency 99th percentile   :   22.6 ms [READ: 22.6 ms]
Latency 99.9th percentile :   40.1 ms [READ: 40.1 ms]
Latency max               :  253.9 ms [READ: 253.9 ms]
Total partitions          :    100,000 [READ: 100,000]
Total errors              :          0 [READ: 0]
Total GC count            : 0
Total GC memory           : 0.000 KiB
Total GC time             :    0.0 seconds
Avg GC time               :    NaN ms
StdDev GC time            :    0.0 ms
Total operation time      : 00:01:42

Results:
Op rate                   :    1,634 op/s  [READ: 1,634 op/s]
Partition rate            :    1,634 pk/s  [READ: 1,634 pk/s]
Row rate                  :    1,634 row/s [READ: 1,634 row/s]
Latency mean              :    4.8 ms [READ: 4.8 ms]
Latency median            :    2.8 ms [READ: 2.8 ms]
Latency 95th percentile   :   15.1 ms [READ: 15.1 ms]
Latency 99th percentile   :   25.2 ms [READ: 25.2 ms]
Latency 99.9th percentile :   44.9 ms [READ: 44.9 ms]
Latency max               :  173.0 ms [READ: 173.0 ms]
Total partitions          :    100,000 [READ: 100,000]
Total errors              :          0 [READ: 0]
Total GC count            : 0
Total GC memory           : 0.000 KiB
Total GC time             :    0.0 seconds
Avg GC time               :    NaN ms
StdDev GC time            :    0.0 ms
Total operation time      : 00:01:01

Improvement over 4 threadCount: 67%

...

Results:
Op rate                   :    5,519 op/s  [READ: 5,519 op/s]
Partition rate            :    5,519 pk/s  [READ: 5,519 pk/s]
Row rate                  :    5,519 row/s [READ: 5,519 row/s]
Latency mean              :   46.0 ms [READ: 46.0 ms]
Latency median            :   36.9 ms [READ: 36.9 ms]
Latency 95th percentile   :  111.0 ms [READ: 111.0 ms]
Latency 99th percentile   :  162.5 ms [READ: 162.5 ms]
Latency 99.9th percentile :  352.6 ms [READ: 352.6 ms]
Latency max               :  491.3 ms [READ: 491.3 ms]
Total partitions          :    100,000 [READ: 100,000]
Total errors              :          0 [READ: 0]
Total GC count            : 0
Total GC memory           : 0.000 KiB
Total GC time             :    0.0 seconds
Avg GC time               :    NaN ms
StdDev GC time            :    0.0 ms
Total operation time      : 00:00:18

Improvement over 181 threadCount: -2%

...
Running READ with 913 threads for 100000 iteration
Results:
Op rate                   :    8,720 op/s  [READ: 8,720 op/s]
Partition rate            :    8,720 pk/s  [READ: 8,720 pk/s]
Row rate                  :    8,720 row/s [READ: 8,720 row/s]
Latency mean              :   92.6 ms [READ: 92.6 ms]
Latency median            :   70.5 ms [READ: 70.5 ms]
Latency 95th percentile   :  237.2 ms [READ: 237.2 ms]
Latency 99th percentile   :  472.1 ms [READ: 472.1 ms]
Latency 99.9th percentile :  624.4 ms [READ: 624.4 ms]
Latency max               :  739.8 ms [READ: 739.8 ms]
Total partitions          :    100,000 [READ: 100,000]
Total errors              :          0 [READ: 0]
Total GC count            : 0
Total GC memory           : 0.000 KiB
Total GC time             :    0.0 seconds
Avg GC time               :    NaN ms
StdDev GC time            :    0.0 ms
Total operation time      : 00:00:11

Improvement over 609 threadCount: 47%
```

После завершения, удаляю созданный кластер:
```
helm del test-cassandra-cluster
```