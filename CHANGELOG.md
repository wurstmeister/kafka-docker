Changelog
=========

Kafka features are not tied to a specific kafka-docker version (ideally all changes will be merged into all branches). Therefore, this changelog will track changes to the image by date.

04-Apr-2018
-----------

-	Support `_{PORT_COMMAND}` placeholder.

03-Apr-2018
-----------

-	**BREAKING:** removed `KAFKA_ADVERTISED_PROTOCOL_NAME` and `KAFKA_PROTOCOL_NAME`. Use the canonical [Kafka Configuration](http://kafka.apache.org/documentation.html#brokerconfigs) instead.
-	Support `_{HOSTNAME_COMMAND}` placeholder.
-	**BREAKING:** Make `KAFKA_ZOOKEEPER_CONNECT` mandatory
