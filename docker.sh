#!/bin/bash

if [ ! -f /.dockerenv ]; then
  echo "This should run inside docker container"
  exit 1
fi

echo "Uploading authors"
hdfs dfs -mkdir -p /authors/
hdfs dfs -put /tmp/authors.txt /authors/
hdfs fsck /authors/authors.txt

echo "Uploading works"
hdfs dfs -mkdir -p /works/
hdfs dfs -put /tmp/works.txt /works/
hdfs fsck /works/works.txt

echo "Uploading editions"
hdfs dfs -mkdir -p /editions/
hdfs dfs -put /tmp/editions.txt /editions/
hdfs fsck /editions/editions.txt
