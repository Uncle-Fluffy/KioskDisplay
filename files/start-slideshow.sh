#!/bin/bash
sleep 5

CACHE_FILE="$HOME/.sunwait_location"

# If cache file exists, use it
if [ -f "$CACHE_FILE" ]; then
  read -r LAT LON < "$CACHE_FILE"
else
  # Try to get location from IP
  LOC=$(curl -s https://ipinfo.io/loc)
  LAT=${LOC%,*}
  LON=${LOC#*,}

  # Fallback to Pflugerville, TX if lookup failed
  if [ -z "$LAT" ] || [ -z "$LON" ]; then
    LAT="30.4394"
    LON="-97.6200"
  fi

  # Save to cache
  echo "$LAT $LON" > "$CACHE_FILE"
fi

# Get sunset time
sunset_iso_time=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&daily=sunset&timezone=auto&forecast_days=1" | jq -r '.daily.sunset[0]')
read sunset_hour sunset_minute <<< $(date -d "$sunset_iso_time" "+%H %M")
SUNSET_MINUTES=$((10#$sunset_hour * 60 + 10#$sunset_minute))

# Current time in minutes since midnight
HOUR=$(date +%H)
MIN=$(date +%M)
NOW_MINUTES=$((10#$HOUR * 60 + 10#$MIN))

# Define 10:00 PM (night)
NIGHT_TIME_MINUTES=1320

# Pick correct folder
if [ "$NOW_MINUTES" -ge "$NIGHT_TIME_MINUTES" ]; then
  IMG_DIR="/home/tcarter/Pictures/night"
elif [ "$NOW_MINUTES" -ge "$SUNSET_MINUTES" ]; then
  IMG_DIR="/home/tcarter/Pictures/evening"
else
  IMG_DIR="/home/tcarter/Pictures"
fi

# Start slideshow
fbi -T 1 -a --noverbose -t 10 "$IMG_DIR"/*.jpg
#fbi -T 1 -a --noverbose -t 10 /home/tcarter/Pictures/*.jpg 

# sudo pkill fbi
# sudo ./start-slideshow.sh
