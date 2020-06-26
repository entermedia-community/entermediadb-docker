#!/bin/bash -x

if [ "$#" -ne 5 ]; then
    echo "usage: server subnet url nodenumber"
    exit 1
fi

SERVER=$1
SUBNET=$2
URL=$3
NODE=$4
DNS=$5
CONFIGFILE="trial-$URL.conf"
# CONFIGFILE_ROOT="trial.redirect-$URL.conf"
#
# FILE_ROOT='server {
#   server_name '$URL'.'$DNS';
#   return 301 http://'$URL'.'$DNS'$request_uri;
# }'

FILE='server {
  server_name   '$URL'.'$DNS';
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
  listen 443 ssl;
  ssl_certificate /etc/letsencrypt/live/'$DNS'/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/'$DNS'/privkey.pem;
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

upstream cluster_'$URL' {
  server 172.'$SUBNET'.0.'$NODE':8080;
}

server {
  listen        80;
  server_name '$URL'.'$DNS';
  return 301 https://$host$request_uri;
}'
#
# deployToOtherServer() {
# 	NGINX="sudo mv /home/entermedia/$CONFIGFILE_ROOT /etc/nginx/conf.d && sudo chown root. /etc/nginx/conf.d/$CONFIGFILE_ROOT && sudo nginx -s reload"
#
# 	#Create local NGINX config
# 	echo -e $FILE_ROOT > /home/entermedia/$CONFIGFILE
#
# 	#Deploy NGINX config to server and reload service
# 	scp /home/entermedia/$CONFIGFILE_ROOT $SERVER_ROOT:/home/entermedia
# 	ssh -tt $SERVER "$NGINX"
# 	rm /home/entermedia/$CONFIGFILE
#
# 	deployToServer
# }

deployToServer() {
	DEPLOY="sudo bash /home/entermedia/entermedia-docker-trial.sh $URL $NODE $SUBNET"
	NGINX="sudo mv /home/entermedia/$CONFIGFILE /etc/nginx/conf.d && sudo chown root. /etc/nginx/conf.d/$CONFIGFILE && sudo chmod 644 /etc/nginx/conf.d/$CONFIGFILE &&sudo nginx -s reload"

	#Deploy docker instance
	ssh -tt $SERVER "curl -o entermedia-docker-trial.sh -jL docker-trial.entermediadb.org && $DEPLOY"

	#Create local NGINX config
	echo -e $FILE > /home/entermedia/$CONFIGFILE

	#Deploy NGINX config to server and reload service
	scp /home/entermedia/$CONFIGFILE $SERVER:/home/entermedia
	ssh -tt $SERVER "$NGINX"
	rm /home/entermedia/$CONFIGFILE
}

deployToServer

