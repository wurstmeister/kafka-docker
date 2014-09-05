#!/usr/bin/env bash

set -eu

# Get the IP address of the Docker container and set it as advertised.host.name
IP_ADDR=$(ifconfig eth0 | grep 'inet addr:' | cut -d':' -f2 | cut -d' ' -f1)
sed -r -i "s/#(advertised.host.name)=(.*)/\1=$IP_ADDR/g" \
    $KAFKA_HOME/config/server.properties

# Set Zookeeper assuming we link it with a Zookeeper container with alias zk.
sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ZK_PORT_2181_TCP_ADDR/g" \
    $KAFKA_HOME/config/server.properties

# Set Kafka to use user settings
sed -r -i "s/(broker.id)=(.*)/\1=$BROKER_ID/g" \
    $KAFKA_HOME/config/server.properties
sed -r -i "s/^(port)=(.*)/\1=$PORT/g" $KAFKA_HOME/config/server.properties

set +u
if [ ! -z $KAFKA_HEAP_OPTS ]; then
  sed -r -i "s/^(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" \
      $KAFKA_HOME/bin/kafka-server-start.sh
fi
set -u

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
