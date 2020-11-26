import json
import redis
import datetime

f = open ('/tmp/big.json')
r = redis.Redis ('localhost')

j = json.load(f)

print (datetime.datetime.now())
for s in j:
    r.rpush ('list', json.dumps(s))
print (datetime.datetime.now())

#2020-11-26 22:32:49.000112
#2020-11-26 22:32:53.924118

print (datetime.datetime.now())
s = r.lrange('list', 0, -1)
print (datetime.datetime.now())

#2020-11-26 23:01:13.416610
#2020-11-26 23:01:13.580627

