FROM anapsix/alpine-java

MAINTAINER Wurstmeister

ENV KAFKA_VERSION="0.10.0.0" SCALA_VERSION="2.11" KAFKA_HOME=/opt/kafka

RUN set -x && \
  apk add --no-cache curl docker jq coreutils && \
  curl -s https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$KAFKA_VERSION_$SCALA_VERSION-$KAFKA_VERSION.tgz | \
  tar xvz -C /opt && \
  ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} $KAFKA_HOME

VOLUME ["/kafka"]

ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD create-topics.sh /usr/bin/create-topics.sh

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
