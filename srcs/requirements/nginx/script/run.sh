#! /bin/sh

mkdir -p /etc/nginx/ssl/

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/C=FR/ST=Alsace/L=Mulhouse/O=42/CN=${DOMAIN_NAME}" 

envsubst < /tmp/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g "daemon off;"