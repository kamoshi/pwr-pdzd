#!/bin/bash

cat ./docker/works.txt |
  jq '(reduce $authors[] as $obj ({}; .[$obj.key] = true)) as $set
    | select(all(.; .authors[].author.key | in($set)))' \
  --slurpfile authors ./docker/authors.txt

