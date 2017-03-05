FROM anapsix/alpine-java

ARG kafka_version=0.10.1.1
ARG scala_version=2.11
ARG kafkacat_version=1.3.0
MAINTAINER wurstmeister

RUN apk add --update unzip wget curl docker jq coreutils alpine-sdk bash python cmake

RUN curl https://codeload.github.com/edenhill/kafkacat/tar.gz/${kafkacat_version} | tar xzf - && cd kafkacat-* && bash ./bootstrap.sh && mv kafkacat /usr/bin && cd / && rm -rf /kafkacat-*  && apk del alpine-sdk python cmake wget curl unzip

ENV KAFKA_VERSION=$kafka_version SCALA_VERSION=$scala_version
ADD download-kafka.sh /tmp/download-kafka.sh
RUN chmod a+x /tmp/download-kafka.sh && sync && /tmp/download-kafka.sh && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD create-topics.sh /usr/bin/create-topics.sh
# The scripts need to have executable permission
RUN chmod a+x /usr/bin/start-kafka.sh && \
    chmod a+x /usr/bin/broker-list.sh && \
    chmod a+x /usr/bin/create-topics.sh
# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
