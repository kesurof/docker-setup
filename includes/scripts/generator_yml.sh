#!/bin/bash

# Emplacement du fichier .env
env_file="./.env"

# Vérifier si le fichier .env existe
if [ ! -f "$env_file" ]; then
  echo "Le fichier .env n'existe pas. Veuillez d'abord créer le fichier .env avec les données nécessaires."
  exit 1
fi

# Charger les variables du fichier .env
source "$env_file"

# Générer le docker-compose.yml
cat <<EOL > docker-compose.yml
version: '3'
services:
  myapp:
    image: myapp-image
    environment:
      USER_HOME: "$USER_HOME"
      LOCAL_DIR: "$LOCAL_DIR"
      MEDIAS_DIR: "$MEDIAS_DIR"
      APP_SETTINGS_DIR: "$APP_SETTINGS_DIR"
      RCLONE_DIR: "$RCLONE_DIR"
      RCLONE_CONFIG_FILE: "$RCLONE_CONFIG_FILE"
      RD_API_KEY: "$RD_API_KEY"
      RD_TOKEN_PLEX: "$RD_TOKEN_PLEX"
      PLEX_ADDRESS: "$PLEX_ADDRESS"
      PLEX_USER: "$PLEX_USER"
      PLEX_PASSWD: "$PLEX_PASSWD"
      PLEX_CLAIM: "$PLEX_CLAIM"
EOL

echo "Le fichier docker-compose.yml a été généré avec succès."
