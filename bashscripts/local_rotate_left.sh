#!/bin/bash

for imagefile in *.jpg; do
  [ -e "$imagefile" ] || continue
  echo "Rotating $imagefile left..."
  magick "$imagefile" -rotate -90 "$imagefile"
done