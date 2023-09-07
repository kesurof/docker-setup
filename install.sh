    #!/bin/bash

    # Fonction pour afficher une question en jaune
    function ask_question() {
        echo -e "\033[33m$1\033[0m"
    }

    # Vérifier si l'utilisateur a les droits sudo
    if [ "$(id -u)" -eq 0 ]; then
        echo "Ce script ne doit pas être exécuté en tant que superutilisateur (root). Utilisez un utilisateur avec les droits sudo."
        exit 1
    fi

    # Vérifier si l'utilisateur appartient au groupe Docker
    if ! groups "$USER" | grep &>/dev/null '\bdocker\b'; then
        echo "L'utilisateur n'appartient pas au groupe Docker. Ajout de l'utilisateur au groupe Docker..."
        sudo usermod -aG docker "$USER"
        if [ $? -eq 0 ]; then
            echo "L'utilisateur a été ajouté au groupe Docker avec succès. Veuillez vous déconnecter/reconnecter et relancer le script 'instal.sh' pour continuer."
            exit 1
        else
            echo "Impossible d'ajouter l'utilisateur au groupe Docker. Veuillez le faire manuellement et réexécutez le script."
            exit 1
        fi
    fi

    # Fonction pour demander à l'utilisateur de continuer ou d'annuler
    function ask_to_continue() {
        ask_question "Voulez-vous continuer l'installation ? (Oui/Non) "
        read continue_choice
        if [ "$continue_choice" != "oui" ] && [ "$continue_choice" != "Oui" ] && [ "$continue_choice" != "o" ] && [ "$continue_choice" != "O" ]; then
            echo "Installation annulée."
            exit 1
        fi
    }

    # Vérifier la distribution Linux en cours d'exécution
    distro=$(lsb_release -si)
    version=$(lsb_release -sr)

    if [ "$distro" != "Ubuntu" ] && [ "$distro" != "Debian" ]; then
        echo "Ce script ne prend en charge que les distributions Ubuntu et Debian."
        exit 1
    fi

    # Adapter les sources Apt en fonction de la distribution et de la version
    if [ "$distro" == "Ubuntu" ]; then
        if [ "$version" == "20.04" ] || [ "$version" == "22.04" ]; then
            docker_repo="https://download.docker.com/linux/ubuntu"
        else
            echo "La version Ubuntu $version n'est pas prise en charge."
            exit 1
        fi
    elif [ "$distro" == "Debian" ]; then
        if [ "$version" == "11" ] || [ "$version" == "12" ]; then
            docker_repo="https://download.docker.com/linux/debian"
        else
            echo "La version Debian $version n'est pas prise en charge."
            exit 1
        fi
    fi

    # Demander à l'utilisateur le chemin d'installation des volumes des containers (par défaut /home/$USER/seedbox/app_settings)
    ask_question "Veuillez entrer le chemin d'installation des volumes des containers (par défaut /home/$USER/seedbox/app_settings) : "
    read container_volumes_path

    # Utiliser le chemin par défaut si l'utilisateur n'a rien saisi
    if [ -z "$container_volumes_path" ]; then
        container_volumes_path="/home/$USER/seedbox/app_settings"
    fi

    # Installation de Docker
    ask_question "Voulez-vous installer Docker ? (Oui/Non) "
    read choix

    if [ "$choix" = "oui" ] || [ "$choix" = "Oui" ] || [ "$choix" = "o" ] || [ "$choix" = "O" ]; then
        # Ajout de la clé GPG officielle de Docker
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL $docker_repo/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Ajout du référentiel Docker aux sources Apt
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $docker_repo $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Mise à jour des informations du package
        sudo apt-get update

        # Installation de Docker
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        # Installation de Docker Compose
        echo "Installation de Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        # Vérification de l'installation de Docker et Docker Compose
        sudo docker --version
        sudo docker-compose --version

        echo "Docker et Docker Compose ont été installés avec succès."
    fi

    # Demander à l'utilisateur la clé API de RealDebrid
    ask_question "Veuillez entrer votre clé API RealDebrid : "
    read rd_api_key

    # Demander à l'utilisateur le nom de domaine ou l'adresse IP du serveur Plex
    ask_question "Veuillez entrer le nom de domaine ou l'adresse IP du serveur Plex : "
    read plex_address

    # Demander à l'utilisateur l'identifiant Plex
    ask_question "Veuillez entrer votre identifiant Plex : "
    read plex_user

    # Demander à l'utilisateur le claim Plex
    ask_question "Veuillez entrer votre claim Plex (https://www.plex.tv/claim/): "
    read plex_token

    # Chemin complet pour enregistrer le fichier wg0.conf
    wg0_config_path="$container_volumes_path/wireguard/config/wg0.conf"

    # Vérifier si le répertoire $container_volumes_path/wireguard/config existe, sinon le créer
    if [ ! -d "$container_volumes_path/wireguard/config" ]; then
        ask_question "Le répertoire $container_volumes_path/wireguard/config n'existe pas. Voulez-vous le créer ? (Oui/Non) "
        read create_dir_choice
        if [ "$create_dir_choice" = "oui" ] || [ "$create_dir_choice" = "Oui" ] || [ "$create_dir_choice" = "o" ] || [ "$create_dir_choice" = "O" ]; then
            mkdir -p "$container_volumes_path/wireguard/config"
            echo "Le répertoire $container_volumes_path/wireguard/config a été créé."
        else
            echo "Le répertoire $container_volumes_path/wireguard/config n'a pas été créé. Le fichier WireGuard n'a pas été enregistré."
            exit 1
        fi
    fi

