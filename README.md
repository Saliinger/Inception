# Guide d'implémentation — Inception 42

> Guide personnel pour construire le projet de zéro.

---

## Vue d'ensemble

Tu dois créer 3 conteneurs Docker qui communiquent entre eux :

```
Internet :443 (HTTPS)
    │
    ▼
[ NGINX ] ──── FastCGI :9000 ──── [ WordPress + php-fpm ]
                                           │
                                     MySQL :3306
                                           │
                                       [ MariaDB ]
```

- **NGINX** : seul point d'entrée, gère le TLS
- **WordPress** : tourne avec php-fpm (pas de serveur web dedans)
- **MariaDB** : base de données

---

## Étape 0 — Arborescence à créer

```
Inception/
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt          ← user WP / password WP / email (1 par ligne)
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── script/
        │       └── run.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── script/
        │       └── run.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── my.cnf
            └── script/
                └── run.sh
```

---

## Étape 1 — Les secrets et le .env

### `secrets/db_password.txt`
```
ton_mot_de_passe_db
```

### `secrets/db_root_password.txt`
```
ton_mot_de_passe_root
```

### `secrets/credentials.txt`
```
wpmaster
ton_mot_de_passe_wp
ton@email.fr
```
> Ligne 1 = username admin WP (**pas** `admin` ni `administrator` dans le nom)
> Ligne 2 = password WP
> Ligne 3 = email

### `srcs/.env`
```env
DOMAIN_NAME=anoukan.42.fr

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
```
> Pas de passwords ici. Les passwords viennent des secrets.

---

## Étape 2 — Le Makefile

```makefile
COMPOSE = docker compose -f srcs/docker-compose.yml

all: create_dirs
	$(COMPOSE) up -d --build

create_dirs:
	mkdir -p /home/anoukan/data/mariadb
	mkdir -p /home/anoukan/data/wordpress

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build --no-cache

clean:
	$(COMPOSE) down -v --rmi all

fclean: clean
	sudo rm -rf /home/anoukan/data

re: fclean all

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all up down build clean fclean re logs ps create_dirs
```

---

## Étape 3 — docker-compose.yml

```yaml
version: '3.8'

services:

  nginx:
    build: ./requirements/nginx
    container_name: nginx
    image: nginx
    depends_on:
      - wordpress
    ports:
      - "443:443"
    networks:
      - inception
    volumes:
      - wp-volume:/var/www/html
    restart: unless-stopped

  wordpress:
    build: ./requirements/wordpress
    container_name: wordpress
    image: wordpress
    depends_on:
      - mariadb
    networks:
      - inception
    volumes:
      - wp-volume:/var/www/html
    env_file:
      - .env
    secrets:
      - db_password
      - credentials
    restart: unless-stopped

  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    image: mariadb
    networks:
      - inception
    volumes:
      - db-volume:/var/lib/mysql
    env_file:
      - .env
    secrets:
      - db_password
      - db_root_password
    restart: unless-stopped

networks:
  inception:
    driver: bridge

volumes:
  wp-volume:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/anoukan/data/wordpress

  db-volume:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/anoukan/data/mariadb

secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt
  credentials:
    file: ../secrets/credentials.txt
```

---

## Étape 4 — MariaDB

### `srcs/requirements/mariadb/Dockerfile`

```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/conf.d/my.cnf
COPY script/run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3306

ENTRYPOINT ["/run.sh"]
```

### `srcs/requirements/mariadb/conf/my.cnf`

```ini
[mysqld]
bind-address = 0.0.0.0
```
> Par défaut MariaDB écoute sur `127.0.0.1` — il faut qu'il accepte les connexions des autres conteneurs.

### `srcs/requirements/mariadb/script/run.sh`

```bash
#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Initialise les fichiers de données si ce n'est pas déjà fait
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Démarre mysqld temporairement pour configurer la DB
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# Lance MariaDB en foreground (PID 1)
exec mysqld --user=mysql
```

---

## Étape 5 — WordPress

### `srcs/requirements/wordpress/Dockerfile`

```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Installe WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY script/run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 9000

ENTRYPOINT ["/run.sh"]
```

### `srcs/requirements/wordpress/script/run.sh`

```bash
#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN=$(sed -n '1p' /run/secrets/credentials)
WP_PASSWORD=$(sed -n '2p' /run/secrets/credentials)
WP_EMAIL=$(sed -n '3p' /run/secrets/credentials)

# Crée le répertoire WordPress si vide
if [ ! -f /var/www/html/wp-config.php ]; then

    # Attend que MariaDB soit prêt
    until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
        echo "Waiting for MariaDB..."
        sleep 2
    done

    # Télécharge WordPress
    wp core download --path=/var/www/html --allow-root

    # Crée wp-config.php
    wp config create \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root

    # Installe WordPress
    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN}" \
        --admin_password="${WP_PASSWORD}" \
        --admin_email="${WP_EMAIL}" \
        --allow-root

    # Crée un second utilisateur (non admin)
    wp user create \
        --path=/var/www/html \
        subscriber subscriber@${DOMAIN_NAME} \
        --user_pass="subscriber_pass" \
        --role=subscriber \
        --allow-root
fi

# Lance php-fpm en foreground (PID 1)
exec php-fpm7.4 -F
```

