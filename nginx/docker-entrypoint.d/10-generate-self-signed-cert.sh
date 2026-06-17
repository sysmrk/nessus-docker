#!/bin/sh
set -eu

cert_dir=/etc/nginx/certs
cert_file="$cert_dir/tls.crt"
key_file="$cert_dir/tls.key"

mkdir -p "$cert_dir"

if [ ! -s "$cert_file" ] || [ ! -s "$key_file" ]; then
    openssl req \
        -x509 \
        -nodes \
        -newkey rsa:2048 \
        -days "${TLS_CERT_DAYS:-3650}" \
        -keyout "$key_file" \
        -out "$cert_file" \
        -subj "/CN=${TLS_CERT_CN:-localhost}" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
fi
