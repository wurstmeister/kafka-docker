Changelog
=========

Kafka features are not tied to a specific kafka-docker version (ideally all changes will be merged into all branches). Therefore, this changelog will track changes to the image by date.

08-Apr-2018
-----------

-	Issue #208 - Add `KAFKA_CREATE_TOPICS_SEPARATOR` to allow custom input, such as multi-line YAML.
-	Issue #298 - Fix SNAPPY compression support by adding glibc port back into image (removed when switching to openjdk base image in #7a25ade)

04-Apr-2018
-----------

-	Support `_{PORT_COMMAND}` placeholder.

03-Apr-2018
-----------

-	**BREAKING:** removed `KAFKA_ADVERTISED_PROTOCOL_NAME` and `KAFKA_PROTOCOL_NAME`. Use the canonical [Kafka Configuration](http://kafka.apache.org/documentation.html#brokerconfigs) instead.
-	Support `_{HOSTNAME_COMMAND}` placeholder.
-	**BREAKING:** Make `KAFKA_ZOOKEEPER_CONNECT` mandatory
