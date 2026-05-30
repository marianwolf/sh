#!/bin/bash
# Install daily updates with a smart reboot

LOGFILE="/var/log/apt-update.log"
export DEBIAN_FRONTEND=noninteractive

exec >>"$LOGFILE" 2>&1
echo "=== Automation gestartet: $(date) ==="

echo "[1/5] apt-get update"
if apt-get update; then
    echo "[2/5] apt-get dist-upgrade -y"
    if apt-get dist-upgrade -y; then
        echo "[3/5] apt-get autoclean"
        apt-get autoclean
        echo "[4/5] apt-get autopurge"
        apt-get autopurge
        echo "[5/5] reboot"
        # Short pause to allow the log buffer to be written
        sleep 5
        reboot
    else
        echo "ERROR: apt-get dist-upgrade fehlgeschlagen"
    fi
else
    echo "ERROR: apt-get update fehlgeschlagen"
fi
echo "=== Automation beendet: $(date) ==="
echo ""