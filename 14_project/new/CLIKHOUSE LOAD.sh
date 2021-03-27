clickhouse-client --query "INSERT INTO otus.test FORMAT TSV" --max_insert_block_size=100000 < /mnt/e/temp/otus.tsv
 
clickhouse-client --query "OPTIMIZE TABLE otus.test FINAL"