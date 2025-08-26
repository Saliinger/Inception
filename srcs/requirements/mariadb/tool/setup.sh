#!/bin/bash

# Create SQL script
sql_commands=$(cat <<EOF
CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'localhost' IDENTIFIED BY '$MARIADB_PASSWORD';
GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
)

# Execute SQL commands
mysql -u"$MARIADB_USER" -p"$MARIADB_ROOT_PASSWORD" -e "$sql_commands"

sudo systemctl enable mariadb
sudo systemctl start mariadb