# Demander à l'utilisateur de coller le code de configuration WireGuard ci-dessous
ask_question "Veuillez coller le code de configuration WireGuard ci-dessous (sans appuyer sur Ctrl+D) :"

# Lire le code de configuration WireGuard
IFS= read -d '' -r wireguard_config

# Enregistrer le code de configuration WireGuard dans le fichier
echo -e "$wireguard_config" > "$wg0_config_path"
echo "Le code de configuration WireGuard a été enregistré dans $wg0_config_path."

    # Génération du fichier docker-compose.yml avec la clé API RealDebrid, l'adresse du serveur Plex, l'identifiant Plex et le token Plex
    cat <<EOL > docker-compose.yml
version: '3'

services:
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - 80:80
      - 81:81
      - 443:443
    volumes:
      - $container_volumes_path/nginx-proxy-manager/data:/data
      - $container_volumes_path/nginx-proxy-manager/letsencrypt:/etc/letsencrypt

  portainer:
    image: portainer/portainer-ce
    container_name: portainer-ce
    restart: unless-stopped
    volumes: 
      - /var/run/docker.sock:/var/run/docker.sock
      - $container_volumes_path/portainer:/data
    ports:
      - 9000:9000

  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    environment:
      - VERSION=docker
      - PUID=1000
      - PGID=1000
      - PLEX_CLAIM=$plex_token
      - TZ=Europe/Paris
    network_mode: host
    volumes:
      - $container_volumes_path/plex/config:/config
      - $container_volumes_path/plex/transcode:/transcode
      - /home/$USER/seedbox/rclone:/rclone
    cap_add:
      - SYS_ADMIN
    depends_on:
      - pdrcrd
    security_opt:
      - apparmor:unconfined
      - no-new-privileges
    restart: unless-stopped    

  pdrcrd:
    container_name: pdrcrd
    image: iampuid0/pdrcrd:latest  
    stdin_open: true # docker run -i
    tty: true        # docker run -t    
    volumes:
      - $container_volumes_path/pdrcrd/config:/config
      - $container_volumes_path/pdrcrd/log:/log
      - /home/$USER/seedbox/rclone:/data:shared
    environment:
      - TZ=Europe/Paris
      - RD_API_KEY=$rd_api_key
      - RCLONE_MOUNT_NAME=realdebrid
      - RCLONE_DIR_CACHE_TIME=10s
      - PLEX_USER=$plex_user
      - PLEX_TOKEN=$plex_token
      - PLEX_ADDRESS=http://$plex_address:32400
      - SHOW_MENU=false
    devices:
      - /dev/fuse:/dev/fuse:rwm
    cap_add:
      - SYS_ADMIN   
    security_opt:
      - apparmor:unconfined    
      - no-new-privileges
    restart: unless-stopped
    depends_on:
      - wireguard   

  overseerr:
    image: lscr.io/linuxserver/overseerr
    container_name: overseerr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris
      - VERSION=latest
    volumes:
      - $container_volumes_path/overseerr/config:/config
    ports:
      - 5055:5055
    restart: unless-stopped     

  tautulli:
    image: lscr.io/linuxserver/tautulli
    container_name: tautulli
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris
    volumes:
      - $container_volumes_path/tautulli/config:/config
    ports:
      - 8181:8181
    restart: unless-stopped        

  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris        
    volumes:
      - $container_volumes_path/jackett/config:/config
      - $container_volumes_path/jackett/blackhole/:/downloads   
    ports:
      - 9117:9117      
    restart: unless-stopped

  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    security_opt:
      - no-new-privileges:true    
    environment:
      - TZ=Europe/Paris  
      - LOG_LEVEL=${LOG_LEVEL:-info}
      - LOG_HTML=${LOG_HTML:-false}      
      - CAPTCHA_SOLVER=${CAPTCHA_SOLVER:-none}       
    restart: unless-stopped

  wireguard:
    image: linuxserver/wireguard:latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
    volumes:
      - $container_volumes_path/wireguard/config:/config
    ports:
      - 51820:51820/udp
    restart: unless-stopped
    depends_on:
      - pdrcrd

networks:
  your_custom_network:
    driver: bridge
EOL
