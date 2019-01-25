Following the excellent tutorials on how to run a multi broker kafka cluster natively: [http://www.michael-noll.com/blog/2013/03/13/running-a-multi-broker-apache-kafka-cluster-on-a-single-node/](http://www.michael-noll.com/blog/2013/03/13/running-a-multi-broker-apache-kafka-cluster-on-a-single-node/) and in vagrant: [http://allthingshadoop.com/2013/12/07/using-vagrant-to-get-up-and-running-with-apache-kafka/](http://allthingshadoop.com/2013/12/07/using-vagrant-to-get-up-and-running-with-apache-kafka/)

Here is the tutorial based on Docker and Fig:

Cluster Setup
=============

1.	Install [Docker](https://www.docker.io/gettingstarted/#h_installation)
2.	Install [Compose](http://docs.docker.com/compose/install/)
3.	Update `docker-compose.yml` with your docker host IP (`KAFKA_ADVERTISED_HOST_NAME`\)
4.	If you want to customise any Kafka parameters, simply add them as environment variables in `docker-compose.yml`. For example:
	-	to increase the `message.max.bytes` parameter add `KAFKA_MESSAGE_MAX_BYTES: 2000000` to the `environment` section.
	-	to turn off automatic topic creation set `KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'`
5.	Start the cluster

```
$ docker-compose up
```

e.g. to start a cluster with two brokers

```
$ docker-compose scale kafka=2
```

This will start a single zookeeper instance and two Kafka instances. You can use `docker-compose ps` to show the running instances. If you want to add more Kafka brokers simply increase the value passed to `docker-compose scale kafka=n`

Kafka Shell
===========

You can interact with your Kafka cluster via the Kafka shell:

```
$ start-kafka-shell.sh <DOCKER_HOST_IP> <ZK_HOST:ZK_PORT>
```

Testing
=======

To test your setup, start a shell, create a topic and start a producer:

```
$ $KAFKA_HOME/bin/kafka-topics.sh --create --topic topic \
--partitions 4 --zookeeper $ZK --replication-factor 2
$ $KAFKA_HOME/bin/kafka-topics.sh --describe --topic topic --zookeeper $ZK
$ $KAFKA_HOME/bin/kafka-console-producer.sh --topic=topic \
--broker-list=`broker-list.sh`
```

Start another shell and start a consumer:

```
$ $KAFKA_HOME/bin/kafka-console-consumer.sh --topic=topic --zookeeper=$ZK
```

Running kafka-docker on a Mac:
==============================

Install the [Docker Toolbox](https://www.docker.com/products/docker-toolbox) and set `KAFKA_ADVERTISED_HOST_NAME` to the IP that is returned by the `docker-machine ip` command.

Troubleshooting:
================

-	By default a Kafka broker uses 1GB of memory, so if you have trouble starting a broker, check `docker-compose logs`/`docker logs` for the container and make sure you've got enough memory available on your host.
-	Do not use localhost or 127.0.0.1 as the host IP if you want to run multiple brokers otherwise the brokers won't be able to communicate
