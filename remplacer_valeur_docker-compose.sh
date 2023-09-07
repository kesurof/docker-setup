#!/bin/bash

# Charger les valeurs à partir du fichier .env
if [ -f .env ]; then
  source .env
else
  echo "Le fichier .env n'existe pas."
  exit 1
fi

# Chemin vers le fichier docker-compose.yml
docker_compose_file="/home/$USER/docker-setup/docker-compose.yml"

# Vérifier si le fichier docker-compose.yml existe
if [ ! -f "$docker_compose_file" ]; then
  echo "Le fichier docker-compose.yml n'existe pas à ce chemin : $docker_compose_file"
  exit 1
fi

# Remplacer les placeholders dans docker-compose.yml
sed -i "s/\$PLEX_TOKEN/$PLEX_TOKEN/g" "$docker_compose_file"
sed -i "s/\$RD_API_KEY/$RD_API_KEY/g" "$docker_compose_file"
sed -i "s/\$PLEX_USER/$PLEX_USER/g" "$docker_compose_file"
sed -i "s/\$PLEX_ADDRESS/$PLEX_ADDRESS/g" "$docker_compose_file"

echo "Les valeurs ont été mises à jour dans $docker_compose_file"
