#!/bin/bash
# If you want to rebuild, just do the following:
# sudo docker build -t emdrupal:php5 docker-drupal

CLIENT=$1
if [[ ! $CLIENT ]]; then
  echo You must specify a client to use this.
  exit 1
fi

# Default port
if [[ $2 ]]; then
  PORT=$2
else
  PORT=8004
fi

# Default name
if [[ $3 ]]; then
  CNAME=$3
else
  CNAME=entermedia_drupal
fi

# Docker networking
if [[ ! $(sudo docker network ls | grep embridge) ]]; then
        sudo docker network create --subnet=172.18.0.0/16 embridge
fi

DIR_ROOT=/media/clients/$CLIENT
DRUPAL_ROOT=$DIR_ROOT/drupal7
if [[ $(id -u www-data) ]]; then
	sudo groupadd -g 33 www-data
	sudo useradd -ms /bin/bash www-data -g www-data -u 33
fi
DRUPAL_VERSION=7.50
DRUPAL_MD5=f23905b0248d76f0fc8316692cd64753
#add more than one site
if [[ ! -d "$DRUPAL_ROOT" ]]; then
	sudo mkdir -p $DRUPAL_ROOT/html
	sudo chown -R www-data. $DRUPAL_ROOT
	sudo chmod 755 $DRUPAL_ROOT
	cd $DRUPAL_ROOT/html
	sudo curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
        	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	        && sudo tar -xz --strip-components=1 -f drupal.tar.gz \
	        && sudo rm drupal.tar.gz \
	        && sudo chown -R www-data:www-data .
fi

# If you want to run start.sh yourself just append /bin/bash to below line
sudo docker run -d -t -i \
	--net embridge \
	--ip 172.18.0.3 \
	--name $CNAME \
	-p 127.0.0.1:${PORT}:80 \
	-v $DRUPAL_ROOT/html:/var/www/html \
	-v $DRUPAL_ROOT/data:/data \
	emdrupal:latest

#
#	NOTE: if you must 'reset' Drupal, you may do so by deleting
#	dropping all tables in the db and deleting settings.php from
#	$DRUPAL_ROOT/sites/default .. might want to back up first :)
#
