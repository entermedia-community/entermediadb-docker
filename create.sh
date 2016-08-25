#!/bin/bash -x
#To run this script: sudo ./create.sh xyzcorp 8888
SITE=$1
PORT=$2

ENDPOINT=/media/emsites/${SITE}
USERID=9009
GROUPID=9009

# Create entermedia user if needed
sudo groupadd -g $GROUPID entermedia
sudo useradd -ms /bin/bash entermedia -g entermedia -u $USERID

# Make site mount area
if [[ ! -d "${ENDPOINT}/webapp" ]]; then
	sudo mkdir -p ${ENDPOINT}/webapp
fi

if [[ ! -d "${ENDPOINT}/data" ]]; then
	sudo mkdir -p ${ENDPOINT}/data
fi

if [[ ! -d "${ENDPOINT}/logs${PORT}" ]]; then
	sudo mkdir -p ${ENDPOINT}/logs${PORT}
fi

if [[ -d "${ENDPOINT}/temp${PORT}" ]]; then
	sudo mkdir -p ${ENDPOINT}/logs${PORT}
fi

# Fix permissions
sudo chown -R entermedia. "${ENDPOINT}"

# Run Create Docker Instance
sudo docker run -d --name ${SITE}_entermedia \
	-p $PORT:$PORT \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=${PORT} \
	-v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${ENDPOINT}/logs${PORT}:/opt/entermediadb/tomcat/logs \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	entermediadb/entermediadb9
