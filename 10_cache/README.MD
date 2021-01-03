# 10 Cache

Была установлена community-версия Cache под Windows 10 из дистрибутива с [официального сайта](https://download.intersystems.com/download/download.csp).

Были созадны пустая БД SHOP и область SHOP.

Скачан Visual Studio Code и добавлено расширение InterSystems ObjectScript Extension Pack.

Далее был создан класс [Company](https://github.com/unfilled/otus_nosql/blob/master/10_cache/Company.cls)

В терминале была создана первая запись:
```
set company = ##class(Shop.Company).%New()

set company.Name = "OTUS"

set company.Phone = "+7 499 938-92-02"

set company.DeliveryAddress = "г.Москва, улица Ленина, 1-1"

do $system.OBJ.Dump(company)

+----------------- general information ---------------
|      oref value: 1
|      class name: Shop.Company
| reference count: 1
+----------------- attribute values ------------------
|       %Concurrency = 1  <Set>
|    DeliveryAddress = "г.Москва, улица Ленина, 1-1"
|               Name = "OTUS"
|              Phone = "+7 499 938-92-02"
+-----------------------------------------------------

write company.%Id()

set status = company.%Save()

write status

1

write company.%Id()
1
```

На портале, в разделе SQL, с помощью запроса была добавлена вторая запись:

```
INSERT INTO Shop.Company (Name, Phone, DeliveryAddress)
VALUES ('InterSystemsRUS', '+7 (495) 967-0088', 'Москва, Краснопресненская наб., 12
ЦМТ, подъезд 7, офис 609')
``` 

В терминале были добавлены ещё 10 записей:

```
do ##class(Shop.Company).Populate(10)
```

На портале был выполнен запрос 1:
```
SELECT *
FROM Shop.Company
```
и получен следующий ![скриншот](https://github.com/unfilled/otus_nosql/blob/master/10_cache/screenshots/1_select.png)
