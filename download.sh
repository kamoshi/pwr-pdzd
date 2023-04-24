#!/bin/bash
mkdir -p data

echo "DOWNLOAD LOG:" > data/download.log
echo "# Authors:" >> data/download.log
wget -P data/ https://openlibrary.org/data/ol_dump_authors_latest.txt.gz >> data/download.log 2>&1
echo "# Editions:" >> data/download.log
wget -P data/ https://openlibrary.org/data/ol_dump_editions_latest.txt.gz >> download.log 2>&1
echo "# Works:" >> data/download.log
wget -P data/ https://openlibrary.org/data/ol_dump_works_latest.txt.gz >> download.log 2>&1
