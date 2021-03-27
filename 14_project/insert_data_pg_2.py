import psycopg2
import json
import uuid
import sys

with open ('test2_%s_%s.json' % (str(sys.argv[1]), str(sys.argv[2])), 'r') as f:
    j = json.load(f)
    with psycopg2.connect(dbname = 'otus', user = 'otus', password = 'otus', host = 'localhost') as pg:
        pg.set_session (autocommit = True)
        cursor = pg.cursor()

        for e in j:
            cursor.execute('insert into test(someuuid, eventdate, data) values (%s, %s, %s)', [str(e['someuuid']), str(e['eventdate']), json.dumps(e)])
            
            