#!/bin/bash
sleep 5

CACHE_FILE="$HOME/.sunwait_location"
#FBPID_FILE="/tmp/.slideshow_fbi.pid" # Store PID in /tmp

# --- Time Definitions (Human Friendly Integer Input) ---
# Define times as HHMM (e.g., 800 for 8:00, 730 for 7:30, 2200 for 10:00 PM)
MORNING_START_TIME_HHMM=800  # Represents 08:00 AM
NIGHT_START_TIME_HHMM=2200   # Represents 10:00 PM (22:00)

# --- Calculate minutes since midnight from HHMM format ---
MORNING_START_MINUTES=$(( ( (MORNING_START_TIME_HHMM / 100) * 60) + (MORNING_START_TIME_HHMM % 100) ))
NIGHT_START_MINUTES=$(( ( (NIGHT_START_TIME_HHMM / 100) * 60) + (NIGHT_START_TIME_HHMM % 100) ))

# Function to get location (cached or fetched)
get_location() {
    if [ -f "$CACHE_FILE" ]; then
      read -r LAT LON < "$CACHE_FILE"
    else
      LOC=$(curl --max-time 5 -s https://ipinfo.io/loc)
      LAT=${LOC%,*}
      LON=${LOC#*,}
      if [ -z "$LAT" ] || [ -z "$LON" ]; then
        # No logging here to save writes
        LAT="30.4394" # Pflugerville, TX
        LON="-97.6200"
      fi
      # This is the only persistent write related to location
      echo "$LAT $LON" > "$CACHE_FILE"
    fi
}

# Function to get SUNSET_MINUTES for today
get_todays_sunset_minutes() {
    local sunset_iso
    sunset_iso=$(curl --max-time 5 -s "https://api.open-meteo.com/v1/forecast?latitude=${LAT}&longitude=${LON}&daily=sunset&timezone=auto&forecast_days=1" | jq -r '.daily.sunset[0]')
    if [ "$sunset_iso" == "null" ] || [ -z "$sunset_iso" ]; then
        # No logging
        echo 1080 # Default to 18:00
    else
        local hour minute
        read hour minute <<< $(date -d "$sunset_iso" "+%H %M")
        echo $((10#$hour * 60 + 10#$minute))
    fi
}

# Function to determine the target image directory
determine_target_dir() {
    local now_m=$1
    local sunset_m=$2
    local target_dir

    # CORRECTED: Use global MORNING_START_MINUTES and NIGHT_START_MINUTES
    if [ "$now_m" -ge "$NIGHT_START_MINUTES" ] || [ "$now_m" -lt "$MORNING_START_MINUTES" ]; then
      target_dir="/home/tcarter/Pictures/night"
    elif [ "$now_m" -ge "$sunset_m" ]; then
      target_dir="/home/tcarter/Pictures/evening"
    else
      target_dir="/home/tcarter/Pictures"
    fi
    echo "$target_dir"
}

# Function to start FBI
start_fbi() {
    local dir_to_show="$1"
    [ -z "$dir_to_show" ] && return 1
#    setsid fbi -T 1 -a --noverbose -t 10 "$dir_to_show"/*.jpg > /dev/null 2>&1 &
    setsid fbi -T 1 -a -t 10 "$dir_to_show"/*.jpg > /dev/null 2>&1 &
}

# Function to stop FBI
stop_fbi() {
#    pkill -f "fbi -T 1 -a --noverbose -t 10" # Kill all fbi instances matching the pattern used by this script (SIGTERM first)
    pkill -f "fbi -[T] 1" # Kill all fbi instances matching the pattern used by this script (SIGTERM first)
    sleep 0.5  # Brief pause to allow processes to terminate
#    pkill -9 -f "fbi -T 1 -a --noverbose -t 10" # Force kill any that didn't respond to SIGTERM (SIGKILL)
    pkill -9 -f "fbi -[T] 1" # Force kill any that didn't respond to SIGTERM (SIGKILL)
}

# --- Main Logic ---
# On exit, try to stop fbi. The trap will run even if the script exits due to an error.
trap 'stop_fbi; exit 0' SIGINT SIGTERM EXIT

get_location # Initial location get/cache

CURRENT_IMG_DIR=""
LAST_SUNSET_CALC_DAY=""
SUNSET_MINUTES=$(get_todays_sunset_minutes) # Get sunset once at start
LAST_SUNSET_CALC_DAY=$(date +%j)

sleep 5 # Initial sleep to allow system (e.g., network) to settle if run at boot

while true; do
    NOW_MINUTES=$((10#$(date +%H) * 60 + 10#$(date +%M)))
    CURRENT_DAY_OF_YEAR=$(date +%j)

    if [ "$CURRENT_DAY_OF_YEAR" != "$LAST_SUNSET_CALC_DAY" ]; then
        SUNSET_MINUTES=$(get_todays_sunset_minutes)
        LAST_SUNSET_CALC_DAY="$CURRENT_DAY_OF_YEAR"
    fi

    TARGET_IMG_DIR=$(determine_target_dir "$NOW_MINUTES" "$SUNSET_MINUTES")

    # Handle initial start or scheduled transition
    if [ "$TARGET_IMG_DIR" != "$CURRENT_IMG_DIR" ] || [ -z "$CURRENT_IMG_DIR" ]; then
        if [ -n "$TARGET_IMG_DIR" ]; then # Ensure TARGET_IMG_DIR is not empty
            stop_fbi 
            sleep 1
            start_fbi "$TARGET_IMG_DIR"
            CURRENT_IMG_DIR="$TARGET_IMG_DIR"
        fi
    # If no scheduled transition, check if fbi for current period is alive
    elif [ -n "$CURRENT_IMG_DIR" ]; then # Only check if we expect fbi to be running
#        if ! pgrep -f "fbi -T 1 -a --noverbose -t 10" > /dev/null; then
        if ! pgrep -f "fbi -[T] 1" > /dev/null; then
            # No fbi slideshow running with the core arguments, restart it
            start_fbi "$CURRENT_IMG_DIR"
        fi
    fi

    # Tell systemd we are still alive and healthy
    systemd-notify WATCHDOG=1

    sleep 60 # Check every 60 seconds - simpler and reliable for Pi Zero.
done

# sudo pkill fbi
# sudo ./start-slideshow.sh
