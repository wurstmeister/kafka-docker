FROM ubuntu

MAINTAINER Wurstmeister 
RUN echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list; apt-get update; apt-get install -y unzip  openjdk-6-jdk wget git

ENV LAST_GIT_UPDATE 2014-01-11
RUN cd /tmp; git clone https://github.com/apache/kafka.git; 
RUN cd /tmp/kafka; ./sbt update; ./sbt package; ./sbt assembly-package-dependency;  ./sbt release-tar 
RUN tar xfz /tmp/kafka/target/RELEASE/kafka_2.8.0-0.8.1.tar.gz -C /opt
ENV KAFKA_HOME /opt/kafka_2.8.0-0.8.1
ADD start-kafka.sh /usr/bin/start-kafka.sh 
CMD start-kafka.sh 
