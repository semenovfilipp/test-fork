#!/bin/bash

ROOT=$(dirname "$0")
cd "$ROOT" || exit 1

echo "Building project..."
mvn clean package || exit 1

SERVICE_NAME="yandex-ml-service"
BUILD_BRANCH=$(git rev-parse --abbrev-ref HEAD)
BRANCH_NAME_LOWER=$(echo "$BUILD_BRANCH" | tr '[:upper:]' '[:lower:]')

SECRET=$(LC_CTYPE=C tr -dc 'a-z0-9' </dev/urandom | head -c 24)

IMAGE=docker-pub.caila.io/caila-public/"$SERVICE_NAME"-"$SECRET":"$BRANCH_NAME_LOWER"

DOCKER_BUILDKIT=1 docker build . -t "$IMAGE"

echo "$IMAGE"

docker login docker-pub.caila.io -u 'robot$caila-public' -p 'gaerrvb54zjvRx8klacJjh905QZ4Gw7L'
docker push "$IMAGE"

echo --------------------------------------------------
echo Docker image: "$IMAGE"
echo --------------------------------------------------