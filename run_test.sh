#!/bin/bash

docker exec -it cass1 cqlsh -e "
  CREATE KEYSPACE IF NOT EXISTS ordering_test
    WITH REPLICATION = {
     'class' : 'SimpleStrategy',
     'replication_factor' : 3
    };

  CREATE TABLE IF NOT EXISTS ordering_test.ordering_test (
       key text,
       value text,
       PRIMARY KEY (key)
   )
"

docker exec -it cass1 cqlsh -e "CONSISTENCY ALL; INSERT INTO ordering_test.ordering_test(key, value) VALUES('key', 'value_1'); SELECT dateof(now()) FROM system.local "
echo "Inserted 'value_1'"

docker exec -it cass2 cqlsh -e "CONSISTENCY ALL; INSERT INTO ordering_test.ordering_test(key, value) VALUES('key', 'value_2'); SELECT dateof(now()) FROM system.local"
echo "Inserted 'value_2'"

echo "Selecting current value"
docker exec -it cass3 cqlsh -e "CONSISTENCY ALL; SELECT * FROM ordering_test.ordering_test; SELECT dateof(now()) FROM system.local"