FROM anapsix/alpine-java

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.url="http://kafka.apache.org" \
      org.label-schema.version="0.11.0.0" \
      org.label-schema.build-date="2017-07-01" \
      org.apache.kafka.base-image="anapsix/alpine-java" \
      org.apache.kafka.scala-version="2.12" \
      org.apache.kafka.kafka-version="0.11.0.0"

ARG kafka_version=0.11.0.0
ARG scala_version=2.12

RUN apk add --update unzip wget curl docker jq coreutils

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
