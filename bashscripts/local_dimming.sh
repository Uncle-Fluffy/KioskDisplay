#!/bin/bash
mkdir -p evening
mkdir -p night

# Dimming values. Higher numbers are brighter
# evening_brightness="20"
# night_brightness="60"
# Modulate values. Higher numbers are brighter
evening_brightness="80"
night_brightness="40"

# Calculate saturation as half of brightness
evening_saturation=$((evening_brightness / 2))
night_saturation=$((night_brightness / 2))

for imagefile in *-2.jpg; do
  echo "Updating $imagefile..."
  eveningfile="evening/${imagefile}"
  nightfile="night/${imagefile}"
#  magick "$imagefile" -brightness-contrast -"${evening_brightness}"x0 "$eveningfile"
#  magick "$imagefile" -brightness-contrast -"${night_brightness}"x0 "$nightfile"
  magick "$imagefile" -modulate "${evening_brightness},${evening_saturation}",100 "$eveningfile" # Brightness, Saturation, Hue
  magick "$imagefile" -modulate "${night_brightness},${night_saturation}",100 "$nightfile"
done