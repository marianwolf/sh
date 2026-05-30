#!/bin/bash
# Git Updates: clone repository and copy .sh files to cron.daily

LOGFILE="/var/log/git-update.log"
REPO_URL="https://github.com/marianwolf/sh"
REPO_DIR="/marianwolf/sh"
export DEBIAN_FRONTEND=noninteractive

# Redirect all output to logfile
exec >>"$LOGFILE" 2>&1
echo "=== Automation gestartet: $(date) ==="

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "ERROR: 'git' ist nicht installiert. Abbruch."
    echo "=== Automation beendet: $(date) ==="
    exit 1
fi

# Clone or update repository
if [ ! -d "$REPO_DIR" ]; then
    echo "Klone Repository $REPO_URL nach $REPO_DIR..."
    mkdir -p "$(dirname "$REPO_DIR")"
    if ! git clone "$REPO_URL" "$REPO_DIR"; then
        echo "ERROR: Fehler beim Klonen des Repositories."
        echo "=== Automation beendet: $(date) ==="
        exit 1
    fi
else
    echo "Repository existiert bereits. Aktualisiere $REPO_DIR..."
    if ! git -C "$REPO_DIR" pull; then
        echo "ERROR: Fehler beim Aktualisieren (git pull) des Repositories."
        echo "=== Automation beendet: $(date) ==="
        exit 1
    fi
fi

# Copy .sh files to cron.daily
echo "Suche nach .sh-Dateien in $REPO_DIR..."
while IFS= read -r -d '' SH_FILE; do
    BASENAME=$(basename "$SH_FILE" .sh)
    if [[ ! "$BASENAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "WARNING: Dateiname '$BASENAME' ist ungültig für cron.daily. Überspringe..."
        continue
    fi

    TARGET="/etc/cron.daily/$BASENAME"
    echo "Kopiere $SH_FILE nach $TARGET"
    if cp "$SH_FILE" "$TARGET"; then
        chmod +x "$TARGET"
    else
        echo "ERROR: Fehler beim Kopieren nach $TARGET"
    fi
done < <(find "$REPO_DIR" -type f -name "*.sh" -print0 2>/dev/null)

echo "=== Automation beendet: $(date) ==="
echo ""