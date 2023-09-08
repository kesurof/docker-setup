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

# Fonction pour lire une entrée de l'utilisateur
function read_input() {
  ask_question "$1"
  read input
  echo "$input"
}

# Fonction pour récupérer le token Plex
function get_plex_token() {
  local plex_user="$1"
  local plex_passwd="$2"

  if [ -z "$plex_user" ] || [ -z "$plex_passwd" ]; then
    while [ -z "$plex_user" ]; do
      plex_user=$(read_input "Veuillez entrer utilisateur plex : ")
    done
    while [ -z "$plex_passwd" ]; do
      plex_passwd=$(read_input "Veuillez entrer passwd plex : ")
    done
  fi

  ask_question "Récupération du token Plex... "

  curl -qu "${plex_user}:${plex_passwd}" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 0.9' \
    -H 'X-Plex-Platform-Version: 0.9' \
    -H 'X-Plex-Platform: xcid' \
    -H 'X-Plex-Product: Plex Media Server' \
    -H 'X-Plex-Device: Linux' \
    -H 'X-Plex-Client-Identifier: XXXX' --compressed >/tmp/plex_sign_in
  rd_token_plex=$(sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p' /tmp/plex_sign_in)
  if [ -z "$rd_token_plex" ]; then
    #cat /tmp/plex_sign_in
    rd_token_plex=$(cat /tmp/plex_sign_in)
    rm -f /tmp/plex_sign_in
    >&2 echo 'Failed to retrieve the X-Plex-Token.'
    exit 0
  fi
  rm -f /tmp/plex_sign_in

  echo "$rd_token_plex"
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$USER"
env_file="$env_file_path/.env"

echo "Fichier .env sera enregistré à : $env_file"
echo "Veuillez fournir les informations suivantes :"

# Demander à l'utilisateur le chemin d'installation des volumes des containers (par défaut /home/$USER/seedbox/app_settings)
folder_app_settings=$(read_input "Veuillez entrer le chemin d'installation des volumes des containers : par défaut /home/$USER/seedbox/app_settings  ")

# Utiliser le chemin par défaut si l'utilisateur n'a rien saisi
if [ -z "$folder_app_settings" ]; then
  folder_app_settings="/home/$USER/seedbox/app_settings"
fi

# Créer le répertoire si nécessaire
create_directory "$folder_app_settings"

# Demander à l'utilisateur le Chemin du dossier rclone (par défaut /home/$user/rclone)
folder_rclone=$(read_input "Veuillez entrer le Chemin du dossier rclone : par défaut /home/$USER/rclone  ")

# Utiliser le chemin par défaut si l'utilisateur n'a rien saisi
if [ -z "$folder_rclone" ]; then
  folder_rclone="/home/$USER/rclone"
fi

# Créer le répertoire si nécessaire
create_directory "$folder_rclone"

# Demander à l'utilisateur la clé API de RealDebrid
rd_api_key=$(read_input "Veuillez entrer votre clé API RealDebrid : ")

# Demander à l'utilisateur le nom de domaine ou l'adresse IP du serveur Plex
plex_address=$(read_input "Veuillez entrer le nom de domaine ou l'adresse IP du serveur Plex : ")

# Demander à l'utilisateur le claim Plex (https://www.plex.tv/claim/)
plex_claim=$(read_input "Veuillez entrer votre claim Plex (https://www.plex.tv/claim/) : ")

# Récupérer le token Plex
rd_token_plex=$(get_plex_token "$plex_user" "$plex_passwd")

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
