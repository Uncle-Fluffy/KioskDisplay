#!/bin/bash
mkdir -p original

for imagefile in *.jpg; do
  [ -e "$imagefile" ] || continue

  # Skip files that already appear to be processed (e.g., foo-2.jpg)
  if [[ "$imagefile" == *-2.jpg ]]; then
    continue
  fi

  # Copy to original/ folder ONLY if it doesn't already exist there
  if [ ! -f "original/$imagefile" ]; then
    cp "$imagefile" "original/$imagefile"
    echo "  Backed up: original/$imagefile"
  fi

  echo "Rotating $imagefile left..."
  # Rotate the image (modifies in-place)
  if magick "$imagefile" -rotate -90 "$imagefile"; then
    # Rename the processed file: foo.jpg becomes foo-2.jpg
    base_name_no_ext="${imagefile%.jpg}"
    new_filename="${base_name_no_ext}-2.jpg"
    mv "$imagefile" "$new_filename"
    echo "  Rotated & Renamed to: $new_filename"
  else
    echo "  ERROR: ImageMagick failed to rotate $imagefile. File not renamed."
  fi
done