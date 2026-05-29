#!/bin/bash
# Git Updates: clone repository and copy .sh files to cron.daily

LOGFILE="/var/log/git-update.log"
export DEBIAN_FRONTEND=noninteractive

echo "=== Automation gestartet: $(date) ===" >> "$LOGFILE"

REPO_URL="https://github.com/marianwolf/sh"
REPO_DIR="/marianwolf/sh"

if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning repository $REPO_URL to $REPO_DIR" >> "$LOGFILE"
    if ! git clone "$REPO_URL" "$REPO_DIR" >> "$LOGFILE" 2>&1; then
        echo "ERROR: Failed to clone repository" >> "$LOGFILE"
        echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
        echo "" >> "$LOGFILE"
        exit 1
    fi
else
    echo "Pulling latest changes in $REPO_DIR" >> "$LOGFILE"
    if ! (cd "$REPO_DIR" && git pull && git diff) >> "$LOGFILE" 2>&1; then
        echo "ERROR: Failed to pull repository" >> "$LOGFILE"
        echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
        echo "" >> "$LOGFILE"
        exit 1
    fi
fi

# Find all .sh files in the cloned repository
echo "Searching for .sh files in $REPO_DIR" >> "$LOGFILE"
SH_FILES=$(find "$REPO_DIR" -type f -name "*.sh" 2>/dev/null)
if [ -z "$SH_FILES" ]; then
    echo "WARNING: No .sh files found in repository" >> "$LOGFILE"
else
    echo "Found $(echo "$SH_FILES" | wc -l) .sh files" >> "$LOGFILE"
    for SH_FILE in $SH_FILES; do
        # Get the base filename
        BASENAME=$(basename "$SH_FILE" .sh)
        TARGET="/etc/cron.daily/$BASENAME"
        echo "Copying $SH_FILE to $TARGET" >> "$LOGFILE"
        cp "$SH_FILE" "$TARGET" >> "$LOGFILE" 2>&1
        chmod +x "$TARGET" >> "$LOGFILE" 2>&1
    done
fi

echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"