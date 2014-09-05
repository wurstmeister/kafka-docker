FROM ubuntu:14.04

MAINTAINER hwasungmars
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y openjdk-7-jre-headless wget

RUN wget -q http://mirror.ox.ac.uk/sites/rsync.apache.org/kafka/0.8.1.1/kafka_2.9.2-0.8.1.1.tgz -O /tmp/kafka.tgz
RUN mkdir /opt/kafka
RUN tar xfz /tmp/kafka.tgz -C /opt/kafka --strip-components=1

ENV KAFKA_HOME /opt/kafka

# Set the maximum message size to 2MB.
RUN echo 'message.max.bytes=2000000' >> $KAFKA_HOME/config/server.properties
RUN echo 'replica.fetch.max.bytes=2000000' >> $KAFKA_HOME/config/server.properties

ADD start-kafka.sh /usr/bin/start-kafka.sh
CMD start-kafka.sh
