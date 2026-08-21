#!/usr/bin/env bash
#

# dolphin icon size 22 pixels
kwriteconfig6 --file dolphinrc --group DetailsMode --key PreviewSize 22

# view mode details
kwriteconfig6 --file dolphinrc --group Dolphin --key ViewMode 1

# konsole ✅Run all Konsole windows in a single prosess
kwriteconfig6 --file konsolerc --group KonsoleWindow --key UseSingleInstance true

