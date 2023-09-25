#!/bin/bash

# Fonction pour afficher du texte en jaune
function afficher_texte_jaune() {
  echo -e "\e[93m$1\e[0m"
}

# Fonction pour créer un répertoire s'il n'existe pas
function create_directory() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    chmod 755 "$1"
    chown "$(logname):$(logname)" "$1"
  fi
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$(logname)"
env_file="$env_file_path/.env"

# Vérifier si le fichier .env existe, sinon le créer
if [ ! -f "$env_file" ]; then
  echo "Le fichier .env n'existe pas. Création du fichier..."
  
  # Définir le contenu initial du fichier .env
  cat <<EOL > "$env_file"
USER_HOME=
LOCAL_DIR=
MEDIAS_DIR=
APP_SETTINGS_DIR=
RCLONE_DIR=
RCLONE_CONFIG_FILE=
RD_API_KEY=
RD_TOKEN_PLEX=
PLEX_ADDRESS=
PLEX_USER=
PLEX_PASSWD=
PLEX_CLAIM=
EOL

  echo "Le fichier .env a été créé avec des valeurs par défaut."
fi

# Si le fichier .env existe, afficher le contenu des variables et permettre la modification
if [ -f "$env_file" ]; then
  while true; do
    echo "Le fichier .env existe déjà. Voici son contenu :"
    cat "$env_file"
  
    read -r -p "Souhaitez-vous modifier les variables ? (O/N) " modify_choice
    
    if [ "$modify_choice" != "O" ] && [ "$modify_choice" != "o" ]; then
      echo "La configuration existante sera conservée. Sortie du script."
      exit 0  # Quitter le script proprement
    fi

    # Définir le chemin du répertoire de l'utilisateur
    user_home="/home/$(logname)"

    # Définir le chemin des dossiers à créer
    folders=("$user_home/seedbox/local" "$user_home/Medias" "$user_home/seedbox/app_settings" "$user_home/rclone")

    # Initialiser une variable pour suivre si les dossiers ont été créés
    folders_created=false

    for folder in "${folders[@]}"; do
      if [ ! -d "$folder" ]; then
        create_directory "$folder"
        folders_created=true
      fi
    done

    # Afficher un message de confirmation si les dossiers ont été créés
    if [ "$folders_created" = true ]; then
      for folder in "${folders[@]}"; do
        echo " - $folder : $(stat -c '%a %n' "$folder")"
      done
    fi

    echo -e "\e[32mTous les dossiers ont été créés avec succès.\e[0m"

    # Demander à l'utilisateur la clé API de RealDebrid
    read -r -p "Veuillez entrer votre clé API RealDebrid : " rd_api_key

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

    echo -e "\e[32mLe fichier rclone.conf a été créé dans $rclone_config_file.\e[0m"

    # Récupération du token Plex pour Plex_debrid

    plex_user=$1
    plex_passwd=$2

    if [ -z "$plex_user" ] || [ -z "$plex_passwd" ]; then
        while [ -z "$plex_user" ]; do
            >&2 echo -n "Veuillez entrer votre nom d'utilisateur Plex (e-mail ou nom d'utilisateur) : "
            read plex_user
        done

        while [ -z "$plex_passwd" ]; do
            >&2 echo -n "Veuillez entrer votre mot de passe Plex : "
            read -s plex_passwd
        done
    fi

    >&2 echo "Récupération d'un X-Plex-Token à l'aide du login/mot de passe Plex..."

    curl -qu "${plex_user}:${plex_passwd}" 'https://plex.tv/users/sign_in.xml' \
        -X POST -H 'X-Plex-Device-Name: PlexMediaServer' \
        -H 'X-Plex-Provides: server' \
        -H 'X-Plex-Version: 0.9' \
        -H 'X-Plex-Platform-Version: 0.9' \
        -H 'X-Plex-Platform: xcid' \
        -H 'X-Plex-Product: Plex Media Server'\
        -H 'X-Plex-Device: Linux'\
        -H 'X-Plex-Client-Identifier: XXXX' --compressed >/tmp/plex_sign_in

    rd_token_plex=$(sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p' /tmp/plex_sign_in)
    if [ -z "$rd_token_plex" ]; then
        cat /tmp/plex_sign_in
        rm -f /tmp/plex_sign_in
        >&2 echo 'Échec de la récupération du Token'
        exit 1
    fi
    rm -f /tmp/plex_sign_in

    >&2 echo "Votre Token Plex : $rd_token_plex"

    # Utilisation de curl pour récupérer l'adresse IP publique de l'utilisateur depuis httpbin.org
    ip_public=$(curl -s http://httpbin.org/ip | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

    # URL Plex par défaut avec IP publique
    plex_address="http://$ip_public:32400"

    # Demander à l'utilisateur le claim Plex (https://www.plex.tv/claim/)
    read -r -p "Veuillez entrer votre claim Plex (https://www.plex.tv/claim/) : " plex_claim


    # Écrire les réponses dans le fichier .env
    {
      echo "USER_HOME=$user_home"
      echo "LOCAL_DIR=${folders[0]}"
      echo "MEDIAS_DIR=${folders[1]}"
      echo "APP_SETTINGS_DIR=${folders[2]}"
      echo "RCLONE_DIR=${folders[3]}"
      echo "RCLONE_CONFIG_FILE=$rclone_config_file"
      echo "RD_API_KEY=$rd_api_key"
      echo "RD_TOKEN_PLEX=$rd_token_plex"
      echo "PLEX_ADDRESS=$plex_address"
      echo "PLEX_USER=$plex_user"
      echo "PLEX_PASSWD=$plex_passwd"
      echo "PLEX_CLAIM=$plex_claim"
    } > "$env_file"

    echo -e "\e[32mConfiguration terminée. Les informations ont été écrites dans le fichier $env_file.\e[0m"

    # Copier le contenu du fichier includes/templates/docker-compose.yml vers $app_settings_dir
    app_settings_dir="$user_home/seedbox/app_settings"
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

    # Demander à l'utilisateur s'il souhaite refaire la configuration
    if read -r -p "Souhaitez-vous refaire la configuration ? (O/N) " redo_choice && [ "$redo_choice" != "O" ] && [ "$redo_choice" != "o" ]; then
      echo "Sortie du script."
      exit 0  # Quitter le script proprement
    fi
  done
else
  echo "Fichier .env sera enregistré à : $env_file"
fi