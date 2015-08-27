#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='123pass'
PROJECTFOLDER='elementz-exam'

# create project folder
sudo mkdir "/var/www/html/${PROJECTFOLDER}"

# update
sudo apt-get update

# install apache 2.5 and php 5.5 with mcrypt
sudo apt-get install -y apache2
sudo apt-get install -y php5 php5-mcrypt

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECTFOLDER}"
    ErrorLog  "/var/www/html/${PROJECTFOLDER}/error.log"
    CustomLog "/var/www/html/${PROJECTFOLDER}/access.log" combined
    <Directory "/var/www/html/${PROJECTFOLDER}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

# enable php5-mcrypt
sudo php5enmod mcrypt

# restart apache
service apache2 restart

echo "Done!"
