#!/bin/bash

sed -r -i "s/(zookeeper.connect)=(.*)/\1=$ZK_PORT_2181_TCP_ADDR/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/#(advertised.host.name)=(.*)/\1=$HOST_IP/g" $KAFKA_HOME/config/server.properties

for VAR in `env`
do
  if [[ $VAR == KAFKA_* ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    if [[ $kafka_name != 'home' ]]; then
      env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
      if grep -q "$kafka_name" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/^($kafka_name)=(.*)/\1=${!env_var}/g" $KAFKA_HOME/config/server.properties
      else
        echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
      fi
     fi
  fi
done

if [ "$KAFKA_HEAP_OPTS" != "" ]; then
    sed -r -i "s/^(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
fi

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
