FROM debian:bullseye

LABEL maintainer="anoukan"

RUN apt-get update && apt-get install -y php7.4-fpm php7.4-mysql wget mariadb-client

COPY ./script/run.sh /run.sh

RUN chmod +x /run.sh

EXPOSE 9000

ENTRYPOINT [ "/run.sh" ]