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
#export KAFKA_SSL_CLIENT_AUTH=none
#export KAFKA_SSL_KEYSTORE_TYPE=JKS
#export KAFKA_SSL_TRUSTSTORE_TYPE=JKS
export KAFKA_SSL_SECURE_RANDOM_IMPLEMENTATION=${KAFKA_SSL_SECURE_RANDOM_IMPLEMENTATION-SHA1PRNG}

#The following environment is not used by Kafka but controls the creation of bootstrap certificates
# CA_DN for the DN used to generate the Root CA (in a format supported by openssl)
# CA_PASSWORD to protect the CA private key
# CERT_DN for the DN used to generate the server private key (in a format supported by keytool)
export CA_KEY=${CA_KEY-/etc/ssl/private/ca_key} #The CA Private key used for signing
export CA_PASSWORD=${CA_PASSWORD-password1234} #The CA Private key password
export CA_P12_FILE=${CA_P12_FILE-} #Use an outside CA key pair as a PKCS12 file
export CA_P12_PASSWORD=${CA_PA12_PASSWORD-password1234} #the password for the P12 file

cd /etc/ssl/private

#Check if the Keystore and/or Truststore files are available as Secrets; if they are, then
#this script does not need to run.
if [[ -f /run/secrets/server.keystore.jks ]]; then
   export KAFKA_SSL_KEYSTORE_LOCATION=/run/secrets/server.keystore.jks
fi

if [[ -f /run/secrets/server.truststore.jks ]]; then
   export KAFKA_SSL_TRUSTSTORE_LOCATION=/run/secrets/server.truststore.jks
fi

#If the Keystore file already exists (i.e., has been volume-mounted or loaded as a secret) don't run this script any more
if [[ ! -f ${KAFKA_SSL_KEYSTORE_LOCATION} ]]; then

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

#Only if there is no present Root CA key and the PKCS12 option is not set.
if [[ ! -f ${CA_KEY} && -z ${CA_P12_FILE} ]]; then
openssl req -new -x509 -keyout ${CA_KEY} -out ca-cert -days 365 \
-passout pass:${CA_PASSWORD} \
-subj "$CA_DN"
cat ca-cert
fi

#Extract the certificate from the PKCS12 file if set
if [[ -n "${CA_P12_FILE}" ]]; then
openssl pkcs12 -in ${CA_P12_FILE} -out ca-cert -nokeys -nodes -passin pass:${CA_P12_PASSWORD}
openssl pkcs12 -in ${CA_P12_FILE} -out ca-key -nocerts -nodes -passin pass:${CA_P12_PASSWORD}
fi

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
if [[ -n "$CA_P12_FILE}" ]]; then
openssl x509 -req -CA ca-cert -CAkey ${CA_KEY} -in cert-file -out cert-signed -days 365 \
-CAcreateserial -passin pass:${CA_PASSWORD}
else
openssl x509 -req -CA ca-cert -CAkey ${CA_KEY} -in cert-file -out cert-signed -days 365 \
-CAcreateserial -passin pass:${CA_PASSWORD}
fi

#Import the CA and server signed certificate to the server keystores
keytool -keystore server.keystore.jks -noprompt -alias CARoot -import -file ca-cert \
-storepass ${KAFKA_SSL_KEYSTORE_PASSWORD} \
-keypass ${KAFKA_SSL_KEY_PASSWORD}

keytool -keystore server.keystore.jks -noprompt -alias localhost -import -file cert-signed \
-storepass ${KAFKA_SSL_KEYSTORE_PASSWORD} \
-keypass ${KAFKA_SSL_KEY_PASSWORD}

#End Keystore file check IF block
fi
