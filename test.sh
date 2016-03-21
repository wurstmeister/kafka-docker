#!/bin/bash

: ${KAFKA_VERSION:=0.9.0.1}
: ${SCALA_VERSION:=2.11}
KAFKA_HOME=/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}

CONTAINER=${1:-kafkadocker_kafka_1}
DOCKEREXEC="docker exec $CONTAINER"

ZK=zk:2181
KF_HOST=kafka
KF_BROKERS=$KF_HOST:9092

$DOCKEREXEC $KAFKA_HOME/bin/kafka-topics.sh --zookeeper=$ZK --list
$DOCKEREXEC $KAFKA_HOME/bin/kafka-topics.sh --zookeeper=$ZK --describe --topic=test
$DOCKEREXEC bash -c "IP=\$(eval \$HOSTNAME_COMMAND); echo \$IP $KF_HOST >> /etc/hosts; cat /etc/hosts"
$DOCKEREXEC bash -c "echo \"test msg1 \`date\`\" | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list=$KF_BROKERS --topic=test"
$DOCKEREXEC bash -c "echo \"test msg2 \`date\`\" | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list=$KF_BROKERS --topic=test"
$DOCKEREXEC bash -c "echo \"test msg3 \`date\`\" | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list=$KF_BROKERS --topic=test"
$DOCKEREXEC $KAFKA_HOME/bin/kafka-console-consumer.sh --zookeeper=$ZK --topic=test --from-beginning
