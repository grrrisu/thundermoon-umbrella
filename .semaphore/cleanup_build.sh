#!/usr/bin/env bash

ORGANIZATION="grrrocker"
IMAGE="thundermoon-umbrella"

login_data() {
cat <<EOF
{
  "username": "$DOCKER_USERNAME",
  "password": "$DOCKER_PASSWORD"
}
EOF
}

TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`

curl "https://hub.docker.com/v2/repositories/${ORGANIZATION}/${IMAGE}/tags/build_${SEMAPHORE_GIT_SHA}/" \
-X DELETE \
-H "Authorization: JWT ${TOKEN}"
