#FROM ubuntu:trusty
FROM dockerfile/ubuntu

MAINTAINER lyddonb

RUN echo "deb http://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list

RUN apt-get update 

RUN apt-get install --force-yes -y sbt
RUN apt-get install -y openjdk-7-jdk && rm -rf /var/lib/apt/lists/*
RUN apt-get install -y git
RUN apt-get install -y unzip
RUN git clone https://github.com/yahoo/kafka-manager.git

WORKDIR kafka-manager

RUN sbt clean dist

WORKDIR target/universal

RUN unzip kafka-manager-1.0-SNAPSHOT.zip
RUN mv kafka-manager-1.0-SNAPSHOT /opt/kafka-manager

WORKDIR /opt/kafka-manager/bin

EXPOSE 9000

ADD application.conf application.conf
ADD run.sh run.sh
RUN chmod +x run.sh

CMD ./run.sh 
