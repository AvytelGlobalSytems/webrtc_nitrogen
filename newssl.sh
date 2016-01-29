#!/bin/sh

echo Generating Private Key
openssl genrsa -out $1.key 2048
echo Generating CSR
openssl req -new -key $1.key -out $1.csr
echo Generating Test Cert
openssl x509 -req -days 365 -in $1.csr -signkey $1.key -out $1.test.crt
echo Done
