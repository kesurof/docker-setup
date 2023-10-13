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

# Vérifier si le script est exécuté en tant qu'administrateur (sudo)
if [ "$EUID" -ne 0 ]; then
    afficher_texte_jaune "Ce script doit être exécuté avec les droits sudo. Utilisez 'sudo ./install.sh'."
    exit 1
fi

# Vérifier si Python 3 est installé
if ! command -v python3 &> /dev/null; then
    afficher_texte_jaune "2) Installation de Python 3"
    sudo apt update
    sudo apt install -y python3
fi

# Vérifier si le paquet python3-venv est installé
if ! dpkg -l | grep -q python3-venv; then
    afficher_texte_jaune "3) Installation du paquet python3-venv"
    sudo apt install -y python3-venv
fi

# Vérifier si pip est installé
if ! command -v pip3 &> /dev/null; then
    afficher_texte_jaune "4) Installation de pip"
    sudo apt install -y python3-pip
fi

# Vérifier si plex_debrid est déjà installé dans le répertoire spécifié
if [ ! -d "$folder_plex_debrid" ]; then
    afficher_texte_jaune "10) Installation de plex_debrid"
    sudo apt install -y git
    git clone https://github.com/itsToggle/plex_debrid "$folder_plex_debrid"
    cd "$folder_plex_debrid"
    python3 -m venv venv
    source venv/bin/activate
    pip3 install --use-pep517 -r requirements.txt
    deactivate
    cd ..
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
WorkingDirectory=$folder_app_settings/plex_debrid/
ExecStart=$folder_app_settings/plex_debrid/venv/bin/python3 $folder_app_settings/plex_debrid/main.py
Restart=always
User=$(logname)

[Install]
WantedBy=default.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable plex_debrid.service
    sudo systemctl start plex_debrid.service
fi

# Ajouter user_allow_other à /etc/fuse.conf
echo 'user_allow_other' | sudo tee -a /etc/fuse.conf
sudo systemctl restart rclone.service

# changer le propriétaire du dossier plex_debrid :
sudo chown -R $(logname):$(logname) "$folder_plex_debrid"

# Attendre 10 secondes avec un décompte
for i in {10..1}; do
    echo -e "Attente de $i secondes..."
    sleep 1
done

afficher_texte_jaune "Statut de plex_debrid.service :"
sudo systemctl status plex_debrid.service

afficher_texte_jaune "Installation terminée !"

# Afficher un message pour indiquer à l'utilisateur de relancer le container plex
echo "Il faut maintenant relancer le container plex"
docker restart plex
