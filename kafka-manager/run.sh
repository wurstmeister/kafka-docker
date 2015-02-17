#!/bin/bash

echo "Running on:"
echo $ZOOKEEPER_1_PORT_2181_TCP_ADDR
echo $ZOOKEEPER_1_PORT_2181_TCP_PORT

./kafka-manager -Dconfig.file=application.conf -Dkafka-manager.zkhosts="$ZOOKEEPER_1_PORT_2181_TCP_ADDR:$ZOOKEEPER_1_PORT_2181_TCP_PORT"
