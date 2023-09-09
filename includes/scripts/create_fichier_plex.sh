#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$USER"
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

# Chemin par défaut pour le dossier à changer de propriétaire
folder_to_change_owner="$FOLDER_RCLONE"

# Récupérer le nom d'utilisateur actuellement connecté
current_user=$(whoami)

# Changer le propriétaire du dossier récursivement
chown -R "$current_user:$current_user" "$folder_to_change_owner"

# Afficher un message de confirmation
echo "Le propriétaire du dossier $folder_to_change_owner a été changé à $current_user."

# Chemin vers les dossiers
create_fichier_shows="$FOLDER_RCLONE/realdebrid/shows/"
create_fichier_movies="$FOLDER_RCLONE/realdebrid/movies/"
create_fichier_default="$FOLDER_RCLONE/realdebrid/default"

# Définir les noms des fichiers
nom_fichier_shows="ZeroZeroZero - imdb-tt8332438 - S01E08 - Same Blood WEBDL-1080p.mkv"
nom_fichier_movies_default="Slumberland (2022) imdb-tt13320662 WEBDL-1080p.mkv"

# Définir la taille souhaitée en Mo
taille=500

# Calculer la taille en octets
taille_octets=$((taille * 1024 * 1024))

# Créer les fichiers dans les dossiers spécifiés
for dossier in "$create_fichier_shows" "$create_fichier_movies" "$create_fichier_default"; do
  if [ "$dossier" == "$create_fichier_shows" ]; then
    nom_fichier="$nom_fichier_shows"
  else
    nom_fichier="$nom_fichier_movies_default"
  fi

  chemin_fichier="$dossier/$nom_fichier"
  
  # Utiliser 'dd' pour créer un fichier vide de la taille spécifiée
  dd if=/dev/zero of="$chemin_fichier" bs="$taille_octets" count=1
done
