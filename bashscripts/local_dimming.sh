#!/bin/bash
mkdir -p evening
mkdir -p night

# Dimming values. Higher numbers are brighter
evening_brightness="20"
night_brightness="60"

for imagefile in *-2.jpg; do
  eveningfile="evening/${imagefile}"
  nightfile="night/${imagefile}"
  magick "$imagefile" -brightness-contrast -"${evening_brightness}"x0 "$eveningfile"
  magick "$imagefile" -brightness-contrast -"${night_brightness}"x0 "$nightfile"
done