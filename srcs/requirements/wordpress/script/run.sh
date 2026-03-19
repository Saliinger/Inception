#! /bin/sh

DB_PASSWORD=$(cat /run/secrets/db_password)

ADMIN_USER=$(sed -n '1p'  /run/secrets/credential)
ADMIN_EMAIL=$(sed -n '2p'  /run/secrets/credential)
ADMIN_PASSWORD=$(sed -n '3p' /run/secrets/credential)

REGULAR_USER=$(sed -n '4p'  /run/secrets/credential)
REGULAR_EMAIL=$(sed -n '5p'  /run/secrets/credential)
REGULAR_PASSWORD=$(sed -n '6p' /run/secrets/credential)

until mysqladmin ping --host=${DB_HOST} --silent; do sleep 1; done

if [ ! -f "/var/www/html/wp-config.php" ]; then
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O wp-cli.phar

	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp

	wp core download --path=/var/www/html --allow-root
	wp config create --path=/var/www/html --dbhost ${DB_HOST} --dbname ${MYSQL_DATABASE} --dbuser ${MYSQL_USER} --dbpass ${DB_PASSWORD} --allow-root
	wp core install --path=/var/www/html --title "Inception" --url ${DOMAIN_NAME} --admin_user ${ADMIN_USER} --admin_email ${ADMIN_EMAIL} --admin_password ${ADMIN_PASSWORD} --skip-email --allow-root
	wp user create ${REGULAR_USER} ${REGULAR_EMAIL} --user_pass ${REGULAR_PASSWORD} --role=editor --allow-root

fi

exec php-fpm7.4 -F