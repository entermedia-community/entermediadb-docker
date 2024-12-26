#!/bin/bash

# Launch Ollama Docker instance with dedicated IP and external models directory

if [ -z $BASH ]; then
  echo "Using Bash..."
  exec "/bin/bash" $0 $@
  exit
fi

# Root check
if [[ ! $(id -u) -eq 0 ]]; then
  echo "You must run this script as the superuser."
  exit 1
fi

# Argument check
if [ "$#" -ne 3 ]; then
    echo "Usage: ./ollama-docker.sh instance_name last_octet /path/to/external/models"
    exit 1
fi

INSTANCE_NAME=$1
LAST_OCTET=$2
MODELS_DIR=$3

# Validate last octet
if ! [[ $LAST_OCTET =~ ^[0-9]+$ ]] || [ "$LAST_OCTET" -lt 100 ] || [ "$LAST_OCTET" -gt 250 ]; then
  echo "Error: Last octet must be a number between 100 and 250."
  exit 1
fi

# Calculate full IP address
SUBNET="172.20.0"
IP_ADDR="${SUBNET}.${LAST_OCTET}"

# Ensure the entermedia user exists
if [[ ! $(id -u entermedia 2> /dev/null) ]]; then
  echo "Creating entermedia user..."
  groupadd entermedia > /dev/null
  useradd -g entermedia entermedia > /dev/null
fi

USERID=$(id -u entermedia)
GROUPID=$(id -g entermedia)

# Ensure the external models directory exists and assign ownership
if [ ! -d "$MODELS_DIR" ]; then
  echo "Creating external models directory: $MODELS_DIR"
  mkdir -p "$MODELS_DIR"
fi

echo "Assigning ownership of $MODELS_DIR to entermedia user..."
chown -R entermedia:entermedia "$MODELS_DIR"

# Pull latest Ollama image
docker pull ollama/ollama:latest

# Check and create Docker network if not exists
NETWORK_NAME="ollama"
if [[ ! $(docker network ls | grep $NETWORK_NAME) ]]; then
  echo "Creating Docker network $NETWORK_NAME..."
  docker network create --subnet=172.20.0.0/16 $NETWORK_NAME
fi

# Stop and remove any existing instance with the same name
EXISTING_INSTANCE=$(docker ps -aq --filter name=$INSTANCE_NAME)
if [[ $EXISTING_INSTANCE ]]; then
  echo "Stopping and removing existing instance: $INSTANCE_NAME"
  docker stop $EXISTING_INSTANCE && docker rm $EXISTING_INSTANCE
fi

# Run Docker instance with dedicated IP and mounted models directory
docker run -d --restart unless-stopped \
  --net $NETWORK_NAME \
  --ip $IP_ADDR \
  --name $INSTANCE_NAME \
  -e USERID=$USERID \
  -e GROUPID=$GROUPID \
  -v "$MODELS_DIR:/root/.ollama/models" \
  ollama/ollama:latest

echo "Ollama instance $INSTANCE_NAME is running on IP: $IP_ADDR."
