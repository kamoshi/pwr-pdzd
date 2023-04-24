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

echo "Processing authors"
gzip -cd data/authors.txt.gz | cut -f5 | head -n 1000 > docker/authors.txt

echo "Processing works"
gzip -cd data/works.txt.gz | cut -f5 | # Filter works
  jq -c '(reduce $authors[] as $obj ({}; .[$obj.key] = true)) as $authorIds
    | select(has("authors") and all(.; .authors[].author.key | in($authorIds)))' \
  --slurpfile authors ./docker/authors.txt \
  > docker/works.txt

echo "Processing editions"
gzip -cd data/editions.txt.gz | cut -f5 | # Filter editions
  jq -c '(reduce $authors[] as $obj ({}; .[$obj.key] = true)) as $authorIds
    | (reduce $works[] as $obj ({}; .[$obj.key] = true)) as $workIds
    | select(has("authors") and has("works") and all(.; .authors[].key | in($authorIds)) and all(.; .works[].key | in($workIds)))' \
  --slurpfile authors ./docker/authors.txt \
  --slurpfile works ./docker/works.txt \
  > docker/works.txt

echo "FINISHED"