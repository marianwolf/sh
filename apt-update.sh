#!/bin/bash
# Daily apt updates with reboot
# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi
set -euo pipefail

# Prevent concurrent runs
LOCKFILE="/var/run/apt-update.lock"
exec 200>"$LOCKFILE"
flock -n 200 || { echo "Another instance is running. Exiting."; exit 1; }
trap 'rm -f "$LOCKFILE"' EXIT

LOGFILE="/var/log/apt-update.log"
exec >>"$LOGFILE" 2>&1
export DEBIAN_FRONTEND=noninteractive

echo "=== Automation started: $(date) ==="

echo "[1/5] apt-get update"
if apt-get -qq update; then
  echo "[2/5] apt-get dist-upgrade -y"
  if apt-get -y -qq dist-upgrade; then
    echo "[3/5] apt-get autoclean"
    apt-get -y -qq autoclean
    echo "[4/5] apt-get autopurge"
    apt-get -y -qq autopurge
    echo "[5/5] reboot"
    sleep 5
    reboot
  else
    echo "ERROR: apt-get dist-upgrade failed"
  fi
else
  echo "ERROR: apt-get update failed"
fi

echo "=== Automation finished: $(date) ==="