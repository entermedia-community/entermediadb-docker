#!/bin/bash -x

#####################################
#
# Launch EnterMediadb using entermediadb/entermedia:latest Docker image
#
#####################################

set -eo pipefail

if [ -z $BASH ]; then
  echo Using Bash...
  exec "/bin/bash" $0 $@
  exit
fi

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo "You must run this script as the superuser. Usage: sudo ./entermedia-docker.sh sitename nodenumber"
  exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: sudo ./entermedia-docker.sh sitename nodenumber"
    exit 1
fi

# Setup
DOCKERPROJECT=entermediadb
DOCKERIMAGE=entermedia
BRANCH=latest
DOCKERNETWORKBASE=172.25.0
ENDPOINTBASE=/media/emsites
SITE=$1
NODENUMBER=$2

if [ ${#NODENUMBER} -ge 4 ]; then echo "Node Number must be between 100-250" ; exit
else echo "Using Node Number: $NODENUMBER"
fi

INSTANCE=$SITE$NODENUMBER
DOCKERNETWORK=entermedia

# Pull latest images
docker pull $DOCKERPROJECT/$DOCKERIMAGE:$BRANCH

ALREADY=$(docker ps -aq --filter name=$INSTANCE)
[[ $ALREADY ]] && docker stop -t 60 $ALREADY && docker rm -f $ALREADY

IP_ADDR="$DOCKERNETWORKBASE.$NODENUMBER"

ENDPOINT=$ENDPOINTBASE/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep $DOCKERNETWORK) ]]; then
  docker network create --subnet $DOCKERNETWORKBASE.0/16 $DOCKERNETWORK
fi

# TODO: support upgrading, start, stop and removing

# Initialize site root
if [[ ! -f $ENDPOINT/webapp/index.html ]]; then
	mkdir -p ${ENDPOINT}/{webapp,data,$NODENUMBER,elastic,services/extensions}
	chown -R entermedia:entermedia ${ENDPOINT}
	rm -rf "/tmp/$NODENUMBER"  2>/dev/null
	mkdir -p "/tmp/$NODENUMBER"
	chown entermedia:entermedia "/tmp/$NODENUMBER"
fi

# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$NODENUMBER

echo "sudo docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "sudo docker stop -t 60 $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "sudo docker stop -t 60 $INSTANCE && sudo docker start $INSTANCE" > ${SCRIPTROOT}/restart.sh
echo "sudo docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "sudo docker exec -it $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "sudo bash $SCRIPTROOT/entermedia-docker.sh $SITE $NODENUMBER" > ${SCRIPTROOT}/rebuild.sh
echo 'sudo docker exec -it -u 0 '$INSTANCE' entermediadb-update-em11.sh $1 $2' > ${SCRIPTROOT}/update.sh

# Health check
echo "#!/bin/bash +x" > ${SCRIPTROOT}/health.sh
echo "IP=http://$IP_ADDR:9200" >> ${SCRIPTROOT}/health.sh
wget -O - https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/elastic/health-base.sh >> ${SCRIPTROOT}/health.sh

# Versions
#VERSIONS_FILE=${ENDPOINT}/services/versions.sh
#curl -XGET -o ${ENDPOINT}/services/versions.sh https://raw.githubusercontent.com/entermedia-community/entermediadb-docker/master/tomcat/services/versions.sh > /dev/null
#chmod +x ${ENDPOINT}/services/versions.sh
#chown entermedia. ${ENDPOINT}/services/versions.sh
#V_DOCKER=$(docker -v | head -n 1 | awk '{print $3}' | sed 's/,//')
#sed -i "s/V_DOCKER_EXT/$V_DOCKER/g;" $VERSIONS_FILE


cp  $0  ${SCRIPTROOT}/entermedia-docker.sh 2>/dev/null
chmod 755 ${SCRIPTROOT}/*.sh

echo "Review the following URL to get the full TZ list"
echo "https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
echo "Default time zone(TZ) will be US Eastern time"

set -e
# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
	--restart unless-stopped \
	--net $DOCKERNETWORK \
	`#-p 22$NODENUMBER:22` \
	`#-p 93$NODENUMBER:9300` \
	`#-p 92$NODENUMBER:9200` \
	--ip $IP_ADDR \
	--name $INSTANCE \
	--log-opt max-size=10m --log-opt max-file=10 \
	--cap-add=SYS_PTRACE \
	-e TZ="America/New_York" \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=$NODENUMBER \
	-v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	-v ${ENDPOINT}/services:/media/services \
	-v ${ENDPOINT}/$NODENUMBER/tmp:/tmp \
    -v ${SCRIPTROOT}/tomcat:/opt/entermediadb/tomcat \
	$DOCKERPROJECT/$DOCKERIMAGE:$BRANCH \
	/usr/bin/entermediadb-deploy.sh

# Fix /etc/resolv.conf to independently reflect Cloudflare and Google DNS

docker exec -d $INSTANCE sudo sh -c "truncate -s 0 /etc/resolv.conf"
docker exec -d $INSTANCE sudo sh -c "echo 'nameserver 1.1.1.1' >>/etc/resolv.conf"
docker exec -d $INSTANCE sudo sh -c "echo 'nameserver 8.8.8.8' >>/etc/resolv.conf"
docker exec -d $INSTANCE sudo sh -c "echo 'options ndots:0' >>/etc/resolv.conf"


echo ""
echo "Node is running: curl http://$IP_ADDR:8080 in $SCRIPTROOT"
echo ""
echo "- Run ${SCRIPTROOT}/logs.sh to view logs"
