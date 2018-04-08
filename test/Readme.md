Tests
=====

This directory contains some basic tests to validate functionality after building.

To execute
----------

```
cd test
docker-compose up -d zookeeper
docker-compose scale kafka=2
./runAllTests.sh
```

Run selected tests
------------------

### Kafka

These tests can be run without Zookeeper or Kafka running.

```
docker-compose run --rm kafkatest <testname pattern>
```

### Kafkacat

These tests require zookeeper and kafka to be running

```
BROKER_LIST=$(./internal-broker-list.sh) docker-compose run --rm kafkacattest <testname pattern>
```

`<testname pattern>` can be an individual filename, or a pattern such as `'test.start-kafka*.kafka.sh'`
