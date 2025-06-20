#!/bin/bash
#
# This script dynamically finds the default gateway (the router) and pings it.
# It is designed to be called by the watchdog daemon.
# - Exits with 0 (success) if the router is reachable.
# - Exits with 1 (failure) if there is no gateway or it is unreachable.

# Find the default gateway IP address using the 'ip route' command.
# This is the most reliable modern method.
GATEWAY_IP=$(ip route | grep default | awk '{print $3}')

# Check if we successfully found a gateway IP.
# If the variable is empty, it means the Pi has no network connection at all.
if [ -z "$GATEWAY_IP" ]; then
  # No gateway found, so the network is definitely down.
  # Exit with a failure code to trigger the watchdog.
  exit 1
fi

# Ping the discovered gateway IP.
# -c 1: Send only one packet.
# -W 2: Wait a maximum of 2 seconds for a reply.
# >/dev/null: Discard the output, we only care about the exit code.
if /bin/ping -c 1 -W 2 "$GATEWAY_IP" > /dev/null; then
  # Success: The router is reachable.
  # Exit with 0 to "pet" the watchdog and tell it everything is fine.
  exit 0
else
  # Failure: We have a gateway, but we can't ping it.
  # The network stack is likely frozen. Exit with 1 to trigger a reboot.
  exit 1
fi