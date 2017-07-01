#!/bin/bash

#Script to create and sign broker certificate for SSL operation. In default mode will
#generate generic default values for DNs and passwords.

#The following environment should be supplied to Kafka to support this default behavior
export KAFKA_SSL_KEYSTORE_LOCATION=${KAFKA_SSL_KEYSTORE_LOCATION-/etc/ssl/private/server.keystore.jks}
export KAFKA_SSL_KEYSTORE_PASSWORD=${KAFKA_SSL_KEYSTORE_PASSWORD-password1234}
export KAFKA_SSL_KEY_PASSWORD=${KAFKA_SSL_KEY_PASSWORD-password1234}
export KAFKA_SSL_TRUSTSTORE_LOCATION=${KAFKA_SSL_TRUSTSTORE_LOCATION-/etc/ssl/private/server.truststore.jks}
export KAFKA_SSL_TRUSTSTORE_PASSWORD=${KAFKA_SSL_TRUSTSTORE_PASSWORD-password1234}

#The following environment is optional
#KAFKA_SSL_CLIENT_AUTH=none
#KAFKA_SSL_KEYSTORE_TYPE=JKS
#KAFKA_SSL_TRUSTSTORE_TYPE=JKS
KAFKA_SSL_SECURE_RANDOM_IMPLEMENTATION=${KAFKA_SSL_SECURE_RANDOM_IMPLEMENTATION-SHA1PRNG}

cd /etc/ssl/private

#If the Keystore file already exists (i.e., has been volume-mounted) don't run this script any more
if [[ ! -f ${KAFKA_SSL_KEYSTORE_LOCATION} ]]; then

#If a secrets file named passwords has been created, source it.
# Expect it to export environment variables for passwords and certificate names
# Including
# KEYSTORE_PASSWORD to protect the keystore JKS
# KEY_PASSWORD to protect the broker private key
# CA_PASSWORD to protect the CA private key
# CERT_DN for the DN used to generate the server private key (in a format supported by keytool)
# CA_DN for the DN used to generate the Root CA (in a format supported by openssl)

if [[ -f /run/secret/passwords ]]; then
. /run/secret/passwords
fi

#Check if the Keystore and/or Truststore files are available as Secrets; if they are, then
#this script does not need to run.
#TODO

if [[ -z "$CERT_DN" ]]; then
export CERT_DN="cn=$(hostname), ou=GenericOU, o=GenericO, c=US"
fi

if [[ -z "$CA_DN" ]]; then
export CA_DN="/C=US/ST=California/L=Cupertino/CN=$(hostname)"
fi

echo "##########"
echo "Creating a Keystore with a Private Key for the Broker"

keytool -keystore ${KAFKA_SSL_KEYSTORE_LOCATION} -alias localhost -validity 365 -keyalg RSA -genkey \
-storepass ${KAFKA_SSL_KEYSTORE_PASSWORD} \
-dname "$CERT_DN" \
-keypass ${KAFKA_SSL_KEY_PASSWORD}

echo "##########"
echo "Creating a Root CA key and certificate"

openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 \
-passout pass:${CA_PASSWORD-password1234} \
-subj "$CA_DN"

cat ca-cert

echo "##########"
echo "Importing Root CA certificate to Client and Server Truststores."

keytool -keystore $KAFKA_SSL_TRUSTSTORE_LOCATION -alias CARoot -import -file ca-cert -storepass ${KAFKA_SSL_TRUSTSTORE_PASSWORD} -noprompt
#keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert -storepass ${KAFKA_SSL_TRUSTSTORE_PASSWORD} -noprompt

echo "##########"
echo "Signing Broker certificate with Root CA"

#Create certificate request from key in keystore
keytool -keystore ${KAFKA_SSL_KEYSTORE_LOCATION} -alias localhost -certreq -file cert-file \
-storepass ${KAFKA_SSL_KEYSTORE_PASSWORD} \
-keypass ${KAFKA_SSL_KEY_PASSWORD}

#Sign the certificate request with the rootCA
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 \
-CAcreateserial -passin pass:${CA_PASSWORD-password1234}

#Import the CA and server signed certificate to the server keystores
keytool -keystore server.keystore.jks -noprompt -alias CARoot -import -file ca-cert \
-storepass ${KAFKA_SSL_KEYSTORE_PASSWORD} \
-keypass ${KAFKA_SSL_KEY_PASSWORD}

keytool -keystore server.keystore.jks -noprompt -alias localhost -import -file cert-signed \
-storepass ${KAFKA_SSL_KEYSTORE_PASSWORD} \
-keypass ${KAFKA_SSL_KEY_PASSWORD}

#End Keystore file check IF block
fi
