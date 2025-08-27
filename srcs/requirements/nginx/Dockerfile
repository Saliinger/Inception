FROM debian:12-slim

LABEL maintainer="anoukan"

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directories for SSL certificates
RUN mkdir /etc/nginx/ssl

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -subj "/C=FR/ST=Haut-Rhin/L=Mulhouse/O=42/OU=student/CN=anoukan.42.fr"

# Copy nginx configuration
# COPY ./requirements/nginx/conf/default /etc/nginx/sites-available/default
COPY ./requirements/nginx/tool/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 443

CMD ["/usr/local/bin/setup.sh"]