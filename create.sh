#!/bin/bash -x
# To start and stop this, do the following:
# sudo docker stop unitednations_entermedia
# sudo docker start unitednations_entermedia
#
# This process will remount any drives that were attached at runtime

# To build: sudo docker build -t entermediadb9:latest entermedia-docker

PORT=$2
CLIENT=$1

NODE_ID=${CLIENT}${PORT}

ENTERMEDIA_SHARE=/usr/share/entermediadb
ENDPOINT=/media/clients/${CLIENT}

# Create entermedia user
groupadd entermedia > /dev/null
useradd -g entermedia entermedia > /dev/null
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Make client mount area

if [[ ! -d "${ENDPOINT}/webapp" ]]; then
	mkdir -p ${ENDPOINT}/webapp
fi

if [[ ! -d "${ENDPOINT}/data" ]]; then
	mkdir -p ${ENDPOINT}/data
fi

if [[ ! -d "${ENDPOINT}/logs${PORT}" ]]; then
	mkdir -p ${ENDPOINT}/logs${PORT}
fi

if [[ -d "${ENDPOINT}/temp${PORT}" ]]; then
	mkdir -p ${ENDPOINT}/logs${PORT}
fi

chown -R entermedia. "${ENDPOINT}"

# Fix networking
# echo 'DOCKER_OPTS="--dns 8.8.4.4"' > /etc/default/docker
# Build image for client
# docker build -t "entermedia" entermedia-docker

# Run catalina in image to keep alive
# If you want to run catalina.sh yourself (better logs), then append /bin/bash to the following command to override default
docker run -d --name ${CLIENT}_entermedia -p $PORT:$PORT \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$CLIENT \
	-e INSTANCE_PORT=${PORT} \
	-v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${ENDPOINT}/logs${PORT}:/opt/entermediadb/tomcat/logs \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	entermediadb9
#	/usr/bin/entermediadb-deploy /opt/entermediadb
