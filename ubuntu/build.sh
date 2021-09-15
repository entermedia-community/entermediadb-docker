#!/bin/bash


sudo docker stop emubuntutest
sudo docker rm emubuntutest

DOCKERIMAGE=entermedia10
BRANCH=latest
DOCKERNETWORK=entermedia

#sudo docker build -t entermediadb/emubuntu
#sudo docker build -t entermediadb/emubuntu
sudo docker build -t $DOCKERIMAGE .


# Pull latest images


IP_ADDR="172.18.0.$NODENUMBER"

ENDPOINT=/media/emsites/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep $DOCKERNETWORK) ]]; then
  docker network create --subnet 172.18.0.0/16 $DOCKERNETWORK
fi



sudo docker run -t -d \
	--restart unless-stopped \
	--net $DOCKERNETWORK \
	--name emubuntutest \
	--log-opt max-size=10m --log-opt max-file=10 \
	--cap-add=SYS_PTRACE \
	-e TZ="America/New_York" \
	$DOCKERIMAGE \
	/usr/bin/entermediadb-deploy.sh


sudo docker exec -it emubuntutest bash
