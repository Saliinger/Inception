NAME = Inception
COMPOSE_FILE = ./srcs/docker-compose.yml

.PHONY: all ${NAME} down clean fclean re

${NAME}: all

all: 
	echo "anoukan.42.fr" >> /etc/hosts
	docker compose -f ${COMPOSE_FILE} up 

down:
	docker compose -f ${COMPOSE_FILE} down 

clean: down

fclean: down

re: fclean all


# -d is for detach and put it as a background task