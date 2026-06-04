#!/bin/bash
# Clone repository and copy .sh files to cron.daily
# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root."
  exit 1
fi
set -euo pipefail

# Prevent concurrent runs
LOCKFILE="/var/run/git-update.lock"
exec 200>"$LOCKFILE"
flock -n 200 || { echo "Another instance is running. Exiting."; exit 1; }
trap 'rm -f "$LOCKFILE"' EXIT

LOGFILE="/var/log/git-update.log"
export DEBIAN_FRONTEND=noninteractive

log() {
    echo "$1" | tee -a "$LOGFILE"
}

# Repository configuration
REPO_URL="https://github.com/marianwolf/sh"
REPO_DIR="/marianwolf/sh"

log "=== Automation started: $(date) ==="

# Check if git is installed
if ! command -v git &> /dev/null; then
    log "ERROR: 'git' is not installed. Exiting."
    log "=== Automation finished: $(date) ==="
    exit 1
fi

# Clone or update repository
if [ ! -d "$REPO_DIR" ]; then
    log "Cloning repository $REPO_URL into $REPO_DIR..."
    mkdir -p "$(dirname "$REPO_DIR")"
    if ! git clone "$REPO_URL" "$REPO_DIR"; then
        log "ERROR: Failed to clone repository."
        log "=== Automation finished: $(date) ==="
        exit 1
    fi
else
    log "Repository exists. Updating $REPO_DIR..."
    if ! git -C "$REPO_DIR" pull -q; then
        log "ERROR: Failed to update repository."
        log "=== Automation finished: $(date) ==="
        exit 1
    fi
fi

# Copy .sh files to cron.daily
log "Searching for .sh files in $REPO_DIR..."
while IFS= read -r -d '' SH_FILE; do
    BASENAME=$(basename "$SH_FILE" .sh)
    if [[ ! "$BASENAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log "WARNING: Invalid filename '$BASENAME' for cron.daily. Skipping..."
        continue
    fi

    TARGET="/etc/cron.daily/$BASENAME"
    log "Copying $SH_FILE to $TARGET"
    if cp "$SH_FILE" "$TARGET"; then
        chmod +x "$TARGET"
    else
        log "ERROR: Failed to copy to $TARGET"
    fi
done < <(find "$REPO_DIR" -type f -name "*.sh" -print0 2>/dev/null)

log "=== Automation finished: $(date) ==="