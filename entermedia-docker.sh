#!/bin/bash 

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser.
  exit 1
fi


# Setup
OPERATION=$1
SITE=$2
PORT=$3

# For dev
BRANCH=latest

ALREADY=$(docker ps -aq --filter name=$SITE$PORT)
[[ $ALREADY ]] && docker stop $ALREADY && docker rm -f $ALREADY
if [[ $4 ]]; then
  IP_ADDR=$4
else
  existing=($(docker ps -aq --filter network=entermedia))
  highest=${#existing[@]}
  if (( $highest < 154 )); then
    end=$(($highest + 102))
    IP_ADDR=172.101.0.${end}
  else
    echo You have too many instances on this network.
    exit 1
  fi
fi

ENDPOINT=/media/emsites/$SITE

# Create entermedia user if needed
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi
USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Docker networking
if [[ ! $(docker network ls | grep entermedia) ]]; then
  docker network create --subnet 172.101.0.0/16 entermedia
fi

# Pull latest images
docker pull entermediadb:entermediadb9:$BRANCH

# TODO: support upgrading, start, stop and removing

# Initialize site root 
mkdir -p ${ENDPOINT}/{webapp,data,$PORT,elastic}
INSTANCE=$SITE$PORT

# Create custom scripts
SCRIPTROOT=${ENDPOINT}/$PORT
echo "docker start $INSTANCE" > ${SCRIPTROOT}/start.sh
echo "docker exec -it $INSTANCE /opt/entermediadb/tomcat/bin/shutdown.sh; docker stop $INSTANCE" > ${SCRIPTROOT}/stop.sh
echo "docker logs -f --tail 500 $INSTANCE"  > ${SCRIPTROOT}/logs.sh
echo "docker exec -it $INSTANCE bash"  > ${SCRIPTROOT}/bash.sh
echo "./stop.sh; docker rm $INSTANCE; bash ./entermedia-docker.sh create $SITE $PORT $IP_ADDR;" > ${SCRIPTROOT}/update.sh
echo "docker exec -it -u 0 $INSTANCE entermediadb-update.sh" > ${SCRIPTROOT}/updatedev.sh
cp -np $0  ${SCRIPTROOT}/
chmod 755 ${SCRIPTROOT}/*.sh

# Fix permissions
chown -R entermedia. "${ENDPOINT}"

echo "Creating new EnterMedia container $SITE$PORT"

# Run Create Docker Instance, add Mounted HotFolders as needed
docker run -t -d \
	--restart unless-stopped \
	--net entermedia \
	--ip $IP_ADDR \
	--name $INSTANCE \
	-p $PORT:8080 \
	-p 2$PORT:6001 \
	-p 2$PORT:6001/udp \
	-e USERID=$USERID \
	-e GROUPID=$GROUPID \
	-e CLIENT_NAME=$SITE \
	-e INSTANCE_PORT=${PORT} \
	-v ${ENDPOINT}/webapp:/opt/entermediadb/webapp \
	-v ${ENDPOINT}/data:/opt/entermediadb/webapp/WEB-INF/data \
	-v ${SCRIPTROOT}/tomcat:/opt/entermediadb/tomcat \
	-v ${ENDPOINT}/elastic:/opt/entermediadb/webapp/WEB-INF/elastic \
	entermediadb/entermediadb9:$BRANCH


# Finally, write nginx config
if [[ ! -d /etc/nginx ]]; then
  # No nginx, just exit
  exit
fi

cat >/etc/nginx/conf.d/$SITE$PORT.conf << EOF
server {
          listen        80;
          server_name $SITE.media128.com;
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
                    proxy_pass http://docker_$SITE$PORT;
          }
}

upstream docker_$SITE$PORT {
          least_conn;
          server localhost:$PORT;
}
EOF

