#!/bin/bash

INSTANCENAME=emubuntutest3

sudo docker stop $INSTANCENAME
sudo docker rm $INSTANCENAME

DOCKERIMAGE=emubuntubuild2
BRANCH=latest
DOCKERNETWORK=entermediaubuntu

sudo docker build -t $DOCKERIMAGE .

# Pull latest images
IP_ADDR="172.18.0.$NODENUMBER"

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
	--name $INSTANCENAME \
	--log-opt max-size=10m --log-opt max-file=10 \
	--cap-add=SYS_PTRACE \
	-e TZ="America/New_York" \
	$DOCKERIMAGE


sudo docker exec -it $INSTANCENAME bash
