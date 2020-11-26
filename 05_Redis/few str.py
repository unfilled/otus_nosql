import json
import redis
import datetime

f = open ('/tmp/big.json')
r = redis.Redis ('localhost')

j = json.load(f)

print (datetime.datetime.now())
for s in j:
    r.set (s['_id'], json.dumps(s))
print (datetime.datetime.now())

#2020-11-26 22:15:58.460316
#2020-11-26 22:16:01.265393

s = ''
print (datetime.datetime.now())
for key in r.scan_iter():
    s += str(key)
print (datetime.datetime.now())

#2020-11-26 22:49:00.272465
#2020-11-26 22:49:00.593224