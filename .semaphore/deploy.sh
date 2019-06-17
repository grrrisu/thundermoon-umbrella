#!/usr/bin/env bash
set -e

APP_NAME=thundermoon
IMAGE=grrrocker/thundermoon-umbrella:$TAG

echo "pull image $IMAGE..."
docker pull $IMAGE

cd /srv/sites/thundermoon.zero-x.net

if docker node ls > /dev/null 2>&1; then
  echo "swarm already initialized"
else
  echo "docker swarm initializing.."
  docker swarm init
fi

echo "stack deploy"
IMAGE=$IMAGE docker stack deploy --with-registry-auth -c docker-compose.yml --prune $APP_NAME

echo " docker prune..."
docker system prune -af
