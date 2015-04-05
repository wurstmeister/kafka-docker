FROM ubuntu:trusty

MAINTAINER Wurstmeister 

RUN apt-get update; apt-get install -y unzip openjdk-6-jdk wget git docker.io software-properties-common python-software-properties
RUN add-apt-repository ppa:cwchien/gradle; apt-get update; apt-get install -y gradle

RUN cd /opt; mkdir kafka-src; cd kafka-src; git clone https://github.com/apache/kafka.git

ENV BUILD_DATE 2015-04-05

RUN cd /opt/kafka-src/kafka; git pull; gradle; ./gradlew releaseTarGz ; cd /opt/kafka-src/kafka/core/build/distributions; mkdir /opt/kafka; tar xfvz *.tgz -C /opt/kafka --strip-components=1

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
CMD start-kafka.sh 
