#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Fonction pour créer un répertoire s'il n'existe pas
function create_directory() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$USER"
env_file="$env_file_path/.env"

# Si le fichier .env existe, afficher le contenu des variables
if [ -f "$env_file" ]; then
  source "$env_file"
else
  echo "Le fichier .env n'existe pas. Veuillez exécuter le script précédent pour le créer."
  exit 1
fi

# Chemin du dossier d'installation des volumes des containers (par défaut /home/$USER/seedbox/app_settings)
folder_app_settings="${FOLDER_APP_SETTINGS:-/home/$USER/seedbox/app_settings}"

# Chemin du dossier rclone (par défaut /home/$USER/rclone)
folder_rclone="${FOLDER_RCLONE:-/home/$USER/rclone}"

# Nom de domaine ou adresse IP du serveur Plex
plex_address="$PLEX_ADDRESS"

# Réclamation Plex (https://www.plex.tv/claim/)
plex_claim="$PLEX_CLAIM"

# Copier le contenu du fichier includes/templates/docker-compose.yml vers $folder_app_settings
cp includes/templates/docker-compose.yml "$folder_app_settings"

# Remplacer les variables dans docker-compose.yml en utilisant les valeurs du .env
env_vars=$(grep -oE '\{\{[A-Za-z_][A-Za-z_0-9]*\}\}' "$folder_app_settings/docker-compose.yml")

for var in $env_vars; do
  var_name=$(echo "$var" | sed 's/[{}]//g')
  var_value=$(grep "^$var_name=" "$env_file" | cut -d'=' -f2)
  sed -i "s|{{${var_name}}}|${var_value}|g" "$folder_app_settings/docker-compose.yml"
done

# Afficher un message
echo -e "\033[32mLes informations ont été ajoutées au fichier docker-compose.yml.\033[0m"
