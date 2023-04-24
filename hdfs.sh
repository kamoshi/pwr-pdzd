#!/bin/bash
set -e

container_name="master"

if [ ! "$( docker container inspect -f '{{.State.Status}}' $container_name )" == "running" ]; then
  echo "Docker is not running"
  exit 1
fi


echo "COPYING TO DOCKER"

if [ -f docker/authors.txt ]; then
  docker cp docker/authors.txt master:/tmp/authors.txt
else
  echo "Make sure the authors are processed!"
fi

if [ -f docker/works.txt ]; then
  docker cp docker/works.txt master:/tmp/works.txt
else
  echo "Make sure the works are processed!"
fi

if [ -f docker/editions.txt ]; then
  docker cp docker/editions.txt master:/tmp/editions.txt
else
  echo "Make sure the editions are processed!"
fi

# HDFS
echo "UPLOADING TO HDFS"
echo "check upload.log for errors"
docker exec -i master bash < docker.sh >> docker/upload.log 2>&1

echo "FINISHED"
