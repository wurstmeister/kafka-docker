Tests
=====

This directory contains some basic tests to validate functionality after building.

To execute
----------

```
cd test
# if kafka veresion < 3
docker-compose -f docker-compose.yml -f docker-compose-kafka.yml up -d zookeeper kafka_1 kafka_2
# if kafka veresion >= 3
docker-compose -f docker-compose.yml -f docker-compose-kafka3.yml up -d zookeeper kafka_1 kafka_2
./runAllTests.sh
```

Run selected tests
------------------

### Kafka

```
docker-compose run -e BROKER_LIST=$(./internal-broker-list.sh) --rm kafkatest <testname pattern>
```

### Kafkacat

```
BROKER_LIST=$(./internal-broker-list.sh) [KAFKA_VERSION=<version>] docker-compose run --rm kafkacattest <testname pattern>
```

-	`<version>` is the kafka version that the tests are targeting. Normally this environment variable should not need to be specified. The default should be the latest image version. Added for CI support.
-	`<testname pattern>` can be an individual filename, or a pattern such as `'0.0/test.start-kafka*.kafka.sh'`
