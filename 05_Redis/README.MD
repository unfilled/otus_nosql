# 5 Redis

Redis установлен в Ubuntu 20.04 (WSL2) как stand-alone (apt install redis-server), для записи/чтения используется python3 и redis-py.

В качестве большого json использовался файл [json.big] (https://github.com/unfilled/otus_nosql/blob/master/05_Redis/big.json), размером около 25 МБ, сгенерированный с помощью  [генератора json'ов](https://www.json-generator.com)

Данные добавлялись и вычитывались соответствующими python-скриптами. 
Тестировалось время загрузки в:
* [одну строку](https://github.com/unfilled/otus_nosql/blob/master/05_Redis/str.py)
* [множество строк (каждый элемент массива в json - отдельный ключ)](https://github.com/unfilled/otus_nosql/blob/master/05_Redis/few%20str.py)
* [один хэш](https://github.com/unfilled/otus_nosql/blob/master/05_Redis/hset.py)
* [одно упорядоченное множество](https://github.com/unfilled/otus_nosql/blob/master/05_Redis/zadd.py), в качестве "ранга" использовался автоинкремент
* [один список](https://github.com/unfilled/otus_nosql/blob/master/05_Redis/list.py)   

После загрузки данные сразу вычитывались в переменную. Замеры выполнялись вручную (вывод времени "до" и "после" в скрипте). 
После каждого запуска, руками выполнялся flushall в redis-cli.

Запись / чтение одной строки:
```
Запись: 0,237509 сек
Чтение: 0,000420 сек
```

Запись / чтение нескольких строк (каждый элемент массива - ключ)
```
Запись: 2,805077 сек
Чтение: 0,320759 сек
```
Запись / чтение хэша:
```
Запись: 2,854617 сек
Чтение: 0,389860 сек
```

Запись / чтение упорядоченного множества:
```
Запись: 5,166920 сек
Чтение: 0,166833 сек
```

Запись / чтение списка:
```
Запись: 4,924006 сек
Чтение: 0,164017 сек
```
