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
rclone_dir="$RCLONE_DIR"

# Vérifier si Python 3 est installé
if ! command -v python3 &> /dev/null; then
    afficher_texte_jaune "Installation de Python 3"
    sudo apt update
    sudo apt install -y python3
fi

# Vérifier si rclone est déjà installé
if ! command -v rclone &> /dev/null; then
    afficher_texte_jaune "Installation de rclone"
    wget https://github.com/itsToggle/rclone_RD/releases/download/v1.58.1-rd.2.2/rclone-linux
    chmod +x rclone-linux
    sudo mv rclone-linux /usr/local/bin/rclone

    # Définir le répertoire de configuration de rclone
    mkdir -p /home/$(logname)/.config/rclone
    export RCLONE_CONFIG_FILE=/home/$(logname)/.config/rclone/rclone.conf
fi

# Supprimer le service rclone.service s'il existe déjà
if [ -f "/etc/systemd/system/rclone.service" ]; then
    afficher_texte_jaune "Suppression du service rclone.service existant"
    sudo systemctl stop rclone.service
    sudo systemctl disable rclone.service
    sudo rm -f /etc/systemd/system/rclone.service
    sudo systemctl daemon-reload
fi

# Vérifier si le dossier "$rclone_dir" existe
if [ ! -d "$rclone_dir" ]; then
    afficher_texte_jaune "Création du dossier $rclone_dir"
    sudo mkdir -p "$rclone_dir"
fi

# Configuration du service systemd pour rclone
afficher_texte_jaune "Configuration du service systemd pour rclone"
cat <<EOF | sudo tee /etc/systemd/system/rclone.service
[Unit]
Description=rclone mount service for realdebrid

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount -vv --config=/home/$USER/.config/rclone/rclone.conf --allow-other --gid $(id -u) --uid $(id -u) --vfs-read-ahead 512M --vfs-read-chunk-size 128M --vfs-read-chunk-size-limit 2G --vfs-fast-fingerprint --vfs-cache-mode writes --dir-cache-time 10s --buffer-size 256M --vfs-cache-max-size 150G --umask 002 --cache-dir=/home/$USER/.cache/rclone realdebrid: /home/$USER/rcloneExecStop=/bin/fusermount -uz /home/$USER/rclone
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Afficher le contenu actuel de /etc/fuse.conf
afficher_texte_jaune "10) Voir le fichier /etc/fuse.conf actuel"
cat "/etc/fuse.conf"

# Vérifier si 'user_allow_other' est déjà configuré dans /etc/fuse.conf
if grep -q "^user_allow_other" "/etc/fuse.conf"; then
    echo "'user_allow_other' est déjà configuré dans /etc/fuse.conf."
else
    # Ajouter 'user_allow_other' s'il n'est pas déjà configuré
    echo "Ajout de 'user_allow_other' à /etc/fuse.conf"
    sudo sed -i '/^#user_allow_other/s/^#//' "/etc/fuse.conf"
fi

# Redémarrer le service rclone
sudo systemctl daemon-reload
sudo systemctl enable rclone.service
sudo systemctl start rclone.service

# Afficher le contenu de sudo systemctl status rclone.service
afficher_texte_jaune "Statut de rclone.service :"
sudo systemctl status rclone.service

afficher_texte_jaune "Installation terminée !"

# Afficher un message pour indiquer à l'utilisateur de relancer le container plex
echo "Le container Plex va maintenant être relancé"
docker restart plex

afficher_texte_jaune "Installation de rclone terminée"

exit 0