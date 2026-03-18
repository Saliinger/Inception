FROM debian:bullseye

LABEL maintainer="anoukan"

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY ./conf/my.cnf /etc/mysql/conf.d/my.cnf

COPY ./script/run.sh /run.sh

RUN chmod +x /run.sh

EXPOSE 3306

ENTRYPOINT [ "/run.sh" ]