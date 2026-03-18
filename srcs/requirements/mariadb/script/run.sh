#!/bin/sh
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Initialiser les fichiers système
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Démarrer en background
    mysqld --user=mysql &

    # attend jusqu'a ce que mariadb soit parfetement pret
    until mysqladmin ping --silent; do sleep 1; done

    # creer la bdd et user pour wordpress et changement du mot de passe du root
    mysql -u root -e "
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
    "

    # Arrêter proprement
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

# utilisation de exec pour que mariadb devienne pid 1 et que docker puisse suivre sont bon fonctionnement
exec mysqld --user=mysql