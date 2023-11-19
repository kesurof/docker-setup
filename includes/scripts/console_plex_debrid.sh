#!/bin/bash

source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"

# activation du venv
source $APP_SETTINGS_DIR/plex_debrid/venv/bin/activate

#lancement console
cd $APP_SETTINGS_DIR/plex_debrid
python3 main.py