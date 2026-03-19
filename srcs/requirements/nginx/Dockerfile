FROM debian:bullseye-slim

LABEL maintainer="anoukan"

RUN apt-get update && apt-get install nginx -y && rm -rf /var/lib/apt/list/*

COPY ../conf/nginx.conf /etc/nginx/
COPY ../script .

EXPOSE 443

ENTRYPOINT [ "nginx -daemon off" ]
