#!/bin/bash

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

# Chemin du répertoire de torrents
#folder_rclone="/home/$(logname)/rclone"

# Chemin du répertoire de torrents
folder_rclone="$FOLDER_RCLONE"

# Fonction pour afficher le texte en jaune
function afficher_texte_jaune() {
    echo -e "\e[93m$1\e[0m"
}

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

# Vérifier si rclone est déjà installé
if ! command -v rclone &> /dev/null; then
    afficher_texte_jaune "5) Installation de rclone"
    wget https://github.com/itsToggle/rclone_RD/releases/download/v1.58.1-rd.2.2/rclone-linux
    chmod +x rclone-linux
    sudo mv rclone-linux /usr/local/bin/rclone

    # Définir le répertoire de configuration de rclone
    mkdir -p /home/$(logname)/.config/rclone
    export RCLONE_CONFIG=/home/$(logname)/.config/rclone/rclone.conf

    rclone config
fi

# Vérifier si le dossier "$folder_rclone" existe
if [ ! -d "$folder_rclone" ]; then
    afficher_texte_jaune "6) Création du dossier $folder_rclone"
    sudo mkdir -p "$folder_rclone"
fi

# Changer le propriétaire du point de montage à votre utilisateur
afficher_texte_jaune "7) Changer le propriétaire du point de montage"
sudo chown -R $(logname):$(logname) "$folder_rclone"

# Donner des droits d'écriture au propriétaire du point de montage
afficher_texte_jaune "8) Donner des droits d'écriture au propriétaire du point de montage"
chmod +w "$folder_rclone"

# Vérifier si le service systemd pour rclone est configuré
if [ ! -f "/etc/systemd/system/rclone.service" ]; then
    afficher_texte_jaune "9) Configuration du service systemd pour rclone"
    cat <<EOF | sudo tee /etc/systemd/system/rclone.service
[Unit]
Description=rclone mount service for realdebrid

[Service]
Type=simple
ExecStart=/usr/local/bin/rclone mount realdebrid: "$folder_rclone" --dir-cache-time 10s --allow-other --allow-non-empty
Restart=always
User=$(logname)

[Install]
WantedBy=default.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable rclone.service
    sudo systemctl start rclone.service
fi

# Vérifier si plex_debrid est déjà installé
if [ ! -d "plex_debrid" ]; then
    afficher_texte_jaune "10) Installation de plex_debrid"
    sudo apt install -y git
    git clone https://github.com/itsToggle/plex_debrid
    cd plex_debrid
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
Type=simple
ExecStart=$(pwd)/plex_debrid/venv/bin/python3 $(pwd)/plex_debrid/main.py
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

# Attendre 10 secondes avec un décompte
for i in {10..1}; do
    echo -e "Attente de $i secondes..."
    sleep 1
done

# Afficher le contenu de sudo systemctl status rclone.service et sudo systemctl status plex_debrid.service
afficher_texte_jaune "Statut de rclone.service :"
sudo systemctl status rclone.service

afficher_texte_jaune "Statut de plex_debrid.service :"
sudo systemctl status plex_debrid.service

afficher_texte_jaune "Installation terminée !"
