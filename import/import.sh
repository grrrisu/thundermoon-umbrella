#!/usr/bin/env bash
set -e

CONTAINER_TOKEN=$(docker service ps -f 'name=thundermoon' thundermoon_db -q --no-trunc | head -n1)
CONTAINER_NAME=thundermoon_db.1.$CONTAINER_TOKEN

echo "importing data"
docker exec $CONTAINER_NAME pg_restore -U thundermoon --verbose --no-acl --no-owner --clean -d thundermoon_prod import/thundermoon_prod.dump
