# Cassandra ordering with clock skew test

## What is this testing?
1. 3 node Cassandra cluster is started (Based on [digitals-io](https://github.com/digitalis-io/ccc) - thanks!).
2. Each node has some clock drift (check `FAKETIME` env variables in `docker-compose.yml`).
3. `run_test.sh` script creates test table and updates values for the same key from different nodes. Final value is not the last update due to clock differences.

## Running

WARNING: `setup-config.sh` tested only on macOS.

1. Run `./setup-config.sh` which:
   * Creates `etc`, `data` and `bin` directories that will be used by each cassandra node.
   * Adds `libfaketime.so.1` to bin dirs.
   * Modifies `cassandra` script to preload `libfaketime`. Thanks to that overriding time is possible. In each node time will be same as host +/- difference provided in `FAKETIME` env variables. 
   * Updates `cqlsh.py` so that client timestamps are disabled (forces cassandra to use coordinator timestamp).
2. Run containers: `docker-compose up -d`.
3. Check the cluster status after some time (3 nodes should be up): `docker exec cass1  nodetool status`.
4. Run test `./run_test.sh`.
