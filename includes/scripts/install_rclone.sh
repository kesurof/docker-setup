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

# Chemin du répertoire de torrents
#rclone_dir="$RCLONE_DIR"

# Vérifier si Python 3 est installé
if ! command -v python3 &> /dev/null; then
    afficher_texte_jaune "2) Installation de Python 3"
    sudo apt update
    sudo apt install -y python3
fi

# Vérifier si rclone est déjà installé
if ! command -v rclone &> /dev/null; then
    afficher_texte_jaune "5) Installation de rclone"
    wget https://github.com/itsToggle/rclone_RD/releases/download/v1.58.1-rd.2.2/rclone-linux
    chmod +x rclone-linux
    sudo mv rclone-linux /usr/local/bin/rclone

    # Définir le répertoire de configuration de rclone
    mkdir -p /home/$(logname)/.config/rclone
    export RCLONE_CONFIG_FILE=/home/$(logname)/.config/rclone/rclone.conf
fi

# Vérifier si le dossier "$rclone_dir" existe
if [ ! -d "$rclone_dir" ]; then
    afficher_texte_jaune "6) Création du dossier $rclone_dir"
    sudo mkdir -p "$rclone_dir"
fi

# Changer le propriétaire du point de montage à votre utilisateur
afficher_texte_jaune "7) Changer le propriétaire du point de montage"
sudo chown -R $(logname):$(logname) "$rclone_dir"

# Donner des droits d'écriture au propriétaire du point de montage
afficher_texte_jaune "8) Donner des droits d'écriture au propriétaire du point de montage"
chmod 755 "$rclone_dir"

# Vérifier si le service systemd pour rclone est configuré
if [ ! -f "/etc/systemd/system/rclone.service" ]; then
    afficher_texte_jaune "9) Configuration du service systemd pour rclone"
    cat <<EOF | sudo tee /etc/systemd/system/rclone.service
[Unit]
Description=rclone mount service for realdebrid

[Service]
Type=simple
ExecStart=/usr/local/bin/rclone mount realdebrid: "$rclone_dir" --dir-cache-time 10s --allow-other --allow-non-empty
Restart=always
User=$(logname)

[Install]
WantedBy=default.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable rclone.service
    sudo systemctl start rclone.service
fi


# Afficher le contenu de sudo systemctl status rclone.service
afficher_texte_jaune "Statut de rclone.service :"
sudo systemctl status rclone.service

afficher_texte_jaune "Installation terminée !"

# Afficher un message pour indiquer à l'utilisateur de relancer le container plex
echo "Le container Plex va maintenant être relancé"
docker restart plex

afficher_texte_jaune "Installation de rclone terminé"