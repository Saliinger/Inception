FROM debian:bullseye

LABEL maintainer="anoukan"

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy mariadb configuration
COPY conf/setup.cnf /etc/mariadb.conf.d/setup.cnf
COPY tool/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

CMD ["/usr/local/bin/setup.sh"] 