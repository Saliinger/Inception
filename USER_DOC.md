# User Documentation

## Services provided

This stack runs three services:

| Service | Role |
|---|---|
| **NGINX** | Web server, only entry point via HTTPS (port 443) |
| **WordPress** | Website and admin panel, powered by php-fpm |
| **MariaDB** | Database storing all WordPress content |

---

## Start and stop the project

**Start:**
```sh
make
```
This builds the Docker images and starts all containers.

**Stop (keep data):**
```sh
make clean
```
Stops and removes the containers. Your data is preserved.

**Full reset (removes everything):**
```sh
make fclean
```
Stops containers, removes images and volumes. All data is lost.

**Rebuild from scratch:**
```sh
make re
```

---

## Access the website

Open your browser and go to:

```
https://anoukan.42.fr
```

> The browser will show a certificate warning — this is expected as the SSL certificate is self-signed. Accept and continue.

**WordPress admin panel:**
```
https://anoukan.42.fr/wp-admin
```

Log in with the admin credentials stored in `secrets/credential.txt`.

---

## Credentials

Credentials are stored in the `secrets/` folder at the root of the project:

| File | Content |
|---|---|
| `secrets/credential.txt` | WordPress admin user, email, password (lines 1-3) then regular user (lines 4-6) |
| `secrets/db_password.txt` | MariaDB WordPress user password |
| `secrets/db_root_password.txt` | MariaDB root password |

> These files are ignored by git and must never be shared or committed.

---

## Check that services are running

**See running containers:**
```sh
docker compose -f srcs/docker-compose.yml ps
```

All three services (`nginx`, `wordpress`, `mariadb`) should show status `running`.

**Read logs for a specific service:**
```sh
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

**Follow logs in real time:**
```sh
docker compose -f srcs/docker-compose.yml logs -f
```
