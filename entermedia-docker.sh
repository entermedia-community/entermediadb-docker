#!/bin/bash 
#To run this script: sudo ./create.sh xyzcorp 8888
OPERATION=$1
SITE=$2
PORT=$3

#TODO support creating, upgrading, start, stop and removing

ENDPOINT=/media/emsites/${SITE}

# Create entermedia user if needed
groupadd entermedia > /dev/null
useradd -g entermedia entermedia > /dev/null
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Make site mount area 
sudo mkdir -p ${ENDPOINT}/assets
sudo mkdir -p ${ENDPOINT}/data
sudo mkdir -p ${ENDPOINT}/${PORT}
sudo mkdir -p ${ENDPOINT}/elastic
sudo echo "sudo docker start ${SITE}${PORT}" > ${ENDPOINT}/${PORT}/start.sh
sudo echo "sudo docker exec -it ${SITE}${PORT} /opt/entermediadb/tomcat/bin/shutdown.sh" > ${ENDPOINT}/${PORT}/stop.sh
sudo echo "sudo docker stop ${SITE}${PORT}" >> ${ENDPOINT}/${PORT}/stop.sh
sudo echo "sudo docker logs -f --tail 500 ${SITE}${PORT}"  > ${ENDPOINT}/${PORT}/logs.sh
sudo echo "sudo docker exec -it ${SITE}${PORT} bash"  > ${ENDPOINT}/${PORT}/bash.sh

sudo echo "sudo ./stop.sh" > ${ENDPOINT}/${PORT}/update.sh
sudo echo "sudo docker rm ${SITE}${PORT}" >> ${ENDPOINT}/${PORT}/update.sh
sudo echo "sudo docker pull entermediadb/entermediadb9" >> ${ENDPOINT}/${PORT}/update.sh
sudo cp -p entermedia-docker.sh  ${ENDPOINT}/${PORT}/
sudo echo "sudo sh ./entermedia-docker.sh create ${SITE} ${PORT}" >> ${ENDPOINT}/${PORT}/update.sh

sudo chmod 755 ${ENDPOINT}/${PORT}/*.sh

# Fix permissions
sudo chown -R entermedia. "${ENDPOINT}"

echo "Creating new EnterMedia container ${SITE}${PORT}"
# Run Create Docker Instance, add Mounted HotFolders as needed
sudo docker run -t -d --name ${SITE}${PORT} \
	-p $PORT:$PORT \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=${PORT} \
	-v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${ENDPOINT}/${PORT}/tomcat:/opt/entermediadb/tomcat \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	entermediadb/entermediadb9:latest
