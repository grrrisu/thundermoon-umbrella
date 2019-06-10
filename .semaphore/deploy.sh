#!/usr/bin/env bash
set -e

APP_NAME=thundermoon
IMAGE=grrrocker/thundermoon-umbrella:$TAG

echo "Deploying $APP_NAME..."

echo " * Pull image $IMAGE..."
docker pull $IMAGE

cd /srv/sites/thundermoon

IMAGE=$IMAGE docker-compose up