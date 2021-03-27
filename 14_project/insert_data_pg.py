import psycopg2
import json
import uuid
import sys

x = 0
u = str(uuid.uuid4())

with open ('test_%s_%s.json' % (str(sys.argv[1]), str(sys.argv[2])), 'r') as f:
    j = json.load(f)
    with psycopg2.connect(dbname = 'otus', user = 'otus', password = 'otus', host = 'localhost') as pg:
        pg.set_session (autocommit = True)
        cursor = pg.cursor()

        for e in j:
            x = x + 1
            if x % 10 == 0:
                u = str(uuid.uuid4())
            cursor.execute('insert into test(someuuid, data) values (%s, %s)', [u, json.dumps(e)])
