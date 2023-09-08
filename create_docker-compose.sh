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

echo "Fichier .env sera enregistré à : $env_file"
echo "Veuillez fournir les informations suivantes :"

# Demander à l'utilisateur le chemin d'installation des volumes des containers (par défaut /home/$USER/seedbox/app_settings)
ask_question "Veuillez entrer le chemin d'installation des volumes des containers : par défaut /home/$USER/seedbox/app_settings  "
read folder_app_settings

# Utiliser le chemin par défaut si l'utilisateur n'a rien saisi
if [ -z "$folder_app_settings" ]; then
  folder_app_settings="/home/$USER/seedbox/app_settings"
fi

# Créer le répertoire si nécessaire
create_directory "$folder_app_settings"

# Demander à l'utilisateur le Chemin du dossier rclone (par défaut /home/$user/rclone)
ask_question "Veuillez entrer le Chemin du dossier rclone : par défaut /home/$user/rclone : "
read folder_rclone

# Utiliser le chemin par défaut si l'utilisateur n'a rien saisi
if [ -z "$folder_rclone" ]; then
  folder_rclone="/home/$USER/rclone"
fi

# Créer le répertoire si nécessaire
create_directory "$folder_rclone"

# Demander à l'utilisateur la clé API de RealDebrid
ask_question "Veuillez entrer votre clé API RealDebrid : "
read rd_api_key

# Demander à l'utilisateur la token plex pour RealDebrid
ask_question "Veuillez entrer votre token pour RealDebrid : "
read rd_token_plex

# Demander à l'utilisateur le nom de domaine ou l'adresse IP du serveur Plex
ask_question "Veuillez entrer le nom de domaine ou l'adresse IP du serveur Plex : "
read plex_address

# Demander à l'utilisateur l'identifiant Plex
ask_question "Veuillez entrer votre identifiant Plex : "
read plex_user

# Demander à l'utilisateur le claim Plex (https://www.plex.tv/claim/)
ask_question "Veuillez entrer votre token Plex : "
read plex_claim

# Écrit les réponses dans le fichier .env
echo "FOLDER_APP_SETTINGS=$folder_app_settings" > "$env_file"
echo "FOLDER_RCLONE=$folder_rclone" >> "$env_file"
echo "RD_API_KEY=$rd_api_key" >> "$env_file"
echo "RD_TOKEN_PLEX=$rd_token_plex" >> "$env_file"
echo "PLEX_USER=$plex_user" >> "$env_file"
echo "PLEX_CLAIM=$plex_claim" >> "$env_file"
echo "PLEX_ADDRESS=$plex_address" >> "$env_file"

echo -e "\e[32mConfiguration terminée. Les informations ont été écrites dans le fichier $env_file.\e[0m"

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