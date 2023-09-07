#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$USER"
env_file="$env_file_path/.env"

# Charger les variables depuis le fichier .env s'il existe
if [ -f "$env_file" ]; then
  source "$env_file"
  # Charger la variable $FOLDER_APP_SETTINGS depuis le .env
  folder_app_settings="$FOLDER_APP_SETTINGS"
else
  echo "Le fichier .env n'a pas été trouvé dans $env_file_path. Assurez-vous qu'il existe avant de continuer."
  exit 1
fi

# Chemin vers le fichier docker-compose.yml
docker_compose_file="$folder_app_settings/docker-compose.yml"

# Exécuter Docker Compose pour installer et démarrer les services
ask_question "Voulez-vous installer et démarrer les services Docker maintenant ? (Oui/Non) "
read start_services_choice
if [ "$start_services_choice" = "oui" ] || [ "$start_services_choice" = "Oui" ] || [ "$start_services_choice" = "o" ] || [ "$start_services_choice" = "O" ]; then
  docker-compose -f "$docker_compose_file" up -d
  echo "Les services Docker ont été installés et démarrés avec succès."
else
  echo "L'installation des services Docker a été annulée. Vous pouvez les installer ultérieurement en exécutant 'docker-compose -f $docker_compose_file up -d' dans le répertoire du fichier docker-compose.yml."
fi
