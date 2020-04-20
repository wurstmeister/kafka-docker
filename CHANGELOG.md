Changelog
=========

Kafka features are not tied to a specific kafka-docker version (ideally all changes will be merged into all branches). Therefore, this changelog will track changes to the image by date.

20-Apr-2020
-----------

-	Add support for Kafka `2.5.0`

16-Mar-2020
-----------

-	Add support for Kafka `2.4.1`
-	Update glibc to `2.31-r0`

20-Dec-2019
-----------

-	Add support for Kafka `2.2.2`
-	Update glibc to 2.30-r0

17-Dec-2019
-----------

-	Add support for Kafka `2.4.0`

26-Oct-2019
-----------

-	Add support for Kafka `2.3.1`

28-Jun-2019
-----------

-	Add support for Kafka `2.3.0`

04-Jun-2019
-----------

-	Updated `2.2.x` version to Kafka `2.2.1`
-	Update base image to openjdk:8u212-jre-alpine

15-Apr-2019
-----------

-	Update base image to openjdk:8u201-jre-alpine

27-Mar-2019
-----------

-	Add support for Kafka `2.2.0`

21-Feb-2019
-----------

-	Update to latest Kafka: `2.1.1`
-	Update glibc to `2.29-r0`

21-Nov-2018
-----------

-	Update to latest Kafka: `2.1.0`
-	Set scala version for Kafka `2.1.0` and `2.0.1` to recommended `2.12`

10-Nov-2018
-----------

-	Update to Kafka `2.0.0` -> `2.0.1`.
-	Update glibc to `2.28-r0`
-	Update base image to openjdk:8u181-jre-alpine

29-Jun-2018
-----------

-	**MAJOR:** Use new docker image labelling (`<scala-version>-<kafka-version>`) and use travis to publish images.
-	Update base image to openjdk:8u171-jre-alpine

20-Apr-2018
-----------

-	Issue #312 - Fix conflict between KAFKA_xxx broker config values (e.g. KAFKA_JMX_OPTS) and container configuration options (e.g. KAFKA_CREATE_TOPICS)

19-Apr-2018
-----------

-	Issue #310 - Only return Apache download mirrors that can supply required kafka/scala version

11-Apr-2018
-----------

-	Issue #313 - Fix parsing of environment value substitution when spaces included.

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
