import json
import sys
import datetime
from faker import Faker
from faker_vehicle import VehicleProvider
from decimal import Decimal


def element_generator (length, fake):
    for i in range(length):
        if i % 10 == 0:
            u = str(fake.uuid4())
        yield{
            'id': fake.uuid4(),
            'someuuid' : u,
            'eventdate': datetime.datetime.now(),
            'correlation_id': fake.uuid4(),
            'company': fake.company(),
            'iban': fake.iban(),
            'series': fake.random_choices(elements= (fake.random_digit(), fake.random_digit(),fake.random_digit(),fake.random_digit())),
            'md5': fake.md5(raw_output=False),
            'insurer': fake.profile(),
            'vehicle': fake.machine_object(),
            'drivers': fake.random_choices(elements=(fake.profile(), fake.profile(), fake.profile(), fake.profile(), fake.profile()))
        }
filename = 'test2'
length = 5
i = 0
fake = Faker()
fake.add_provider(VehicleProvider)
egen = element_generator (length, fake)
with open ('%s_%s_%s.json' % (filename, str(length), str(sys.argv[1])), 'w') as o:
    o.write('[')
    for e in egen:
        json.dump(e, o, default=str)
        i = i + 1
        if i < length:
            o.write(',')
        else:
            o.write(']')
