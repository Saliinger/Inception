NAME=inception
USERNAME=anoukan

all:		${NAME}

down:
			docker compose -f ./srcs/docker-compose.yml down

re:			fclean all

clean:
			docker compose -f ./srcs/docker-compose.yml down
			sed -i "/${USERNAME}.42.fr/d" /etc/hosts

fclean:		clean
			docker compose -f ./srcs/docker-compose.yml down --rmi all
			docker compose -f ./srcs/docker-compose.yml down -v
			rm -rf /home/${USERNAME}/data

setup: 
			mkdir -p /home/${USERNAME}/data/mariadb
			mkdir -p /home/${USERNAME}/data/wordpress
			grep -q "${USERNAME}.42.fr" /etc/hosts || echo "127.0.0.1 ${USERNAME}.42.fr" >> /etc/hosts

${NAME}:	setup
			docker compose -f ./srcs/docker-compose.yml up --build -d

.PHONY: all down re clean fclean setup ${NAME}