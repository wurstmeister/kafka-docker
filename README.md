kafka-docker
============

Dockerfile for building a kafka cluster.

It uses the current trunk version of kafka 0.8.1 because we need: [https://issues.apache.org/jira/browse/KAFKA-1092](https://issues.apache.org/jira/browse/KAFKA-1092)

The image is available directly from https://index.docker.io

##Quickstart

```
export START_SCRIPT=https://raw2.github.com/wurstmeister/kafka-docker/master/start-broker.sh
curl -Ls $START_SCRIPT | bash /dev/stdin 1 9092 localhost
```

##Tutorial

[http://wurstmeister.github.io/kafka-docker/](http://wurstmeister.github.io/kafka-docker/)


