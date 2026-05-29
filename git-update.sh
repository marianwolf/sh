#!/bin/bash
# Git Updates herunterladen und als Cronjob installieren

LOGFILE="/var/log/git-update.log"
export DEBIAN_FRONTEND=noninteractive

echo "=== Automation gestartet: $(date) ===" >> "$LOGFILE"

# Define arrays of source URLs and target cron files
SOURCES=(
    "https://raw.githubusercontent.com/marianwolf/sh/main/apt-update.sh"
    "https://raw.githubusercontent.com/marianwolf/sh/main/git-update.sh"
)

TARGETS=(
    "/etc/cron.daily/apt-update"
    "/etc/cron.daily/git-update"
)

# Check that arrays have same length
if [ ${#SOURCES[@]} -ne ${#TARGETS[@]} ]; then
    echo "ERROR: SOURCES and TARGETS arrays must have the same length" >> "$LOGFILE"
    echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
    echo "" >> "$LOGFILE"
    exit 1
fi

# Update each cron file
for i in "${!SOURCES[@]}"; do
    SOURCE="${SOURCES[$i]}"
    TARGET="${TARGETS[$i]}"
    
    echo "[$((i+1))/${#SOURCES[@]}] Updating $TARGET from $SOURCE" >> "$LOGFILE"
    curl -o "$TARGET" "$SOURCE" >> "$LOGFILE" 2>&1
    chmod +x "$TARGET" >> "$LOGFILE" 2>&1
done

echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"