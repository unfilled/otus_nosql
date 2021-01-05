# 11 Tarantool

С помощью [официальной документации](https://www.tarantool.io/ru/download/os-installation/ubuntu/) был установлен stand-alone экземпляр Tarantool под WSL2 (Ubuntu 20.04):
```bash
curl -L https://tarantool.io/yhwFNL/release/2.5/installer.sh | bash

sudo apt-get install tarantool
```

С github был загружен модуль [expirationd](https://raw.githubusercontent.com/tarantool/expirationd/master/expirationd.lua) и скопирован в /usr/share/tarantool:
```bash
sudo cp /mnt/d/temp/expirationd.lua /usr/share/tarantool/expirationd.lua
```

Для "билинга" использовалась следующая структура данных:
1) таблица (box.space['balance']), содержащая счёт, текущий баланс и статус (active для счетов, с которых производятся ежесекундные списания и suspended для счетов, с нулевым и отрицательным балансом, списания с которых не производятся);
2) таблица (box.space['value']), содержащая одну запись - ежесекундный расход средств.

```
ffi = require('ffi')

box.cfg{}

v = box.schema.space.create('value')

v:format({
{name = 'value', type = 'double'}
})

v:create_index('primary', {type = 'hash', parts = {'value'}})

v:insert({ffi.cast('double', 10)})

b = box.schema.space.create('balance')

b:format({
{name = 'account_id', type = 'unsigned'},
{name = 'sum', type = 'double'},
{name = 'status', type = 'string'}
})

b:create_index('primary', {type = 'hash', parts = {'account_id'}})

b:insert{1, ffi.cast('double', 100), 'active'}
b:insert{2, ffi.cast('double', 200), 'active'}
b:insert{3, ffi.cast('double', 300), 'active'}
b:insert{4, ffi.cast('double', 400), 'active'}
b:insert{5, ffi.cast('double', 0), 'suspended'}

v:drop()
b:drop()
``` 

Были созданы:
1) процедура изменения ежесекундного расхода денег f_change_cost;
2) процедура добавления денег на баланс счёта f_cash_in.
```lua
function f_change_cost (space_id, value)
    box.begin()
    
    box.space[space_id]:truncate()
    box.space[space_id]:insert({value})
    
    box.commit()
    
    return "ok"
end

f_change_cost(v.id, ffi.cast('double', 15))

v:select{}


function f_cash_in (space_id, account_id, sum)    
    tuple_b = box.space[space_id]:select{account_id}
    if (tuple_b[1] == nil) then
        if (sum > 0) then
            box.space[space_id]:insert({account_id, sum, 'active'})
        else
            box.space[space_id]:insert({account_id, sum, 'suspended'})
        end
    else
        if (tuple_b[1][2] + sum > 0) then
            box.space[space_id]:update(account_id, {{'+', 2, sum}, {'=', 3, 'active'}})
        else
            box.space[space_id]:update(account_id, {{'+', 2, sum}, {'=', 3, 'suspended'}})
        end
    end    
end

f_cash_in(b.id, 6, ffi.cast('double', 0))
f_cash_in(b.id, 7, ffi.cast('double', 1000))
b:select{}

f_cash_in(b.id, 6, ffi.cast('double', 10))
b:select{}
```

Был подключен модуль expirationd, в который передаётся функция f_get_payment (осуществляет списание с активного счёта и если баланс стал нулевым или ушёл в минус, меняет статус на 'suspended', чтобы следующие списания с этого счёта не проводились; всегда возвращает false).

```lua
expirationd = require('expirationd')

function f_get_payment(args, tuple)

    va = box.space['value']:select{}

    new_sum = tuple[2] - va[1][1]
    new_status = 'active'
    
    if (tuple[3] == 'suspended') then  
        return false
    end
    
    if (new_sum <= 0) then
        new_status = 'suspended'
    end
    
    box.space['balance']:update(tuple[1], {{'-', 2, va[1][1]}, {'=', 3, new_status}})
    
    if new_status = 'suspended' then require('http.client').new():request('GET', 'http://127.0.0.1', nil, {tuple[1]}) end
    
    return false

end

expirationd.run_task('billing', b.id, f_get_payment)

expirationd.task_stats()
expirationd.kill_task('billing')
```

Изначально я пытался при запуске таска передать идентификаторы спейсов через {args = {b.id, v.id}} и использовать их внутри функции f_get_payment, но постоянно получал ошибку:
```
- error: '/usr/share/tarantool/expirationd.lua:358: process_expired_tuple is not defined,
    please provide a purge function'
```
и даже явное создание функции для удаления "устаревших" строк и передача её таску, не помогали - возвращалась та же ошибка. 

[Код целиком](https://127.0.0.1), в нём:
1. создаются спейсы;
2. заполняются данными;
3. создаются функции, необходимые в ДЗ (изменение расхода денег в секунду и добавление денег на счёт);
4. создаётся функция ежесекундного списания и запускается таск;
5. через 10 секунд выводится содержимое спейса balance (суммы на счетах);
6. добавляется новый счёт с 100 на счету, изменяется сумма ежесекундного списания на 35;
7. через 5 секунд выыодится содержимое спейса balance;
8. удаляется таск, удаляются спейсы.
