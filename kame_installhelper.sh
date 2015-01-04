#!/bin/bash

set -e

. /etc/lsb-release

VER=$DISTRIB_RELEASE

if [ `whoami` != 'root' ]; then
	echo 'This script must be ran as root'
	exit 0
fi

if [ $VER !=  "14.04" ]; then
	echo 'This script is meant for Ubuntu 14.04'
	exit 0
fi

# Update the system.
echo 'Checking for system updates and applying them if there are any'
apt-get update && apt-get -y dist-upgrade

# Install base packages.
echo 'Installing the base packages that are needed'
apt-get install -y apache2 php5 libapache2-mod-php5 php5-mcrypt php5-curl php5-geoip php5-mongo curl libcurl3 libcurl3-dev zip git nodejs nodejs-legacy npm
npm install -g bower
bower -s install bootstrap --allow-root

# Clone Kame into /var/www/kame
git clone https://github.com/jgedeon120/kame.git -b xss_fix /var/www/kame

# Create Missing directories and set permissions
mkdir /var/www/.python-eggs /var/www/logs
chown -R www-data:www-data /var/www/.python-eggs /var/www/logs /var/www/kame

# Update 000-default.conf
sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/kame/' /etc/apache2/sites-enabled/000-default.conf

# Reload Apache2.
service apache2 reload

# Kame is set up.
echo 'Kame has been set up'

exit 0