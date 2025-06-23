#!/bin/bash
#
# This script is the production version for the watchdog daemon.
# It is silent and relies only on its exit code.

# Find the default gateway using full, absolute paths for reliability.
GATEWAY_IP=$(/sbin/ip route | /bin/grep default | /usr/bin/awk '{print $3}')

# If no gateway is found, exit with a failure code.
if [ -z "$GATEWAY_IP" ]; then
  exit 1
fi

# Ping the gateway. The script's exit code will be the same as the
# ping command's exit code (0 for success, non-zero for failure).
/bin/ping -c 1 -W 2 "$GATEWAY_IP" >/dev/null 2>&1
exit $?