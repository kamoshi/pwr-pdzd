#!/bin/bash
set -e
mkdir -p data


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


echo "PROCESSING DATA"
echo " -> output in ./docker/"

echo "Processing editions"
gzip -cd data/editions.txt.gz | 
  cut -f5 |
  jq -c 'select(has("authors") and has("works"))' |
  head -n 100000 \
  > docker/editions.txt

# echo "Processing authors"
# gzip -cd data/authors.txt.gz | cut -f5 |
#   jq -c '(reduce $editions[] as $edition ({}; reduce $edition.authors[] as $author (.; .[$author.key] = true))) as $authors
#     | select(.key | in($authors))' \
#     --slurpfile editions ./docker/editions.txt \
#   > docker/authors.txt

# echo "Processing works"
# gzip -cd data/works.txt.gz | cut -f5 |
#   jq -c '(reduce $editions[] as $edition ({}; reduce $edition.works[] as $work (.; .[$work.key] = true))) as $works
#     | select(.key | in($works))' \
#     --slurpfile editions ./docker/editions.txt \
#   > docker/works.txt

echo "FINISHED"
