#!/bin/bash

# Chemin du répertoire d'installation de plex_debrid
folder_plex_debrid="$APP_SETTINGS_DIR/plex_debrid"

# Vérifier si plex_debrid est déjà installé dans le répertoire spécifié
if [ ! -d "$folder_plex_debrid" ]; then
    echo""
    afficher_texte_jaune "10) Installation de plex_debrid"
    git clone https://github.com/itsToggle/plex_debrid "$folder_plex_debrid"
    cd "$folder_plex_debrid"
    python3 -m venv venv
    source venv/bin/activate
    pip3 install --use-pep517 -r requirements.txt
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
