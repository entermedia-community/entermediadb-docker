#!/bin/bash -x
#This is used to create a custom Docker from the docker file
#Useful when you already have an EnterMedia user userids
#To run this script: sudo ./create.sh xyzcorp 8888
CLIENT=$1
PORT=$2

NODE_ID=${CLIENT}${PORT}
ENTERMEDIA_SHARE=/usr/share/entermediadb
ENDPOINT=/media/clients/${CLIENT}

INSTANCE="${CLIENT}_entermedia"

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 600 $ALREADY && docker rm -f $ALREADY

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
docker build -t "entermediadblocal" .

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
	entermediadblocal
