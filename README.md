*This project has been created as part of the 42 curriculum by anoukan.*

---

## Description

Inception is a system administration project that consists of setting up a small infrastructure using Docker and Docker Compose inside a virtual machine.

The infrastructure is composed of three services, each running in its own container:

- **NGINX** — the only entry point, accessible via port 443 (TLSv1.3)
- **WordPress + php-fpm** — the web application, served by NGINX via FastCGI
- **MariaDB** — the database for WordPress

Data is persisted using Docker named volumes stored on the host at `/home/anoukan/data/`.

### Design choices

#### Virtual Machines vs Docker

| Virtual Machine | Docker |
|---|---|
| Full OS per VM, heavy (GB) | Shares host kernel, lightweight (MB) |
| Slow to start (minutes) | Fast to start (seconds) |
| Strong isolation | Process-level isolation |
| Good for running different OS | Good for packaging applications |

Docker was chosen here because we only need to isolate services, not run separate operating systems. It is lighter and fits the project's scope.

#### Secrets vs Environment Variables

| Secrets | Environment Variables |
|---|---|
| Stored in files, never in env | Visible in `docker inspect`, process list |
| Mounted at `/run/secrets/` in container | Passed directly to the container |
| Suited for passwords, API keys | Suited for non-sensitive config (URLs, usernames) |

Passwords are stored as Docker secrets (files in `secrets/`). Non-sensitive config like `DOMAIN_NAME` or `DB_HOST` uses environment variables via `.env`.

#### Docker Network vs Host Network

| Docker Network | Host Network |
|---|---|
| Containers communicate by service name | Containers share the host's network stack |
| Isolated from host | No isolation |
| Controlled exposure via `ports:` | All ports exposed by default |

A custom Docker bridge network (`inception`) is used so containers can reach each other by name (e.g. `mariadb`, `wordpress`) without exposing internal ports to the host.

#### Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|---|---|
| Managed by Docker | Points to a specific host path |
| Stored in `/var/lib/docker/volumes/` | Stored wherever you specify |
| Opaque to host | Directly accessible on host |

Named volumes with `driver_opts` bind are used here — they behave like bind mounts (data at `/home/anoukan/data/`) while keeping the clean `volume_name:/path` syntax in the compose file.

---

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Add `anoukan.42.fr` to `/etc/hosts` pointing to `127.0.0.1`
- Create the secrets files (see [DEV_DOC.md](DEV_DOC.md))

### Commands

| Command | Description |
|---|---|
| `make` or `make inception` | Build images and start containers |
| `make re` | Full rebuild (fclean + inception) |
| `make clean` | Stop and remove containers |
| `make fclean` | Stop containers, remove images and volumes |
| `make setup` | Create host data directories |

### Access

- Website: `https://anoukan.42.fr`
- WordPress admin: `https://anoukan.42.fr/wp-admin`

---

## Resources

### Documentation

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress WP-CLI](https://wp-cli.org/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)

### AI usage

Claude (claude-sonnet-4-6) was used during this project for:

- **Understanding concepts** — bind mounts vs volumes, PID 1 best practices, Docker secrets mechanism
- **Debugging guidance** — identifying issues in shell scripts (variable quoting, MariaDB init logic)
- **Code review** — checking Dockerfiles and run.sh scripts against the subject requirements

All AI-generated content was reviewed, tested, and understood before being integrated into the project.
