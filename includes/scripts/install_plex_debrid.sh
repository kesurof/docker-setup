#!/bin/bash

# Fonction pour afficher du texte en jaune
function afficher_texte_jaune() {
  echo -e "\e[93m$1\e[0m"
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$(logname)"
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

# vérification rclone installé
if [ ! -e "/usr/bin/rclone" ]; then
    echo -e "\e[1;32mVeuillez au préalable installer rclone avant de continuer.\e[0m"
    exit 1
fi

# Charger toutes les variables depuis le fichier .env
load_env_variables "$env_file"

# À partir de ce point, toutes les variables du fichier .env sont disponibles, y compris $FOLDER_APP_SETTINGS

# Demander à l'utilisateur le chemin d'installation des volumes des containers
read -p "Veuillez entrer le chemin d'installation de plex_debrid (laisser vide pour utiliser /home/$(logname)/seedbox/app_settings) : "

# Utiliser le chemin par défaut si l'utilisateur n'a rien saisi
if [ -z "$folder_app_settings" ]; then
  folder_app_settings="/home/$(logname)/seedbox/app_settings"
fi

# Chemin du répertoire d'installation de plex_debrid
folder_plex_debrid="$folder_app_settings/plex_debrid"

# Vérifier si plex_debrid est déjà installé dans le répertoire spécifié
if [ ! -d "$folder_plex_debrid" ]; then
    echo""
    afficher_texte_jaune "10) Installation de plex_debrid"
    sudo apt install -y git
    git clone https://github.com/itsToggle/plex_debrid "$folder_plex_debrid"
    cd "$folder_plex_debrid"
    python3 -m venv venv
    source venv/bin/activate
    pip3 install --use-pep517 -r requirements.txt
    deactivate
fi

# Vérifier si le service systemd pour plex_debrid est configuré
if [ ! -f "/etc/systemd/system/plex_debrid.service" ]; then
    afficher_texte_jaune "11) Configuration du service systemd pour plex_debrid"
    cat <<EOF | sudo tee /etc/systemd/system/plex_debrid.service
[Unit]
Description=Plex Debrid Download Automation

[Service]
User=$(logname)
Group=$(logname)
Type=simple
WorkingDirectory=$folder_plex_debrid
ExecStart=$folder_plex_debrid/venv/bin/python3 $folder_plex_debrid/main.py
Restart=always
User=$(logname)

[Install]
WantedBy=default.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable plex_debrid.service
    sudo systemctl start plex_debrid.service
fi

afficher_texte_jaune "Installation terminée !"
