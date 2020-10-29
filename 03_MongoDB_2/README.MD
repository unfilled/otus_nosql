# ДЗ2 MongoDB 2

Создаём каталоги для всех будущих реплика-сетов

```bash
mkdir /tmp/data
cd /tmp/data
mkdir cfg1 cfg2 cfg3 rs11 rs12 rs13 rs21 rs22 rs23 rs31 rs32 rs33
```

Создаём keyfile, который будет использоваться всеми монгами
```bash
openssl rand -base64 756 > /tmp/data/k.f
chmod 400 /tmp/data/k.f
```

Запускаем config-server'а, формируем replica-set cfg, создаём пользователя-администратора с максимальными привилегиями (роль root)
```bash
mongod --configsvr --dbpath /tmp/data/cfg1 --port 26001 --replSet rsCfg --fork --logpath /tmp/data/cfg1.log 
mongod --configsvr --dbpath /tmp/data/cfg2 --port 26002 --replSet rsCfg --fork --logpath /tmp/data/cfg2.log 
mongod --configsvr --dbpath /tmp/data/cfg3 --port 26003 --replSet rsCfg --fork --logpath /tmp/data/cfg3.log 
```

```mongo
mongo --port 26001
rs.initiate(
    {
    "_id" : "rsCfg", 
    configsvr: true, 
    members : 
        [
        {"_id" : 0, host : "127.0.0.1:26001"},
        {"_id" : 1, host : "127.0.0.1:26002"},
        {"_id" : 2, host : "127.0.0.1:26003"}
        ]
    }
);

use admin;

db.createUser(
  {
    user: "adm",
    pwd: "1", 
    roles: [ { role: "root", db: "admin" } ]
  }
)
```mongo

Запускаем три реплика-сета, которые будут шардами, создаю такого же пользователя-администратора

```bash
mongod --dbpath /tmp/data/rs11 --port 27101 --replSet rs1 --fork --logpath /tmp/data/rs11.log 
mongod --dbpath /tmp/data/rs12 --port 27102 --replSet rs1 --fork --logpath /tmp/data/rs12.log 
mongod --dbpath /tmp/data/rs13 --port 27103 --replSet rs1 --fork --logpath /tmp/data/rs13.log 

mongo --port 27101
```

```mongo
rs.initiate(
    {
    "_id" : "rs1", 
    members : 
        [
        {"_id" : 0, host : "127.0.0.1:27101"},
        {"_id" : 1, host : "127.0.0.1:27102"},
        {"_id" : 2, host : "127.0.0.1:27103"}
        ]
    }
);

use admin;

db.createUser(
    {
    user: "adm",
    pwd: "1", 
    roles: [ { role: "root", db: "admin" } ]
    }
)
```

```bash
mongod --dbpath /tmp/data/rs21 --port 27201 --replSet rs2 --fork --logpath /tmp/data/rs21.log 
mongod --dbpath /tmp/data/rs22 --port 27202 --replSet rs2 --fork --logpath /tmp/data/rs22.log 
mongod --dbpath /tmp/data/rs23 --port 27203 --replSet rs2 --fork --logpath /tmp/data/rs23.log 

mongo --port 27201
```

```mongo
rs.initiate(
    {
    "_id" : "rs2", 
    members : 
        [
        {"_id" : 0, host : "127.0.0.1:27201"},
        {"_id" : 1, host : "127.0.0.1:27202"},
        {"_id" : 2, host : "127.0.0.1:27203"}
        ]
    }
);

use admin;

db.createUser(
    {
    user: "adm",
    pwd: "1", 
    roles: [ { role: "root", db: "admin" } ]
    }
)
```

```bash
mongod --dbpath /tmp/data/rs31 --port 27301 --replSet rs3 --fork --logpath /tmp/data/rs31.log 
mongod --dbpath /tmp/data/rs32 --port 27302 --replSet rs3 --fork --logpath /tmp/data/rs32.log 
mongod --dbpath /tmp/data/rs33 --port 27303 --replSet rs3 --fork --logpath /tmp/data/rs33.log 

mongo --port 27301
```

```mongo
rs.initiate(
    {
    "_id" : "rs3", 
    members : 
        [
        {"_id" : 0, host : "127.0.0.1:27301"},
        {"_id" : 1, host : "127.0.0.1:27302"},
        {"_id" : 2, host : "127.0.0.1:27303"}
        ]
    }
);

use admin;

db.createUser(
    {
    user: "adm",
    pwd: "1", 
    roles: [ { role: "root", db: "admin" } ]
    }
)
```

Убиваю все запущенные экземпляры с помощью kill и запускаю заново с ключами --auth и --keyFile /tmp/data/k.f, указываю, что они запущены в качестве шард-серверов ключом --shardsvr

