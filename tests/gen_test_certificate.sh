#!/bin/bash
# Generate a self-signed test certificate, used for testing
# This certificate must not be used for any other purpose

# Working files
FILE_KEY="tmp_cert.key"
FILE_CSR="tmp_cert.csr"
FILE_CERT="certificate_for_testing"

# Configuration file
FILE_CONFIG="data_openssl_cert_defaults.config"

# Output filenames
CERT_PEM="${FILE_CERT}.pem"
CERT_CER="${FILE_CERT}.cer"

# Certificate settings
export CERT_KEY_SECRET="THIS_IS_NOT_A_GOOD_SECRET"
CERT_SERIAL="0xBADBADBAD"


echo "==> Starting process to create the TEST CERTIFICATE..."
echo "--> Generating private key file (${FILE_KEY})."
openssl genrsa \
    -aes128 \
    -passout env:CERT_KEY_SECRET \
    -out "${FILE_KEY}"

echo "--> Generating certificate signing request file (${FILE_CSR})."
openssl req \
    -new \
    -passin env:CERT_KEY_SECRET \
    -config "${FILE_CONFIG}" \
    -key "${FILE_KEY}" \
    -out "${FILE_CSR}"

echo "--> Generating self-signed certificate file (${CERT_PEM})."
openssl x509 -req \
    -passin env:CERT_KEY_SECRET \
    -days 1 \
    -set_serial "${CERT_SERIAL}" \
    -in "${FILE_CSR}" \
    -signkey "${FILE_KEY}" \
    -outform pem \
    -out "${CERT_PEM}"

echo "--> Generating DER form of certificate (${CERT_CER})."
openssl x509 \
    -inform pem \
    -in "${CERT_PEM}" \
    -outform der \
    -out "${CERT_CER}"

echo "--> Cleaning up..."
rm -i "${FILE_KEY}" "${FILE_CSR}"

echo "<== Done."
