FROM debian:bullseye

LABEL maintainer="anoukan"

RUN apt-get update 
    # apt-get install -y 

COPY tool/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

CMD ["/usr/local/bin/setup.sh"]