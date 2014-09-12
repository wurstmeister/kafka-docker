#!/bin/sh

# If HOST_IP is undefined, Discover current containers IP address
: ${HOST_IP:=$(cat /etc/hosts | awk '{print $2,$1}' | grep "^$HOSTNAME " | awk '{print $2}')}
export HOST_IP

# Discover the Host Machine's IP address via gateway (needs more testing)
export DOCKER_IP=$(netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}')


#original settings assignments for kafka server

sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ZK_PORT_2181_TCP_ADDR/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/(broker.id)=(.*)/\1=$BROKER_ID/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/#(advertised.host.name)=(.*)/\1=$HOST_IP/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/^(port)=(.*)/\1=$PORT/g" $KAFKA_HOME/config/server.properties

if [ "$KAFKA_HEAP_OPTS" != "" ]; then
    sed -r -i "s/^(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
fi

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
