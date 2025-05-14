#!/bin/bash
mkdir -p output_1920x1080

for infile in *.jpg; do
  outfile="output_1920x1080/${infile}"
  echo "Processing '$infile' -> '$outfile'"
  magick -size 1920x1080 xc:black "$infile" -resize x1080 -gravity center -composite "$outfile" 
done