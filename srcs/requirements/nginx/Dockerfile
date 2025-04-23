FROM debian:bullseye-slim

LABEL maintainer="anoukan"

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]