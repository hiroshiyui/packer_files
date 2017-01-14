#!/bin/bash

sudo locale-gen zh_TW.UTF-8
echo 'export LC_ALL=en_US.UTF-8' >> $HOME/.profile

# Install essential packages
sudo apt-get -y update && sudo apt-get -y upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install unzip nginx mysql-server php-fpm php-mysql php-gd php-xml php-mbstring composer

# Setup PHP-FPM
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm.service

# Setup MysqL user for Drupal
sudo mysql -uroot -e 'CREATE DATABASE drupal;'
sudo mysql -uroot -e 'GRANT USAGE on *.* to drupal@localhost identified by "drupal";'
sudo mysql -uroot -e 'GRANT ALL PRIVILEGES ON drupal.* to drupal@localhost ;'

# Install & setup Drupal
cd /var/www/html
sudo tar xvfz /tmp/drupal.tar.gz --strip-components=1
sudo rm /tmp/drupal.tar.gz

cd /var/www/html/sites/default
sudo cp default.services.yml services.yml
sudo cp default.settings.php settings.php
sudo mkdir -p /var/www/html/sites/default/files/translations 

sudo chown -R www-data:www-data /var/www/html

# Setup Nginx
sudo mv /tmp/nginx-default /etc/nginx/sites-available/default
sudo service nginx restart

# Shutdown services for data integrity
sudo service mysql stop

# Finish!
sudo apt-get -y clean