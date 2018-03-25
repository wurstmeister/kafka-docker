FROM anapsix/alpine-java

MAINTAINER Wurstmeister 

RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.7/main" > /etc/apk/repositories && \
    apk update && \
    apk add --update unzip wget curl jq coreutils

ENV KAFKA_VERSION="0.10.0.0" SCALA_VERSION="2.11"
ADD download-kafka.sh /tmp/download-kafka.sh
RUN /tmp/download-kafka.sh && \
    tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt && \
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    rm -rf /var/cache/apk/*

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD create-topics.sh /usr/bin/create-topics.sh

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
