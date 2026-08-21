#!/usr/bin/env bash
#

# Dolphin instellingen
kwriteconfig6 --file dolphinrc --group DetailsMode --key PreviewSize 22
kwriteconfig6 --file dolphinrc --group Dolphin --key ViewMode 1

# Konsole instellingen
kwriteconfig6 --file konsolerc --group KonsoleWindow --key UseSingleInstance true

# Desktop icons (betrouwbaarder via plasmarc)
kwriteconfig6 --file plasmarc --group DesktopIcons --key IconSize 32

# Herstart Dolphin en Konsole (als ze draaien)
pkill -x dolphin || true
pkill -x konsole || true

echo "✔ Alle instellingen zijn bijgewerkt!"

#
