#!/bin/bash

source /home/$USER/.env
source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"

# Infos user
USER="$user_home"

# Constantes
LOG_FILE="$HOME/Logs/backups/backup_log.txt"
MAX_BACKUPS=3

# Fonction pour afficher les messages dans le terminal et ecrire dans le fichier de log
log_and_echo() {
    local message="$1"
    echo "$message"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# Fonction pour creer un dossier s'il n'existe pas
create_folder() {
    local folder="$1"
    if [ ! -d "$folder" ]; then
        mkdir -p "$folder"
        chmod 700 "$folder"
        chown ${USER}:${USER} "$folder"
        log_and_echo "Dossier cree : $folder"
    else
        log_and_echo "Le dossier existe deja : $folder"
    fi
}

# Fonction pour supprimer les vieux fichiers de sauvegarde
remove_old_backups() {
    local backup_folder="$1"
    find "$backup_folder" -mindepth 1 -maxdepth 1 -type d | sort | head -n -"$MAX_BACKUPS" | xargs rm -rf
    log_and_echo "Suppression des anciens backups dans $backup_folder."
}

# Remplacez le container_name, le port et la cle d'API par les votres
RADARR_CONTAINER_NAME="radarr"
RADARR_PORT="7878"
RADARR_API_KEY="$radarr_api_key"

SONARR_CONTAINER_NAME="sonarr"
SONARR_PORT="8989"
SONARR_API_KEY="$sonarr_api_key"

PROWLARR_CONTAINER_NAME="prowlarr"
PROWLARR_PORT="9696"
PROWLARR_API_KEY="$prowlarr_api_key"

# Definir les chemins des dossiers
backup_folder="$HOME/backups"
medias_folder="$HOME/Medias"
radarr_backup_folder="$HOME/seedbox/app_settings/radarr/Backups/manual"
sonarr_backup_folder="$HOME/seedbox/app_settings/sonarr/Backups/manual"
prowlarr_backup_folder="$HOME/seedbox/app_settings/prowlarr/Backups/manual"
dropbox_folder="docker-setup"
log_folder="$HOME/Logs/backups"
log_crontab_folder="$HOME/Logs/crontab/backups"

# Verifier et creer les dossiers si necessaire
create_folder "$backup_folder"
create_folder "$log_folder"
create_folder "$log_crontab_folder"

# Fonction pour declencher le backup via les API de Radarr, Sonarr ou Prowlarr dans le conteneur Docker
trigger_backup() {
  local container_name=$1
  local port=$2
  local api_key=$3
  local api_version=$4

  # Obtenez l'adresse IP du conteneur
  local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${container_name})

  # Commande pour declencher le backup via les API dans le conteneur Docker
  curl -H "X-Api-Key: ${api_key}" -H 'Content-type: application/json' -X POST --data '{"name": "Backup"}' "http://${container_ip}:${port}/api/v${api_version}/command"
}

# Fonction pour attendre un certain nombre de secondes avec un message
wait_seconds() {
  local seconds=$1
  log_and_echo "Attente de ${seconds} secondes..."
  sleep "$seconds"
  log_and_echo "Attente terminee."
}

log_and_echo "Debut du script de sauvegarde."
log_and_echo "Creation des dossiers et variables"

# Attendre 5 secondes sans decompte
wait_seconds 5

# Creer un dossier avec la date et l'heure actuelles
timestamp=$(date +"%Y.%m.%d_%H.%M.%S")
backup_dir="$backup_folder/$timestamp"
mkdir -p "$backup_dir"

# Declencher le backup pour Radarr (v3)
trigger_backup "${RADARR_CONTAINER_NAME}" "${RADARR_PORT}" "${RADARR_API_KEY}" "3"

# Declencher le backup pour Sonarr (v3)
trigger_backup "${SONARR_CONTAINER_NAME}" "${SONARR_PORT}" "${SONARR_API_KEY}" "3"

# Declencher le backup pour Prowlarr (v1)
trigger_backup "${PROWLARR_CONTAINER_NAME}" "${PROWLARR_PORT}" "${PROWLARR_API_KEY}" "1"

# Attendre 30 secondes sans decompte
wait_seconds 30
log_and_echo "backup de *arr en cours"

# Supprimer les fichiers de sauvegarde excedant 3 dans les dossiers specifies
find "$radarr_backup_folder" -mindepth 1 -maxdepth 1 -type f | sort | head -n -3 | xargs rm -f
find "$sonarr_backup_folder" -mindepth 1 -maxdepth 1 -type f | sort | head -n -3 | xargs rm -f
find "$prowlarr_backup_folder" -mindepth 1 -maxdepth 1 -type f | sort | head -n -3 | xargs rm -f

log_and_echo "Suppression des anciens backups terminee."

# Compresser le dossier Medias en incluant les dossiers vides
log_and_echo "Compression du dossier Medias en cours..."
tar --create --gzip --file="$backup_dir/medias_backup.tar.gz" --directory="$medias_folder" --exclude='.' . > /dev/null 2>&1

# Recuperer le fichier le plus recent de Radarr, Sonarr et Prowlarr
latest_radarr_backup=$(ls -t "$radarr_backup_folder" | head -n1)
latest_sonarr_backup=$(ls -t "$sonarr_backup_folder" | head -n1)
latest_prowlarr_backup=$(ls -t "$prowlarr_backup_folder" | head -n1)

cp "$radarr_backup_folder/$latest_radarr_backup" "$backup_dir/"
cp "$sonarr_backup_folder/$latest_sonarr_backup" "$backup_dir/"
cp "$prowlarr_backup_folder/$latest_prowlarr_backup" "$backup_dir/"

log_and_echo "Sauvegardes de Radarr, Sonarr et Prowlarr copiees."

# Supprimer les sauvegardes locales excedant 3
remove_old_backups "$backup_folder"

log_and_echo "Sauvegardes locales excedant 3 supprimees."

# Purger le dossier Dropbox
log_and_echo "Purge du dossier Dropbox en cours..."
rclone purge dropbox:"$dropbox_folder"

# Verifier que le dossier docker-setup n'est plus present sur Dropbox
log_and_echo "Verification de l'absence du dossier docker-setup sur Dropbox..."
while rclone ls dropbox:"$dropbox_folder" &>/dev/null; do
    sleep 10
done

# Uploader le dossier backup contenant la derniere sauvegarde ainsi que les 2 dernieres
log_and_echo "Upload des sauvegardes sur Dropbox en cours..."
rclone copy "$backup_folder" dropbox:"$dropbox_folder" --progress

log_and_echo "Fin du script de sauvegarde."

# Compte rendu a la fin
echo "----------------------------------------------------"
echo "Script de sauvegarde termine avec succes."
echo "Sauvegarde locale disponible dans : $backup_dir"
echo "Consultez le fichier de log pour plus de details : $LOG_FILE"
echo "----------------------------------------------------"
