import json
import redis
import datetime

f = open ('/tmp/big.json')
r = redis.Redis ('localhost')

j = json.load(f)
i = 0
print (datetime.datetime.now())
for s in j:
    i += 1
    r.zadd ('zadd', {json.dumps(s) : i})
print (datetime.datetime.now())

#2020-11-26 22:40:29.556019
#2020-11-26 22:40:34.722939

print (datetime.datetime.now())
s = r.zrange('zadd', 0, -1)
print (datetime.datetime.now())

#2020-11-26 22:57:49.176077
#2020-11-26 22:57:49.342937