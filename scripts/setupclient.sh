#!/bin/bash -x

if [ "$#" -ne 4 ]; then
    echo "usage: server subnet url nodenumber"
    exit 1
fi

SERVER_ROOT="mediadb08"
SERVER=$1
SUBNET=$2
URL=$3
NODE=$4
DNS=$5
CONFIGFILE="trial-$URL.conf"
CONFIGFILE_ROOT="trial.redirect-$URL.conf"

FILE_ROOT='server {
  server_name '$URL'.com;
  return 301 http://'$SERVER'$request_uri;
}'

FILE='server {
  server_name   '$URL'.com;
  location / {
                    proxy_max_temp_file_size 2048m;
                    proxy_read_timeout 1200s;
                    proxy_send_timeout 1200s;
                    proxy_connect_timeout 1200s;
                    client_max_body_size 100G;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "upgrade";
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header Host $http_host;
                    proxy_pass http://cluster_'$URL';
  }
  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/'$DNS'/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/'$DNS'/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

upstream cluster_'$URL' {
  server 172.'$SUBNET'.0.'$NODE':8080;
}

server {
    if ($host = '$URL'.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

  listen        80;
  server_name '$URL'.com;
  return 404; # managed by Certbot
}'

deployToOtherServer() {
	NGINX="sudo mv /home/entermedia/$CONFIGFILE_ROOT /etc/nginx/conf.d && sudo chown root. /etc/nginx/conf.d/$CONFIGFILE_ROOT && sudo nginx -s reload"

	#Create local NGINX config
	echo -e $FILE_ROOT > /home/entermedia/$CONFIGFILE

	#Deploy NGINX config to server and reload service
	scp /home/entermedia/$CONFIGFILE_ROOT $SERVER_ROOT:/home/entermedia
	ssh -tt $SERVER "$NGINX"
	rm /home/entermedia/$CONFIGFILE

	deployToServer
}

deployToServer() {
	DEPLOY="sudo bash ~/entermedia-docker-trial.sh $URL $NODE $SUBNET"
	NGINX="sudo mv /home/entermedia/$CONFIGFILE /etc/nginx/conf.d && sudo chown root. /etc/nginx/conf.d/$CONFIGFILE && sudo nginx -s reload"

	#Deploy docker instance
	ssh -tt $SERVER "curl -o entermedia-docker-trial.sh -jL https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/entermedia-docker-trial.sh && $DEPLOY"

	#Create local NGINX config
	echo -e $FILE > /home/entermedia/$CONFIGFILE

	#Deploy NGINX config to server and reload service
	scp /home/entermedia/$CONFIGFILE $SERVER:/home/entermedia
	ssh -tt $SERVER "$NGINX"
	rm /home/entermedia/$CONFIGFILE
}

if [ "$SERVER" -ne "$SERVER_ROOT" ]; then
	deployToOtherServer
else
	deployToServer
fi
