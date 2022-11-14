#!/bin/bash
set -ex  #fail fast

CASSANDRA_VERSION=`docker-compose config | grep 'image:.*cassandra:' | head -1 | awk -F":" '{ print $NF}'`
docker image pull cassandra:${CASSANDRA_VERSION}

docker run --rm -d --name tmp cassandra:${CASSANDRA_VERSION}
docker cp tmp:/etc/cassandra/ etc_cassandra_${CASSANDRA_VERSION}_vanilla/
docker cp tmp:/opt/cassandra/bin/ bin_cassandra_${CASSANDRA_VERSION}_vanilla/
docker stop tmp

etc_volumes=`docker-compose config | grep "source:.*etc" | awk -F ":" '{ print $2}' | awk '{ print $NF}'`
for v in ${etc_volumes}; do
   mkdir -p ${v}
   cp -r etc_cassandra_${CASSANDRA_VERSION}_vanilla/*.* ${v}/
done

sed -e 's?exec ?LD_PRELOAD=/opt/cassandra/bin/libfaketime.so.1 exec ?g' -I bac bin_cassandra_${CASSANDRA_VERSION}_vanilla/cassandra
sed -e 's?conn.connect()?conn.connect()\n            self.session.use_client_timestamp=False?g' -I bac bin_cassandra_${CASSANDRA_VERSION}_vanilla/cqlsh.py

bin_volumes=`docker-compose config | grep "source:.*bin" | awk -F ":" '{ print $2}' | awk '{ print $NF}'`
for v in ${bin_volumes}; do
   mkdir -p ${v}
   cp -r bin_cassandra_${CASSANDRA_VERSION}_vanilla/* ${v}/
   cp libfaketime.so.1 ${v}/
done