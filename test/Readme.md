Tests
=====

This directory contains some basic tests to validate functionality after building.

To execute
----------

```
cd test
docker-compose up -d zookeeper kafka
docker-compose scale kafka=2    # or however many nodes you want
BROKER_LIST=$(./internal-broker-list.sh) docker-compose run tests
```
