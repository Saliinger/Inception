#!/bin/bash

cd /var/www
sudo wget http://fr.wordpress.org/latest-fr_FR.tar.gz
sudo tar -xzvf latest-fr_FR.tar.gz
sudo rm latest-fr_FR.tar.gz

# install of wordpress in the /var/www