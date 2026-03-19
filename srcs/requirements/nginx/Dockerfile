FROM debian:bullseye

LABEL maintainer="anoukan"

RUN apt-get update && apt-get install nginx openssl gettext -y && rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /tmp/nginx.conf.template
COPY ./script/run.sh /run.sh

RUN chmod +x /run.sh

EXPOSE 443

ENTRYPOINT [ "/run.sh" ]