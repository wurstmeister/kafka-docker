kafka-docker
============

Dockerfile for building a kafka cluster.

It uses the current trunk version of kafka 0.8.1 because we need: [https://issues.apache.org/jira/browse/KAFKA-1092](https://issues.apache.org/jira/browse/KAFKA-1092)

The image is available directly from https://index.docker.io

##Usage

Start a broker (you can start as many brokers as your host system allows you to start)

- ```start-broker.sh <brokerId> <brokerPort> <hostIp>```

Your broker will be available under ```hostIp:brokerPort```. If you run docker on a linux box you should use the IP of your linux box.
If you run docker inside of vagrant you need to ensure that the ```brokerPort``` is forwarded and use the IP of the host running vagrant as
```hostIp```

To forward ports with vagrant use: ```$ FORWARD_DOCKER_PORTS='true' vagrant up```

By default a kafka broker uses 1GB of memory, so if you have trouble starting a broker, check ```docker logs```
for the container and make sure you've got enough memory available on your host

Start a kafka shell

- ```start-kafka-shell.sh```

Once you've started a shell you can run your favourite kafka commands, e.g.

- ```$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper $ZK_PORT_2181_TCP_ADDR```
- ```$KAFKA_HOME/bin/kafka-topics.sh --create --topic topic --partitions 2 --zookeeper $ZK_PORT_2181_TCP_ADDR --replication-factor 1```


