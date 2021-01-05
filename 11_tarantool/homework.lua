ffi = require('ffi')
expirationd = require('expirationd')
fiber = require('fiber')

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

function f_change_cost (space_id, value)
    box.begin()
    
    box.space[space_id]:truncate()
    box.space[space_id]:insert({value})
    
    box.commit()
    
    return "ok"
end

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

b:select{}

expirationd.run_task('billing', b.id, f_get_payment)

fiber.sleep(10)

b:select{}
f_cash_in(b.id, 6, ffi.cast('double', 100))
f_change_cost(v.id, ffi.cast('double', 35))
b:select{}

fiber.sleep(4)

b:select{}

expirationd.task_stats()

expirationd.kill_task('billing')

v:drop()
b:drop()