#!/bin/bash

source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"

# Chemin par défaut pour le fichier .env
env_file_path="/home/$(logname)"
env_file="$env_file_path/.env"

# Fonction pour charger toutes les variables depuis le fichier .env
load_env_variables() {
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

choose_services
install_service
  echo -e "\nInstallation compose terminée, Appuyer sur [ENTREE] pour retourner au menu..."
  read -r
main_menu

