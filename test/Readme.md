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
BROKER_LIST=$(./internal-broker-list.sh) [KAFKA_VERSION=<version>] docker-compose run --rm kafkacattest <testname pattern>
```

-	`<version>` is the kafka version that the tests are targeting. Normally this environment variable should not need to be specified. The default should be the latest image version. Added for CI support.
-	`<testname pattern>` can be an individual filename, or a pattern such as `'0.0/test.start-kafka*.kafka.sh'`
