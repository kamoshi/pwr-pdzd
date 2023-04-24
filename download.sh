#!/bin/bash
mkdir -p data

### POBIERANIE DANYCH ###
echo "DOWNLOAD LOG:" > data/download.log

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

if [ ! -f data/authors.txt ]; then
  echo "Extracting authors."
  gunzip data/authors.txt.gz 
else
  echo "Authors already extracted"
fi

cat data/authors.txt | cut -f5 | head -n 10000 > docker/authors.txt
