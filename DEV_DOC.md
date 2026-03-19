# Developer Documentation

## Prerequisites

- Docker >= 24.0
- Docker Compose >= 2.0
- `sudo` access (needed for `/etc/hosts` and `/home/anoukan/data/`)

---

## Setup from scratch

### 1. Clone the repository

```sh
git clone <repository-url>
cd Inception
```

### 2. Create the secrets files

The `secrets/` folder must be created manually — it is not tracked by git.

```sh
mkdir -p secrets
```

**`secrets/credential.txt`** — WordPress users (one value per line):
```
<admin_username>
<admin_email>
<admin_password>
<regular_username>
<regular_email>
<regular_password>
```

> The admin username must NOT contain `admin` or `administrator` (case-insensitive).

**`secrets/db_password.txt`** — MariaDB password for the WordPress user:
```
<your_db_password>
```

**`secrets/db_root_password.txt`** — MariaDB root password:
```
<your_root_password>
```

### 3. Check the `.env` file

`srcs/.env` contains non-sensitive configuration:

```env
DOMAIN_NAME=anoukan.42.fr
USERNAME=anoukan

# MariaDB
DB_HOST=mariadb
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
```

Adjust `DOMAIN_NAME` and `USERNAME` to match your 42 login.

---

## Build and launch

```sh
make
```

This runs `setup` then `docker compose up --build -d`.

`setup` does two things:
- Creates `/home/anoukan/data/mariadb` and `/home/anoukan/data/wordpress` on the host
- Adds `127.0.0.1 anoukan.42.fr` to `/etc/hosts` if not already present

---

## Makefile commands

| Command | Description |
|---|---|
| `make` / `make inception` | Build images and start containers |
| `make setup` | Create data directories and update `/etc/hosts` |
| `make clean` | Stop containers and remove the hosts entry |
| `make fclean` | Stop containers, remove images, volumes, and data |
| `make re` | Full rebuild (fclean + inception) |
| `make down` | Stop containers only (no cleanup) |

---

## Manage containers

```sh
# See status
docker compose -f srcs/docker-compose.yml ps

# Read logs
docker compose -f srcs/docker-compose.yml logs -f <service>
# <service> = nginx | wordpress | mariadb

# Open a shell inside a container
docker compose -f srcs/docker-compose.yml exec <service> sh

# Restart a single service
docker compose -f srcs/docker-compose.yml restart <service>
```

---

## Data persistence

| Volume | Host path | Container path |
|---|---|---|
| `mariadb` | `/home/anoukan/data/mariadb` | `/var/lib/mysql` |
| `wordpress` | `/home/anoukan/data/wordpress` | `/var/www/html` |

Both are Docker named volumes using `driver: local` with `o: bind`, which means data is directly accessible on the host at the paths above.

Data survives `make clean` (containers removed) but is deleted by `make fclean` (`rm -rf /home/anoukan/data`).

---

## Project structure

```
Inception/
├── Makefile
├── secrets/                  # ignored by git — create manually
│   ├── credential.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── script/run.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── script/run.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/my.cnf
            └── script/run.sh
```
