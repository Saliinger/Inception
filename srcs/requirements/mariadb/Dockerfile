FROM debian:bullseye-slim

LABEL maintainer="anoukan"

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["mariadbd", "daemon off;"]