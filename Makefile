NAME=inception
USERNAME=anoukan

all:		${NAME}

down:
			docker compose -f ./srcs/docker-compose.yml down

re:			fclean all

clean:
			echo "" >> /etc/hostname

fclean:		clean

setup: 
			mkdir -p /home/${USERNAME}/data/mariadb
			mkdir -p /home/${USERNAME}/data/wordpress
			echo "localhost ${USERNAME}.42.fr" >> /etc/hostname

${NAME}:	setup
			docker compose -f ./srcs/docker-compose.yml up --build -d

.PHONY: all down re clean fclean setup ${NAME}