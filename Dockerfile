FROM anapsix/alpine-java

ARG kafka_version=1.0.1
ARG scala_version=2.12

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.url="http://kafka.apache.org" \
      org.label-schema.version="${kafka_version}" \
      org.apache.kafka.base-image="anapsix/alpine-java" \
      org.apache.kafka.scala-version="${scala_version}" \
      org.apache.kafka.kafka-version="${kafka_version}"

MAINTAINER wurstmeister

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    PATH=${PATH}:${KAFKA_HOME}/bin

COPY start-kafka.sh broker-list.sh create-topics.sh ssl-bootstrap.sh /usr/bin/

RUN apk add --update unzip curl docker coreutils cyrus-sasl cyrus-sasl-gssapi krb5 openssl \
 && chmod a+x /usr/bin/*.sh \
 && curl -L "https://www.apache.org/dyn/closer.cgi?action=download&filename=/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
  | tar xzf - -C /opt \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
 && rm /tmp/*

VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
