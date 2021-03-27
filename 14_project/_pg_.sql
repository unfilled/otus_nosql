CREATE USER otus WITH PASSWORD "otus";

CREATE DATABASE otus;

ALTER DATABASE otus OWNER TO otus;

/etc/postgresql/12/main/pg_hba.conf
host    all             otus            0.0.0.0/0               md5



CREATE TABLE test (id bigserial PRIMARY KEY, eventdate timestamp without time zone default now(), someuuid uuid, data jsonb);

CREATE INDEX ix_someuuid ON test (someuuid);

CREATE INDEX ix_eventdate ON test (eventdate);
