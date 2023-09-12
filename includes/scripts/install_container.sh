#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$USER"
env_file="$env_file_path/.env"

# Fonction pour charger toutes les variables depuis le fichier .env
function load_env_variables() {
  local env_file="$1"
  if [ -f "$env_file" ]; then
    source "$env_file"
  else
    echo "Le fichier .env n'a pas été trouvé à $env_file. Assurez-vous qu'il existe avant de continuer."
    exit 1
  fi
}

# Charger toutes les variables depuis le fichier .env
load_env_variables "$env_file"

# À partir de ce point, toutes les variables du fichier .env sont disponibles, y compris $FOLDER_APP_SETTINGS

# Chemin vers le fichier docker-compose.yml
docker_compose_file="$FOLDER_APP_SETTINGS/docker-compose.yml"

# Fonction pour exécuter Docker Compose
function start_docker_services() {
  local docker_compose_file="$1"
  ask_question "Voulez-vous installer et démarrer les services Docker maintenant ? (Oui/Non) "
  read start_services_choice
  if [ "$start_services_choice" = "oui" ] || [ "$start_services_choice" = "Oui" ] || [ "$start_services_choice" = "o" ] || [ "$start_services_choice" = "O" ]; then
    docker-compose -f "$docker_compose_file" up -d
    echo "Les services Docker ont été installés et démarrés avec succès."
  else
    echo "L'installation des services Docker a été annulée. Vous pouvez les installer ultérieurement en exécutant 'docker-compose -f $docker_compose_file up -d' dans le répertoire du fichier docker-compose.yml."
  fi
}

# Exécuter Docker Compose pour installer et démarrer les services
start_docker_services "$docker_compose_file"


afficher_texte_jaune "Vous devez maintenant quitter l'installation puis lancer sudo ./install.sh choix 6 (Installer Rclone-RD et Plex_Debrid)."