```bash
mongod --configsvr --dbpath /tmp/data/cfg1 --port 26001 --replSet rsCfg --fork --logpath /tmp/data/cfg1.log --auth --keyFile /tmp/data/k.f
mongod --configsvr --dbpath /tmp/data/cfg2 --port 26002 --replSet rsCfg --fork --logpath /tmp/data/cfg2.log --auth --keyFile /tmp/data/k.f
mongod --configsvr --dbpath /tmp/data/cfg3 --port 26003 --replSet rsCfg --fork --logpath /tmp/data/cfg3.log --auth --keyFile /tmp/data/k.f

mongod --dbpath /tmp/data/rs11 --port 27101 --replSet rs1 --fork --logpath /tmp/data/rs11.log --auth --keyFile /tmp/data/k.f --shardsvr
mongod --dbpath /tmp/data/rs12 --port 27102 --replSet rs1 --fork --logpath /tmp/data/rs12.log --auth --keyFile /tmp/data/k.f --shardsvr
mongod --dbpath /tmp/data/rs13 --port 27103 --replSet rs1 --fork --logpath /tmp/data/rs13.log --auth --keyFile /tmp/data/k.f --shardsvr

mongod --dbpath /tmp/data/rs21 --port 27201 --replSet rs2 --fork --logpath /tmp/data/rs21.log --auth --keyFile /tmp/data/k.f --shardsvr
mongod --dbpath /tmp/data/rs22 --port 27202 --replSet rs2 --fork --logpath /tmp/data/rs22.log --auth --keyFile /tmp/data/k.f --shardsvr
mongod --dbpath /tmp/data/rs23 --port 27203 --replSet rs2 --fork --logpath /tmp/data/rs23.log --auth --keyFile /tmp/data/k.f --shardsvr

mongod --dbpath /tmp/data/rs31 --port 27301 --replSet rs3 --fork --logpath /tmp/data/rs31.log --auth --keyFile /tmp/data/k.f --shardsvr
mongod --dbpath /tmp/data/rs32 --port 27302 --replSet rs3 --fork --logpath /tmp/data/rs32.log --auth --keyFile /tmp/data/k.f --shardsvr
mongod --dbpath /tmp/data/rs33 --port 27303 --replSet rs3 --fork --logpath /tmp/data/rs33.log --auth --keyFile /tmp/data/k.f --shardsvr
```

Проверяю, что реплика-сеты теперь требуют авторизации, подключаюсь к каждому и пытаюсь посмотреть статус реплика сета:
```bash
mongo --host rsCfg/127.0.0.1:26001,127.0.0.1:26002,127.0.0.1:26003
mongo --host rs1/127.0.0.1:27101,127.0.0.1:27102,127.0.0.1:27103
mongo --host rs2/127.0.0.1:27201,127.0.0.1:27202,127.0.0.1:27203
mongo --host rs3/127.0.0.1:27301,127.0.0.1:27302,127.0.0.1:27303
```

```mongo
rs.status();
```

во всех получаю ошибку авторизации, указываю в строке подключения пользователя, пароль и БД авторизации:
```bash
mongo --host rsCfg/127.0.0.1:26001,127.0.0.1:26002,127.0.0.1:26003 -u "adm" -p "1" --authenticationDatabase "admin"
mongo --host rs1/127.0.0.1:27101,127.0.0.1:27102,127.0.0.1:27103 -u "adm" -p "1" --authenticationDatabase "admin"
mongo --host rs2/127.0.0.1:27201,127.0.0.1:27202,127.0.0.1:27203 -u "adm" -p "1" --authenticationDatabase "admin"
mongo --host rs3/127.0.0.1:27301,127.0.0.1:27302,127.0.0.1:27303 -u "adm" -p "1" --authenticationDatabase "admin"
```
теперь rs.status() возвращает полную информацию о статусе реплика-сета.
Запускаю mongos, указываю rsCfg
```bash
mongos --configdb rsCfg/127.0.0.1:26001,127.0.0.1:26002,127.0.0.1:26003 --fork --logpath /tmp/data/mongos1.log
```

Поскольку сервера нуждаются в авторизации, запускаю с --keyFile 
```bash
mongos --configdb rsCfg/127.0.0.1:26001,127.0.0.1:26002,127.0.0.1:26003 --fork --logpath /tmp/data/mongos1.log --keyFile /tmp/data/k.f
```

Подключаюсь с использованием пользователя и пароля, добавляю созданные ранее реплика-сеты в качестве шардов, проверяю статус
```bash
mongo -u "adm" -p "1" --authenticationDatabase "admin"
```

```mongo
sh.addShard("rs1/127.0.0.1:27101,127.0.0.1:27102,127.0.0.1:27103");
sh.addShard("rs2/127.0.0.1:27201,127.0.0.1:27202,127.0.0.1:27203");
sh.addShard("rs3/127.0.0.1:27301,127.0.0.1:27302,127.0.0.1:27303");

sh.status();
```

"Разрешаю" шардинг БД mydb и bank. БД bank заполняю коллекцию по аналогии с тем, что было в задании, использую тот же ключ шардирования, тот же индекс и тоже включаю шардирование коллекции после вставки данных, единственное отличие - создаю 20000 документов, а не 200000. Смотрю статус шардирования, как документы "расползаются" по шардам. Перемещаются они по одному документу.

