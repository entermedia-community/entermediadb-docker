#!/bin/bash 
#To run this script: sudo ./create.sh xyzcorp 8888

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser.
  exit 1
fi

# Setup
OPERATION=$1
SITE=$2
PORT=$3
if [[ $4 ]]; then
  BRANCH=$4
else
  BRANCH=latest
fi
if [[ $5 ]]; then
  IP_ADDR=$5
else
  # Maybe later be smarter about this
  # docker inspect --format '{{ or .NetworkSettings.IPAddress .NetworkSettings.Networks.unbridge.IPAddress}}' $(docker ps -q)
  IP_ADDR=172.101.0.101
fi
ENDPOINT=/media/emsites/${SITE}

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]];
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep entermedia) ]]; then
  docker network create --subnet 172.101.0.0/16 entermedia
fi

# TODO: support upgrading, start, stop and removing

# Make site mount area 
mkdir -p ${ENDPOINT}/webapp
mkdir -p ${ENDPOINT}/data
mkdir -p ${ENDPOINT}/${PORT}
mkdir -p ${ENDPOINT}/elastic

# Create custom scripts
echo "docker start ${SITE}${PORT}" > ${ENDPOINT}/${PORT}/start.sh
echo "docker exec -it ${SITE}${PORT} /opt/entermediadb/tomcat/bin/shutdown.sh" > ${ENDPOINT}/${PORT}/stop.sh
echo "docker stop ${SITE}${PORT}" >> ${ENDPOINT}/${PORT}/stop.sh
echo "docker logs -f --tail 500 ${SITE}${PORT}"  > ${ENDPOINT}/${PORT}/logs.sh
echo "docker exec -it ${SITE}${PORT} bash"  > ${ENDPOINT}/${PORT}/bash.sh
echo "./stop.sh" > ${ENDPOINT}/${PORT}/update.sh
echo "docker rm ${SITE}${PORT}" >> ${ENDPOINT}/${PORT}/update.sh
echo "docker pull entermediadb/entermediadb9:$BRANCH" >> ${ENDPOINT}/${PORT}/update.sh
cp -np entermedia-docker.sh  ${ENDPOINT}/${PORT}/
echo "sh ./entermedia-docker.sh create ${SITE} ${PORT}" >> ${ENDPOINT}/${PORT}/update.sh
chmod 755 ${ENDPOINT}/${PORT}/*.sh

# Fix permissions
chown -R entermedia. "${ENDPOINT}"

echo "Creating new EnterMedia container ${SITE}${PORT}"

# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
	--restart unless-stopped \
	--net entermedia \
	--ip $IP_ADDR \
	--name ${SITE}${PORT} \
	-p $PORT:$PORT \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=${PORT} \
	-v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${ENDPOINT}/${PORT}/tomcat:/opt/entermediadb/tomcat \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	entermediadb/entermediadb9:$BRANCH
