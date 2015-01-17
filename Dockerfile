FROM ubuntu:trusty

MAINTAINER Wurstmeister 

RUN apt-get update; apt-get install -y unzip  openjdk-6-jdk wget git docker.io

RUN wget -q http://mirror.gopotato.co.uk/apache/kafka/0.8.2-beta/kafka_2.9.1-0.8.2-beta.tgz -O /tmp/kafka_2.9.1-0.8.2-beta.tgz
RUN tar xfz /tmp/kafka_2.9.1-0.8.2-beta.tgz -C /opt

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka_2.9.1-0.8.2-beta
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
CMD start-kafka.sh 
