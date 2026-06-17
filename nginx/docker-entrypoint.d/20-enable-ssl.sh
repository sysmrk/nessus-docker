#!/bin/sh
set -eu

if [ "${ENABLE_SSL:-false}" != "true" ]; then
    rm -f /etc/nginx/conf.d/ssl.conf
    exit 0
fi

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

cat > /etc/nginx/conf.d/ssl.conf <<'EOF'
server {
    listen 443 ssl http2;
    server_name _;

    ssl_certificate /etc/nginx/certs/tls.crt;
    ssl_certificate_key /etc/nginx/certs/tls.key;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_protocols TLSv1.2 TLSv1.3;

    client_max_body_size 64m;

    location = /nginx-health {
        access_log off;
        add_header Content-Type text/plain;
        return 200 "ok\n";
    }

    location / {
        proxy_pass https://nessus_backend;
        proxy_http_version 1.1;
        proxy_ssl_verify off;
        proxy_ssl_server_name off;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;

        proxy_connect_timeout 60s;
        proxy_send_timeout 3600s;
        proxy_read_timeout 3600s;
        proxy_buffering off;
    }
}
EOF