```mongo
sh.enableSharding("mydb")
sh.enableSharding("bank")

use bank
for (var i=0; i<20000; i++) { db.checks.insert({name: "Just Name", amount: Math.random()*100}) };
db.checks.ensureIndex({amount: 1});

use admin
db.runCommand({shardCollection: "bank.checks", key: {amount: 1}});
sh.status();
```

Вижу, что данные "расползлись" по шардам, пробую подключиться напрямую к реплика-сетам, чтобы посмотреть распределение. Подключаюсь к реплика-сетам поочерёдно, начиная с rs1 (primary для коллекции checks) и выполняю:
```mongo
db.checks.find().count();
```

На rs1 показывает 20000 (все документы), на rs2 9040, на rs3 попадаю на Secondary, который говорит:
not master and slaveOk=false
Выполняю rs.slaveOk(), но получаю сообщение, что slaveOk deprecated и нужно выполнять secondaryOk(), после этого получаю количество документов 9039. Выбрав случайный Id с rs3, выполняю запрос на rs1, rs2 и rs3:
```mongo
db.checks.find({"_id" : ObjectId("5f9962c2306991f616f76710")});
```

На rs1 и rs3 получаю по одной записи, на rs2 такая запись отсутствует.
Спустя несколько минут, данные пропадают с rs1, остаются только на rs3. Повторяю на rs1 
```mongo
db.checks.find().count();
```
Получаю 1921 запись.

В БД mydb создаю аналогичную коллекцию, но добавляю поле "s", которое может принимать только значения 1 / 2 / 3. Создаю индекс и шардирую по s и только после этого заполняю данными: с s=1 создаю 10000 документов, с s=2 15000 документов, с s=3 - 20000 документов. 
```mongo
use mydb
db.checks.ensureIndex({s : 1});

use admin
db.runCommand({shardCollection: "mydb.checks", key: {s: 1}});

use mydb
for (var i=0; i<10000; i++) { db.checks.insert({s: 1, name: "Just Name", amount: Math.random()*100}) };
for (var i=0; i<15000; i++) { db.checks.insert({s: 2, name: "Just Name", amount: Math.random()*100}) };
```

Параллельно, с помощью sh.status() смотрю как должны будут расположиться данные. Когда данные уже начали "расползаться", запускаю третью операцию вставки:
```mongo
for (var i=0; i<20000; i++) { db.checks.insert({s: 3, name: "Just Name", amount: Math.random()*100}) };
```

В результате, кластер перебалансировался, на каждом шарде остались документы только с одним "s".

## Отказоустойчивость. 
### Отказ одной ноды в replica-set
Выключаю primary во всех реплика-сетах, кроме конфиг-сервера.
Проверяю вставку и наличие данных на шардах.
На primary во всех rs:
```mongo
use admin
db.shutdownServer();
```
При подключении к mongos:
```mongo
use mydb
db.checks.insert([{"s":1, "name":"Another one", "amount":1},{"s":2, "name":"Another one", "amount":1}, {"s":3, "name":"Another one", "amount":1}]);
```

При подключении к replica-set'ам видно, что количество записей во всех rs увеличилось на 1. 

### Отказ не "primary"-шарда
Полностью выключаю один из шардов, проверяю вставку данных с ключом шардирования на этом и на других серверах. Возвращаю реплика-сет к жизни, проверяю, что данные на нём появились.

Выключаю все сервера, входящие в replica-set rs1, который не является primary для mydb.checks. Пробую вставить новые данные во все шарды:
```mongo
use mydb
db.checks.insert([{"s":1, "name":"Another one", "amount":1},{"s":2, "name":"Another one", "amount":1}, {"s":3, "name":"Another one", "amount":1}]);
```

Операция "висит", потом получаю сообщение об ошибке, при этом вставка в шарды, "обслуживающие" s=1 и s=2 проходит. Пробую вставить данные только в шарды для s=1 и s=2 
```mongo
db.checks.insert([{"s":1, "name":"Another one", "amount":1},{"s":2, "name":"Another one", "amount":1}]);
```
данные вставлены, доступны как при подключении в monogs, так и к rs3/rs2 напрямую. 
Перезапускаю rs1, пробую вставку во все 3 шарда, операция завершается успешно, данные доступны.

### Отказ "primary"-шарда
По аналогии с предыдущим "экспериментом" выключаю шард, который является primary для mydb.checks - в моём случае rs3. Проверяю sh.status().
Изменений в выводе sh.status() не обнаружено, проверяю вставку в коллекцию, но без s=1 (s=1 относится к rs3).
```mongo
db.checks.insert([{"s":2, "name":"Another one", "amount":1},{"s":3, "name":"Another one", "amount":1}]);
```
Данные вставлены успешно.
Запросы выполняются при подключении к mongos
```mongo
db.checks.find({"s":2}).count();
db.checks.find({"s":3}).count();
```
При этом, запрос, который должен обратиться в т.ч. к выключенному шарду, 
```mongo
db.checks.find()
```
завершается ошибкой.
