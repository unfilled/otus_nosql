# MongoDB

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

На [github](https://github.com/ozlerhakan/mongodb-json-files) были найдены открытые датасеты для загрузки в mongodb. Был загружен и импортирован датасет students.json. 

```bash
mongoimport --db=temp --collection=students --file=/mnt/d/mongo/dataset/students.json
```

Выбранный датасет состоит из 200 документов, каждый из которых содержит имя студента (name) и массив его оценок (scores), содержащий оценку и "тип" (exam, homework, quiz).  

## Добавление новых данных

```bash
mongo
```

С помощью db.collection.insert() было добавлено 3 документа:

```mongo
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

Дублирующйся документ с id=202 был пропущен с сообщением об ошибке "E11000 duplicate key error collection: temp.students index: _id_ dup key: { _id: 202.0 }", документ с id=201 был успешно добавлен в коллекцию.

