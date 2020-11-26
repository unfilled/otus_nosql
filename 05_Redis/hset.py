import json
import redis
import datetime

f = open ('/tmp/big.json')
r = redis.Redis ('localhost')

j = json.load(f)

print (datetime.datetime.now())
for s in j:
    r.hset ('myhset', s['_id'], json.dumps(s))
print (datetime.datetime.now())

#2020-11-26 22:21:01.873924
#2020-11-26 22:21:04.728541

print (datetime.datetime.now())
s = r.hgetall('myhset')
print (datetime.datetime.now())

#2020-11-26 22:55:30.647908
#2020-11-26 22:55:31.037768