#!/bin/bash
# Git Updates: clone repository and copy .sh files to cron.daily

LOGFILE="/var/log/git-update.log"
export DEBIAN_FRONTEND=noninteractive

echo "=== Automation gestartet: $(date) ===" >> "$LOGFILE"

REPO_URL="https://github.com/marianwolf/sh"
REPO_DIR="/marianwolf/sh"

# 1. Abhängigkeiten prüfen
if ! command -v git &> /dev/null; then
    echo "ERROR: 'git' ist nicht installiert. Abbruch." >> "$LOGFILE"
    exit 1
fi

# 2. Repository klonen oder aktualisieren
if [ ! -d "$REPO_DIR" ]; then
    echo "Klone Repository $REPO_URL nach $REPO_DIR..." >> "$LOGFILE"
    # Übergeordnetes Verzeichnis erstellen, falls es nicht existiert
    mkdir -p "$(dirname "$REPO_DIR")"
    if ! git clone "$REPO_URL" "$REPO_DIR" >> "$LOGFILE" 2>&1; then
        echo "ERROR: Fehler beim Klonen des Repositories." >> "$LOGFILE"
        echo "=== Automation fehlerhaft beendet ===" >> "$LOGFILE"
        exit 1
    fi
else
    echo "Repository existiert bereits. Aktualisiere $REPO_DIR..." >> "$LOGFILE"
    if ! git -C "$REPO_DIR" pull >> "$LOGFILE" 2>&1; then
        echo "ERROR: Fehler beim Aktualisieren (git pull) des Repositories." >> "$LOGFILE"
        echo "=== Automation fehlerhaft beendet ===" >> "$LOGFILE"
        exit 1
    fi
fi

# 3. .sh-Dateien finden und nach cron.daily kopieren
echo "Suche nach .sh-Dateien in $REPO_DIR..." >> "$LOGFILE"

# Verhindert Fehler, falls Dateinamen Leerzeichen enthalten (Sicherheits-Best-Practice)
while IFS= read -r -d '' SH_FILE; do
    # Basisnamen ohne .sh-Endung extrahieren (wichtig für run-parts/cron)
    BASENAME=$(basename "$SH_FILE" .sh)
    
    # Validierung des Dateinamens für cron (keine Punkte oder Sonderzeichen erlaubt)
    if [[ ! "$BASENAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "WARNING: Dateiname '$BASENAME' ist ungültig für cron.daily. Überspringe..." >> "$LOGFILE"
        continue
    fi

    TARGET="/etc/cron.daily/$BASENAME"
    
    echo "Kopiere $SH_FILE nach $TARGET" >> "$LOGFILE"
    if cp "$SH_FILE" "$TARGET" >> "$LOGFILE" 2>&1; then
        chmod +x "$TARGET" >> "$LOGFILE" 2>&1
    else
        echo "ERROR: Fehler beim Kopieren nach $TARGET" >> "$LOGFILE"
    fi
done < <(find "$REPO_DIR" -type f -name "*.sh" -print0 2>/dev/null)

echo "=== Automation beendet: $(date) ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"