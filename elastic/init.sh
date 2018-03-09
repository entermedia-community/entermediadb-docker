#!/bin/bash

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo You must run this script as the superuser
  exit 1
fi

if [ -z "$1" ]
  then
    echo "No cluster name argument supplied"
  exit 1
fi

if [ -z "$2" ]
  then
    echo "No node number argument supplied"
  exit 1
fi

if [ -z "$3" ]
  then
    echo "No cluster nodes argument supplied"
  exit 1
fi

# Pull latest images
docker pull entermediadb/entermedia-elasticnode

CLUSTER_NAME=$1
NODE=$3
INSTANCE_NAME="$CLUSTER_NAME$NODE"-elastic
IP_ADDR=172.18.0."$NODE"
ENTERMEDIADB_ADDR=172.18.0.$2
BASE_PATH=/media/cluster/"$CLUSTER_NAME"/"$NODE"
ELASTIC_PATH=$4
CONFIG_PATH="$BASE_PATH"/config
DATA_PATH="$BASE_PATH"/data
LOGS_PATH="$BASE_PATH"/logs
TMP__PATH="$BASE_PATH"/tmp

if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
        groupadd entermedia > /dev/null
        useradd -g entermedia entermedia > /dev/null
fi

USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

mkdir -p /media/cluster/"$CLUSTER_NAME"/"$NODE"/{config,data,logs}
chown -R entermedia:entermedia /media/cluster

chown -R entermedia:entermedia "$BASE_PATH"
TMP_PATH=/tmp/$NODE
rm -rf "$TMP_PATH"  2>/dev/null
mkdir -p "$TMP_PATH"
chown entermedia:entermedia "/tmp/$NODE"


if [[ ! $(docker network ls | grep entermedia) ]]; then
  docker network create --subnet 172.18.0.0/16 entermedia
fi

echo "Instance name:" "$INSTANCE_NAME"
echo "IP Address:" "$IP_ADDR"
echo "EntermediaDB address:" "$ENTERMEDIADB_ADDR"
echo "Config PATH=""$CONFIG_PATH"
echo "Data PATH=""$DATA_PATH"
echo "Logs PATH=""$LOGS_PATH"
echo "TMP PATH=""$TMP_PATH"



docker run -d \
        -e USERID=$USERID \
        -e GROUPID=$GROUPID \
        -e CLUSTER_NAME="$CLUSTER_NAME" \
        -e ELASTICSEARCH_ADDR="$IP_ADDR" \
        -e ENTERMEDIADB_ADDR="$ENTERMEDIADB_ADDR" \
        --restart unless-stopped \
        --name "$INSTANCE_NAME" \
        --net entermedia \
        --ip "$IP_ADDR" \
        -v "$CONFIG_PATH":/etc/elasticsearch \
        -v "$DATA_PATH":/var/lib/elasticsearch \
        -v "$LOGS_PATH":/var/log/elasticsearch \
        -v "$TMP_PATH":/tmp \
        -v $ELASTIC_PATH:/opt/entermediadb/webapp/WEB-INF/elastic/repos \
        entermediadb/entermedia-elasticnode

echo "Node is running: $IP_ADDR:9200"