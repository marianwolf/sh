#!/bin/bash
# Install daily updates with a smart reboot

LOGFILE="/var/log/apt-update.log"
export DEBIAN_FRONTEND=noninteractive

echo "=== Automation gestartet: $(date) ===" >> "$LOGFILE"

echo "[1/5] apt-get update" >> "$LOGFILE"
if apt-get update >> "$LOGFILE" 2>&1; then
    echo "[2/5] apt-get dist-upgrade -y" >> "$LOGFILE"
    if apt-get dist-upgrade -y >> "$LOGFILE" 2>&1; then
        echo "[3/5] apt-get autoclean" >> "$LOGFILE"
        apt-get autoclean >> "$LOGFILE" 2>&1
        echo "[4/5] apt-get autopurge" >> "$LOGFILE"
        apt-get autopurge >> "$LOGFILE" 2>&1
        if [ -f /var/run/reboot-required ]; then
            echo "[5/5] reboot" >> "$LOGFILE"
            # Short pause to allow the log buffer to be written
            sleep 5
            reboot
        else
            echo "[5/5] no reboot" >> "$LOGFILE"
        fi
    else
        echo "ERROR: apt-get dist-upgrade fehlgeschlagen" >> "$LOGFILE"
    fi
else
    echo "ERROR: apt-get update fehlgeschlagen" >> "$LOGFILE"
fi
echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"