---

## Étape 6 — NGINX

### `srcs/requirements/nginx/Dockerfile`

```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

# Génère un certificat TLS auto-signé
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/CN=anoukan.42.fr"

COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY script/run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 443

ENTRYPOINT ["/run.sh"]
```

### `srcs/requirements/nginx/conf/nginx.conf`

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name anoukan.42.fr;

    ssl_certificate     /etc/ssl/certs/nginx.crt;
    ssl_certificate_key /etc/ssl/private/nginx.key;
    ssl_protocols       TLSv1.2 TLSv1.3;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

### `srcs/requirements/nginx/script/run.sh`

```bash
#!/bin/sh
exec nginx -g "daemon off;"
```

---

## Étape 7 — DNS local

Sur la VM, ajoute cette ligne dans `/etc/hosts` :

```bash
echo "127.0.0.1 anoukan.42.fr" | sudo tee -a /etc/hosts
```

---

## Étape 8 — .gitignore

À la racine du projet :

```
secrets/
srcs/.env
```

---

## Ordre de build et lancement

```bash
# 1. Crée les dossiers de données
mkdir -p /home/anoukan/data/mariadb
mkdir -p /home/anoukan/data/wordpress

# 2. Lance tout
make

# 3. Vérifie que les 3 conteneurs tournent
make ps

# 4. Consulte les logs si un conteneur crash
make logs
```

---

## Checklist de validation

- [ ] Les 3 conteneurs tournent (`docker ps`)
- [ ] `https://anoukan.42.fr` charge le site WordPress
- [ ] `https://anoukan.42.fr/wp-admin` permet de se connecter
- [ ] TLS v1.2 et v1.3 fonctionnent : `openssl s_client -connect anoukan.42.fr:443 -tls1_2`
- [ ] TLS v1.1 est refusé : `openssl s_client -connect anoukan.42.fr:443 -tls1_1`
- [ ] La DB a bien 2 utilisateurs WordPress (admin + subscriber)
- [ ] Le username admin ne contient pas `admin` ou `administrator`
- [ ] Aucun mot de passe dans les Dockerfiles
- [ ] Les volumes persistent après `make down && make up`
- [ ] Les conteneurs redémarrent après `docker kill <container>` (`restart: unless-stopped`)
- [ ] Le dossier `secrets/` et `srcs/.env` sont dans `.gitignore`

---

## Notions à connaître pour la soutenance

### PID 1 et `daemon off`
Chaque conteneur doit lancer son process principal **en foreground** pour que Docker reçoive les signaux (SIGTERM pour l'arrêt propre). C'est pourquoi :
- NGINX utilise `nginx -g "daemon off;"`
- php-fpm utilise `php-fpm -F`
- MariaDB utilise `exec mysqld` (pas `service mysql start`)

Le `exec` en fin de script shell remplace le shell par le process — il devient PID 1.

### Pourquoi pas `tail -f` ou `sleep infinity` ?
Ces commandes font tourner le conteneur sans que ton service tourne vraiment. Si le service crashe, Docker ne le sait pas et le conteneur reste "Up" sans rien faire.

### Pourquoi pas le tag `latest` ?
`latest` est mutable — il peut pointer vers une image différente demain. Utilise une version fixe (`debian:bullseye`) pour des builds reproductibles.

### FastCGI (lien NGINX → WordPress)
NGINX ne sait pas exécuter du PHP. Il délègue les fichiers `.php` à php-fpm via le protocole FastCGI sur le port 9000. NGINX est un reverse proxy ici.

### Volumes nommés vs bind mounts
Les bind mounts (`/host/path:/container/path`) sont interdits. Les **named volumes** ont un cycle de vie géré par Docker et sont déclarés dans `docker-compose.yml`. Ici, on utilise le driver `local` avec `type: none` + `o: bind` pour pointer vers `/home/anoukan/data/` — c'est la façon autorisée par le sujet.

### Secrets vs variables d'environnement
Les variables d'env (`-e`, `env_file:`) sont visibles dans `docker inspect`. Les **secrets** Docker sont montés en mémoire dans `/run/secrets/` et ne transitent pas par l'environnement du process. Aucun password ne doit apparaître dans un Dockerfile.
