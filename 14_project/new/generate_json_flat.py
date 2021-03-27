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
            'starts': fake.date_between(start_date='-5y', end_date = 'today'),
            'userid' : fake.random_int(max = 20000),
            'filial' : fake.city(),
            'region' : fake.country_code(),            
            'correlation_id' : fake.uuid4(),
            'card_provider' : fake.credit_card_provider(),
            'license_plate' : fake.license_plate(),
            'md5' : fake.md5(raw_output=False),
            'firstname' : fake.first_name(),
            'lastname' : fake.last_name(),
            'sex' : fake.random_choices(elements = ('F', 'M'), length = 1),
            "birthdate" : fake.date_between(start_date='-75y', end_date = '-10y'),
            'job' : fake.job(),
            'company' : fake.company(),
            'ssn' : fake.ssn(),
            'city' : fake.city(),
            'street' : fake.street_name(),
            'address' : fake.address(),
            "mail" : fake.ascii_free_email(),         
            'maker' : fake.vehicle_make(),
            'model' : fake.vehicle_model(),
            'category' : fake.vehicle_category(),
            'year' : fake.vehicle_year(),     
            'premium' : fake.random_int(min=900, max = 50000),
            'cases' : fake.random_digit(),
            'payout' : fake.random_int (min = 0, max = 400000)
        }
        
filename = 'data_flat'
length = 2
i = 0
fake = Faker()
fake.add_provider(VehicleProvider)
egen = element_generator (length, fake)
with open ('E:\\temp\\%s_%s_%s.json' % (filename, str(length), str(sys.argv[1])), 'w') as o:
    o.write('[')
    for e in egen:
        json.dump(e, o, default=str)
        i = i + 1
        if i < length:
            o.write(',')
        else:
            o.write(']')
