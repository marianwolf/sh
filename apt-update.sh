#!/bin/bash
# Täglich Updates installieren und das System gründlich bereinigen

LOGFILE="/var/log/apt-update.log"
export DEBIAN_FRONTEND=noninteractive

echo "=== Systempflege gestartet: $(date) ===" >> "$LOGFILE"

# 1. Listen aktualisieren
echo "[1/5] Aktualisiere Paketlisten..." >> "$LOGFILE"
if apt-get update >> "$LOGFILE" 2>&1; then
    
    # 2. System-Upgrade durchführen
    echo "[2/5] Führe dist-upgrade aus..." >> "$LOGFILE"
    if apt-get dist-upgrade -y >> "$LOGFILE" 2>&1; then
        
        # 3. Cache aufräumen
        echo "[3/5] Bereinige Paket-Cache (autoclean)..." >> "$LOGFILE"
        apt-get autoclean -y >> "$LOGFILE" 2>&1
        
        # 4. Verwaiste Pakete inklusive Konfiguration restlos löschen (entspricht autoremove + autopurge)
        echo "[4/5] Entferne ungenutzte Pakete restlos (autopurge)..." >> "$LOGFILE"
        apt-get autopurge -y >> "$LOGFILE" 2>&1
        echo "Status: System erfolgreich aktualisiert und bereinigt." >> "$LOGFILE"

        echo "[5/5] Reboot..." >> "$LOGFILE"
        #reboot >> "$LOGFILE" 2>&1
        echo "Status: System neu gestartet." >> "$LOGFILE"
    else
        echo "Status: FEHLER beim dist-upgrade" >> "$LOGFILE"
    fi
else
    echo "Status: FEHLER beim apt update (Abbruch)" >> "$LOGFILE"
fi

echo "=== Systempflege beendet: $(date) ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"