kafka-docker
============

Dockerfile for [Apache Kafka](http://kafka.apache.org/)

It uses the current trunk version of kafka 0.8.1 because we need: [https://issues.apache.org/jira/browse/KAFKA-1092](https://issues.apache.org/jira/browse/KAFKA-1092)

The image is available directly from https://index.docker.io

##Quickstart

```
export START_SCRIPT=https://raw2.github.com/wurstmeister/kafka-docker/master/start-broker.sh
curl -Ls $START_SCRIPT | bash /dev/stdin 1 9092 <your-host-ip>
```

Note: Do not use localhost or 127.0.0.1 as the host ip if you want to run multiple brokers. 

##Tutorial

[http://wurstmeister.github.io/kafka-docker/](http://wurstmeister.github.io/kafka-docker/)


##Building

To force an update of Kafka simply update ```LAST_GIT_UPDATE``` in the docker file (alternatively use the ```-no-cache``` option)
