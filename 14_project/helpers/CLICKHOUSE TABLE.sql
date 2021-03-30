CREATE DATABASE otus;

CREATE TABLE otus.test2 (
    `id`              UUID,
    `someuuid`        UUID,
    `starts`          Date,
    `userid`          Int32,
    `filial`          String,
    `region`          String,
    `correlation_id`  UUID,
    `company`         String,
    `card_provider`   String,
    `license_plate`   String,
    `md5`             String,
    `premium`         Int32,
    `cases`           Int32,
    `payout`          Int32,
    `job`             String,
    `insurer_company` String,
    `ssn`             FixedString(11),
    `residence`       String,
    `blood_group`     String,
    `username`        String,
    `name`            String,
    `sex`             FixedString(2),
    `address`         String,
    `mail`            String,
    `birthdate`       Date,
    `Make`            String,
    `Model`           String,
    `Category`        String,
    `Year`            Int32
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(starts)
ORDER BY tuple()
SETTINGS index_granularity = 8192;


clickhouse-client --query "INSERT INTO otus.test FORMAT TSV" --max_insert_block_size=100000 < /mnt/e/temp/otus.tsv