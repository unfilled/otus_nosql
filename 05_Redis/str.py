import json
import redis
import datetime

f = open ('/tmp/big.json')
r = redis.Redis ('localhost')

j = json.load(f)

print (datetime.datetime.now())
r.set ("key", json.dumps(j))
print (datetime.datetime.now())

#2020-11-26 22:11:13.999378
#2020-11-26 22:11:14.236887

s = ''
print (datetime.datetime.now())
for key in r.scan_iter():
    s += str(key)
print (datetime.datetime.now())

#2020-11-26 22:47:10.890073
#2020-11-26 22:47:10.890493