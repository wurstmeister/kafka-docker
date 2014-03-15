kafka-docker
============

Dockerfile for [Apache Kafka](http://kafka.apache.org/)

The image is available directly from https://index.docker.io

##Quickstart

```
export START_SCRIPT=https://raw2.github.com/wurstmeister/kafka-docker/master/start-broker.sh
curl -Ls $START_SCRIPT | bash /dev/stdin 1 9092 <your-host-ip>
```

Note: Do not use localhost or 127.0.0.1 as the host ip if you want to run multiple brokers. 

##Tutorial

[http://wurstmeister.github.io/kafka-docker/](http://wurstmeister.github.io/kafka-docker/)



