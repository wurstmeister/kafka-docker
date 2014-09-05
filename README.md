kafka-broker
============

Dockerfile for [Apache Kafka](http://kafka.apache.org/) inspired by
[wurstmeister/kafka-docker](https://github.com/wurstmeister/kafka-docker).  The
difference is that we focus on providing a light weight Docker container and the
Kafka brokers are isolated in the Docker environment.  Note that this means that
trying to connect to Kafka via `localhost` is not going to work.  This enforces
users to create their own Docker image to interact with Kafka.

## Quickstart

[Fig](http://www.fig.sh/) is the recommended way to run this Docker image.
```
fig up
```
