FROM ubuntu:trusty

MAINTAINER Wurstmeister 

ENV KAFKA_VERSION="0.8.2.1" SCALA_VERSION="2.10"

RUN apt-get update && apt-get install -y supervisor unzip openjdk-6-jdk wget curl git docker.io jq

ADD download-kafka.sh /tmp/download-kafka.sh
RUN /tmp/download-kafka.sh
RUN tar xf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD kafka.conf /etc/supervisor/conf.d/
RUN echo command=$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties >> /etc/supervisor/conf.d/kafka.conf
CMD start-kafka.sh
