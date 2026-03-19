#! /bin/sh

DB_PASSWORD=$(cat /run/secrets/db_password.txt)

if [! -f "/var/www/html/wp-config.php"]
	wget -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp

	wp config create --dbname ${MYSQL_DATABASE} --dbuser ${MYSQL_USER} --dbhost ${DB_HOST}
	wp core install --url ${DOMAIN_NAME} 
fi

exec php-fpm7.4 -F