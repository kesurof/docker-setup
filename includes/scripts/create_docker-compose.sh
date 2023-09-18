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
  # Définir les permissions rwxr-xr-x pour le répertoire
  chmod 755 "$1"

  # Définir le propriétaire et le groupe du répertoire comme $logname:$logname
  chown "$(logname):$(logname)" "$1"
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$(logname)"
env_file="$env_file_path/.env"

# Si le fichier .env existe, afficher le contenu des variables et permettre la modification
if [ -f "$env_file" ]; then
  echo "Le fichier .env existe déjà. Voici son contenu :"
  cat "$env_file"
  ask_question "Souhaitez-vous modifier les variables ? (O/N) "
  read modify_choice

  if [ "$modify_choice" == "O" ] || [ "$modify_choice" == "o" ]; then
    echo "Veuillez fournir les informations suivantes :"
  else
    echo "La configuration existante sera conservée. Sortie du script."
    exit 0
  fi
else
  echo "Fichier .env sera enregistré à : $env_file"
  echo "Veuillez fournir les informations suivantes :"
fi

# Définir le chemin du répertoire de l'utilisateur
user_home="/home/$(logname)"

# Définir le chemin des dossiers à créer
local_dir="$user_home/seedbox/local"
medias_dir="$user_home/seedbox/Medias"
app_settings_dir="$user_home/seedbox/app_settings"
rclone_dir="$user_home/rclone"

# Utiliser la fonction pour créer les dossiers avec les permissions
create_directory "$local_dir"
create_directory "$medias_dir"
create_directory "$app_settings_dir"
create_directory "$rclone_dir"

# Afficher un message de confirmation
echo "Les dossiers ont été créés avec les permissions suivantes :"
echo " - $local_dir : $(stat -c '%a %n' "$local_dir")"
echo " - $medias_dir : $(stat -c '%a %n' "$medias_dir")"
echo " - $app_settings_dir : $(stat -c '%a %n' "$app_settings_dir")"
echo " - $rclone_dir : $(stat -c '%a %n' "$rclone_dir")"

# Demander à l'utilisateur la clé API de RealDebrid
ask_question "Veuillez entrer votre clé API RealDebrid : "
read rd_api_key

# Chemin du fichier rclone.conf
rclone_config_file="/home/$(logname)/.config/rclone/rclone.conf"

# Utilisez la fonction create_directory pour créer le répertoire .config/rclone s'il n'existe pas
create_directory "/home/$(logname)/.config/rclone"

# Écrire la configuration rclone dans le fichier rclone.conf en remplaçant {{RD_API_KEY}}
cat <<EOL > "$rclone_config_file"
[realdebrid]
type = realdebrid
api_key = $rd_api_key
EOL

echo "Le fichier rclone.conf a été créé dans $rclone_config_file"

# Récupération du token Plex pour Plex_debrid

if [ -z "$plex_user" ] || [ -z "$plex_passwd" ]; then
    plex_user=$1
    plex_passwd=$2
fi

while [ -z "$plex_user" ]; do
    ask_question "Veuillez entrer votre nom d'utilisateur Plex : "
    read plex_user
done

while [ -z "$plex_passwd" ]; do
    ask_question "Veuillez entrer votre mot de passe Plex : "
    read plex_passwd
done

ask_question "Récupération du token Plex... "

plex_sign_in_response=$(curl -qu "${plex_user}":"${plex_passwd}" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 0.9' \
    -H 'X-Plex-Platform-Version: 0.9' \
    -H 'X-Plex-Platform: xcid' \
    -H 'X-Plex-Product: Plex Media Server'\
    -H 'X-Plex-Device: Linux'\
    -H 'X-Plex-Client-Identifier: XXXX' --compressed)

rd_token_plex=$(echo "$plex_sign_in_response" | sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p')

if [ -z "$rd_token_plex" ]; then
    >&2 echo 'Échec de la récupération du token X-Plex-Token.'
    exit 1
fi

# Utilisation de curl pour récupérer l'adresse IP publique de l'utilisateur depuis httpbin.org
ip_public=$(curl -s http://httpbin.org/ip | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

# URL Plex par défaut avec IP publique
plex_address="http://$ip_public:32400"

# Demander à l'utilisateur le claim Plex (https://www.plex.tv/claim/)
ask_question "Veuillez entrer votre claim Plex (https://www.plex.tv/claim/) : "
read plex_claim

# Écrire les réponses dans le fichier .env
echo "USER_HOME=$user_home" > "$env_file"
echo "LOCAL_DIR=$local_dir" > "$env_file"
echo "MEDIAS_DIR=$medias_dir" > "$env_file"
echo "APP_SETTINGS_DIR=$app_settings_dir" > "$env_file"
echo "RCLONE_DIR=$rclone_dir" >> "$env_file"
echo "RCLONE_CONFIG_FILE=$rclone_config_file" >> "$env_file"
echo "RD_API_KEY=$rd_api_key" >> "$env_file"
echo "RD_TOKEN_PLEX=$rd_token_plex" >> "$env_file"
echo "PLEX_ADDRESS=$plex_address" >> "$env_file"
echo "PLEX_USER=$plex_user" >> "$env_file"
echo "PLEX_PASSWD=$plex_passwd" >> "$env_file"
echo "PLEX_CLAIM=$plex_claim" >> "$env_file"

echo -e "\e[32mConfiguration terminée. Les informations ont été écrites dans le fichier $env_file.\e[0m"

# Copier le contenu du fichier includes/templates/docker-compose.yml vers $app_settings_dir
cp includes/templates/docker-compose.yml "$app_settings_dir"

# Remplacer les variables dans docker-compose.yml en utilisant les valeurs du .env
env_vars=$(grep -oE '\{\{[A-Za-z_][A-Za-z_0-9]*\}\}' "$app_settings_dir/docker-compose.yml")

for var in $env_vars; do
  var_name=$(echo "$var" | sed 's/[{}]//g')
  var_value=$(grep "^$var_name=" "$env_file" | cut -d'=' -f2)
  sed -i "s|{{${var_name}}}|${var_value}|g" "$app_settings_dir/docker-compose.yml"
done

# Afficher un message
echo -e "\033[32mLes informations ont été ajoutées au fichier docker-compose.yml.\033[0m"
