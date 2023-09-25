#!/bin/bash

# Vérifier les droits sudo
if [ "$(id -u)" -eq 0 ]; then
  echo "Ce script ne doit pas être exécuté en tant que superutilisateur (root). Utilisez un utilisateur avec les droits sudo."
  exit 1
fi

# Vérifier et installer whiptail si nécessaire
if ! command -v whiptail &>/dev/null; then
  echo "whiptail n'est pas installé. Installation en cours..."
  sudo apt update
  sudo apt install whiptail
fi

# Fonction pour afficher une question en jaune
ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Chemin par défaut pour le fichier .env
env_file_path="/home/$(logname)"
env_file="$env_file_path/.env"

# Fonction pour charger toutes les variables depuis le fichier .env
load_env_variables() {
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

# À partir de ce point, toutes les variables du fichier .env sont disponibles, y compris $APP_SETTINGS_DIR

# Vérifier que docker-compose est disponible
if ! command -v docker-compose &>/dev/null; then
  echo "Erreur : docker-compose n'est pas installé. Veuillez l'installer avant de continuer."
  exit 1
fi

# Chemin vers le fichier docker-compose.yml
docker_compose_file="$APP_SETTINGS_DIR/docker-compose.yml"

# Analyser le fichier docker-compose.yml pour extraire les noms des containers
container_names=($(awk '/container_name:/ {print $NF}' "$docker_compose_file"))

# Utiliser whiptail pour sélectionner les applications à installer
selected_containers=$(whiptail --title "Sélection des applications à installer" --checklist \
"Cochez les applications que vous souhaitez installer :" 15 60 6 "${container_names[@]}" 3>&1 1>&2 2>&3)

# Chemin du répertoire où sera copié le fichier docker-compose.yml
app_settings_dir="/home/$(logname)/seedbox/app_settings"

# Copier le contenu du fichier includes/templates/docker-compose.yml vers $app_settings_dir
cp includes/templates/docker-compose.yml "$app_settings_dir"

# Remplacer les variables dans docker-compose.yml en utilisant les valeurs du .env
env_vars=$(grep -oE '\{\{[A-Za-z_][A-Za-z_0-9]*\}\}' "$app_settings_dir/docker-compose.yml")

for var in $env_vars; do
  var_name=$(echo "$var" | sed 's/[{}]//g')
  var_value=$(grep "^$var_name=" "$env_file" | cut -d'=' -f2)
  sed -i "s|{{${var_name}}}|${var_value}|g" "$app_settings_dir/docker-compose.yml"
done

# Afficher un message en utilisant echo
echo "Les informations ont été ajoutées au fichier docker-compose.yml."

# Fonction pour exécuter Docker Compose
start_docker_services() {
  local docker_compose_file="$1"
  echo "Voulez-vous installer et démarrer les services Docker maintenant ? (Oui/Non)"
  read -r start_services_choice
  if [ "$start_services_choice" = "oui" ] || [ "$start_services_choice" = "Oui" ] || [ "$start_services_choice" = "o" ] || [ "$start_services_choice" = "O" ]; then
    docker-compose -f "$docker_compose_file" up -d ${selected_containers[@]}
    echo "Les services Docker ont été installés et démarrés avec succès."
  else
    echo "L'installation des services Docker a été annulée. Vous pouvez les installer ultérieurement en exécutant 'docker-compose -f $docker_compose_file up -d' dans le répertoire du fichier docker-compose.yml."
  fi
}

# Exécuter Docker Compose pour installer et démarrer les services
start_docker_services "$docker_compose_file"

echo "Containers installés avec succès."
