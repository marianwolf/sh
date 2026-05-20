#!/bin/bash
# Täglich Updates installieren

LOGFILE="/var/log/apt-update.log"
export DEBIAN_FRONTEND=noninteractive

echo "=== Automation gestartet: $(date) ===" >> "$LOGFILE"

echo "[1/5] apt-get update" >> "$LOGFILE"
if apt-get update >> "$LOGFILE" 2>&1; then
    echo "[2/5] apt-get dist-upgrade -y" >> "$LOGFILE"
    if apt-get dist-upgrade -y >> "$LOGFILE" 2>&1; then
        echo "[3/5] apt-get autoclean -y" >> "$LOGFILE"
        apt-get autoclean -y >> "$LOGFILE" 2>&1
        echo "[4/5] apt-get autopurge -y" >> "$LOGFILE"
        apt-get autopurge -y >> "$LOGFILE" 2>&1
        echo "[5/5] reboot" >> "$LOGFILE"
        #reboot >> "$LOGFILE" 2>&1
    else
        echo "ERROR: apt-get dist-upgrade -y" >> "$LOGFILE"
    fi
else
    echo "ERROR: apt-get update" >> "$LOGFILE"
fi
echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"