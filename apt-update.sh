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
export DEBIAN_FRONTEND=noninteractive

log "=== Automation started: $(date) ==="

log "[1/5] apt-get update"
if apt-get -qq update; then
  log "[2/5] apt-get dist-upgrade -y"
  if apt-get -y -qq dist-upgrade; then
    log "[3/5] apt-get autoclean"
    apt-get -y -qq autoclean
    log "[4/5] apt-get autopurge"
    apt-get -y -qq autopurge
    log "[5/5] reboot"
    sleep 5
    reboot
  else
    log "ERROR: apt-get dist-upgrade failed"
  fi
else
  log "ERROR: apt-get update failed"
fi

log "=== Automation finished: $(date) ==="