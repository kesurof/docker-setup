#!/bin/bash

source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"

# activation du venv
source /home/$USER/seedbox/app_settings/plex_debrid/venv/bin/activate

#lancement console
cd /home/$USER/seedbox/app_settings/plex_debrid
python3 main.py