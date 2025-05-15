#!/bin/bash
# convert HEIC files to jpg. Rename jpeg and JPG to jpg. 
#Show all files that are NOT .jpg in the end

#convert from .heic to .jpg
for imagefile in *.heic *.HEIC; do
  [ -e "$imagefile" ] || continue
  echo "Converting '$imagefile'"
  magick "$imagefile" "${imagefile%.*}.jpg" && rm "$imagefile"
done

#convert from .JPG or .jpeg or .JPEG to .jpg
for imagefile in *.JPG *.jpeg *.JPEG; do
  [ -e "$imagefile" ] || continue
  echo "Renaming '$imagefile'"
  mv "$imagefile" "${imagefile%.*}.jpg"
done

# List any files that are not .jpg
echo "--- unknown file types ---"
find . -maxdepth 1 -type f ! -name '*.jpg'