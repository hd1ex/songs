#!/bin/env sh
# This script prints all song source files ordered by their added date  

find songs/ -type f -name '*.tex' | while read file; do
    echo "$(git log --diff-filter=A --follow --format=%aI -- $file | tail -1) $file" 
done | sort -r
