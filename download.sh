#!/bin/bash
set -e
mkdir -p data

### POBIERANIE DANYCH ###
echo "DOWNLOADING DATA"
echo "check download log for errors"

if [ ! -f data/authors.txt.gz ]; then
  echo "# Authors:" >> data/download.log
  wget --progress=dot:giga -O data/authors.txt.gz https://openlibrary.org/data/ol_dump_authors_latest.txt.gz >> data/download.log 2>&1
else
  echo "Authors already downloaded"
fi

if [ ! -f data/editions.txt.gz ]; then
echo "# Editions:" >> data/download.log
wget --progress=dot:giga -O data/editions.txt.gz https://openlibrary.org/data/ol_dump_editions_latest.txt.gz >> data/download.log 2>&1
else
  echo "Editions already downloaded"
fi

if [ ! -f data/works.txt.gz ]; then
  echo "# Works:" >> data/download.log
  wget --progress=dot:giga -O data/works.txt.gz https://openlibrary.org/data/ol_dump_works_latest.txt.gz >> data/download.log 2>&1
else
  echo "Works already downloaded"
fi


### WSTĘPNA OBRÓBKA ###
echo "PROCESSING DATA"
echo "output in ./docker/"

gzip -cd data/authors.txt.gz | cut -f5 | head -n 20 > docker/authors.txt

gzip -cd data/works.txt.gz | cut -f5 | # Filter works
  jq '(reduce $authors[] as $obj ({}; .[$obj.key] = true)) as $set
    | select(has("authors"))
    | select(all(.; .authors[].author.key | in($set)))' \
  --slurpfile authors ./docker/authors.txt \
  > docker/works.txt

gzip -cd data/editions.txt.gz | cut -f5 | head -n 10 > docker/editions.txt


echo "FINISHED"