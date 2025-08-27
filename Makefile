all: up

up:
	sudo mkdir -p /home/anoukan/data/wordpress
	sudo mkdir -p /home/anoukan/data/mariadb
	sudo chown -R $(USER):$(USER) /home/anoukan/data
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -af
	docker volume prune -f

fclean: clean
	sudo rm -rf /home/anoukan/data/wordpress
	sudo rm -rf /home/anoukan/data/mariadb

re: fclean all

logs:
	docker compose -f srcs/docker-compose.yml logs -f

status:
	docker compose -f srcs/docker-compose.yml ps

.PHONY: all up down clean fclean re logs status