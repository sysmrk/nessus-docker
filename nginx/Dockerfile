FROM nginx:1.27-alpine

RUN apk add --no-cache openssl

COPY default.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.d/20-enable-ssl.sh /docker-entrypoint.d/
COPY nginx-healthcheck /usr/local/bin/nginx-healthcheck

RUN chmod +x /docker-entrypoint.d/20-enable-ssl.sh /usr/local/bin/nginx-healthcheck
