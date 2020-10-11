# ДЗ2 MongoDB

## Установка MongoDB CE 4.4 на Ubuntu 20.04 (WSL2)

Согласно [официальной документации](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/) были выполнены следующие шаги:

```bash
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

sudo apt-get update

sudo apt-get install -y mongodb-org
```

## Запуск сервера MongoDB

Параметры mongod описаны в [официальной документации](https://docs.mongodb.com/manual/tutorial/manage-mongodb-processes/).

В /var/lib был создан каталог mongodb и его подкаталог db1, сервер запущен в дочернем процессе

```bash
sudo mkdir /var/lib/mongodb/db1
sudo mongod --dbpath /var/lib/mongodb/db1 --logpath /var/log/mongodb_db1.log --port 27017 --fork
```

## Предварительная загрузка данных

На [github](https://github.com/ozlerhakan/mongodb-json-files) были найдены открытые датасеты для загрузки в mongodb. Был загружен и импортирован датасет [students.json](https://github.com/ozlerhakan/mongodb-json-files/blob/master/datasets/students.json). 

```bash
mongoimport --db=temp --collection=students --file=/mnt/d/mongo/dataset/students.json
```

Выбранный датасет состоит из 200 документов, каждый из которых содержит имя студента (name) и массив его оценок (scores), содержащий оценку и "тип" (exam, homework, quiz).  

## Добавление новых данных

Сервер запущен на 127.0.0.1, порт стандартный 27017, авторизация не настроена и не требуется, поэтому для подключения достаточно запустить утилиту mongo:

```bash
mongo
```

В первую очередь была выбрана БД temp (в которую на предыдущем этапе был загружен датасет), затем, с помощью db.collection.insert() было добавлено 3 документа:

```mongo
use temp;

db.students.insert(
{
	"_id":200, "name": "Oleg Aronov", "scores": [
	{"score": 14.31, "type":"exam"},
	{"score": 81.1212, "type":"quiz"},
	{"score": 55, "type":"homework"}]
});

db.students.insert( 
[
	{
		"_id":202, "name": "Piter Parker", "scores": [ 
		{"score": 99.99, "type":"exam"}, 
		{"score": 99.98, "type":"quiz"}, 
		{"score": 99.99999, "type":"homework"} 
		] 
	}, 
	{
		"_id":203, "name": "Iron Man", "scores": [ 
		{"score": 100, "type":"exam"}, 
		{"score": 100, "type":"quiz"}, 
		{"score": 100, "type":"homework"} 
		] 
	}
] 
);
```

id = 201 был пропущен, чтобы проверить будет ли успешной такая вставка:

```mongo
db.students.insert( 
[
	{
		"_id":202, "name": "Piter Parker", "scores": [ 
		{"score": 99.99, "type":"exam"}, 
		{"score": 99.98, "type":"quiz"}, 
		{"score": 99.99999, "type":"homework"} 
		] 
	}, 
	{
		"_id":201, "name": "Incredible Hulk", "scores": [ 
		{"score": 0.1, "type":"exam"}, 
		{"score": 0.2, "type":"quiz"}, 
		{"score": 0, "type":"homework"} 
		] 
	}
] 
);

```

Документ с id=201 не был вставлен, тогда была произведена вставка с ordered = false:

```mongo
db.students.insert( 
[
	{
		"_id":202, "name": "Piter Parker", "scores": [ 
		{"score": 99.99, "type":"exam"}, 
		{"score": 99.98, "type":"quiz"}, 
		{"score": 99.99999, "type":"homework"} 
		] 
	}, 
	{
		"_id":201, "name": "Incredible Hulk", "scores": [ 
		{"score": 0.1, "type":"exam"}, 
		{"score": 0.2, "type":"quiz"}, 
		{"score": 0, "type":"homework"} 
		] 
	}
],
{ordered: false}
);
```

Документ с id=201 был успешно добавлен в коллекцию, дублирующийся документ с id=202 не был вставлен, получено сообщение об ошибке:
```mongo
"E11000 duplicate key error collection: temp.students index: _id_ dup key: { _id: 202.0 }"
```

Было добавлено несколько документов с помощью insertOne() и insertMany():
```mongo
db.students.insertOne(
	{
		"_id":204, "name": "Captain America", "scores": [ 
		{"score": 91.9, "type":"exam"}, 
		{"score": 65.4, "type":"quiz"}, 
		{"score": 87.123132, "type":"homework"} 
		] 
	}
);

db.students.insertMany( 
[
	{
		"_id":205, "name": "Ant Man", "scores": [ 
		{"score": 83.32, "type":"exam"}, 
		{"score": 76.12, "type":"quiz"}, 
		{"score": 64.112, "type":"homework"} 
		] 
	}, 
	{
		"_id":206, "name": "Black Widow", "scores": [ 
		{"score": 87, "type":"exam"}, 
		{"score": 89.99, "type":"quiz"}, 
		{"score": 88.46, "type":"homework"} 
		] 
	},
	{
		"_id":207, "name": "Star Lord", "scores": [ 
		{"score": 12.1, "type":"exam"}, 
		{"score": 19.333, "type":"quiz"}, 
		{"score": 31.00001, "type":"homework"} 
		] 
	}
]
);
```

## Запросы к данным

Для поиска документов в коллекции использовался [db.collection.find()](https://docs.mongodb.com/manual/reference/method/db.collection.find/).

Вывод всех документов в коллекции (выводятся первые 20 документов, следующие выводятся только при вводе it):
```mongo
db.students.find();
```
Поиск студента по имени:
```mongo
db.students.find({"name": "Oleg Aronov"});
```
Поиск всех студентов, имеющих хотя бы одну оценку больше 98:

```mongo
db.students.find({"scores.score": {$gt : 98}});
```
Поиск всех студентов, имеющих хотя бы одну оценку больше 98 и вывод только их имени:
```mongo
db.students.find({"scores.score": {$gt : 98}}, {"name" : 1, _id : 0});
```
Поиск всех студентов, у которых все оценки больше 90:
```mongo
db.students.find({"scores.score": {$not: {$lte : 90}}});
```
Подсчёт количества документов в коллекции:
```mongo
db.students.find().count();
```
Подсчёт количества студентов, у которых все оценки больше 90:
```mongo
db.students.find({"scores.score": {$not: {$lte : 90}}}).count();
```
Поиск студентов, у которых либо все оценки больше 90, либо все оценки меньше 35.
```mongo
db.students.find ({$or : [{"scores.score" : {$not : {$lte : 90}}}, {"scores.score" : {$not : {$gte : 35}}}]});
```
Поиск студентов, имя которых начинается на "A" ($options:'i' проверяет соответствие выражению без учёта регистра).
```mongo
db.students.find ({"name" : {$regex : /^a/, $options: 'i'}});
```
Подсчёт максимальной/минимальной/средней оценки по категориям (exam, homework, quiz)

Подсчёт средней оценки студента и вывод 5 студентов с максимальными средними оценками

## Обновление данных

## Создание индексов

## Сравнение производительности


