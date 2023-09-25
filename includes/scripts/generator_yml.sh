#!/bin/bash

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

# Chemin vers le fichier docker-compose.yml
docker_compose_file="$APP_SETTINGS_DIR/docker-compose.yml"

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

# Afficher un message
echo -e "\033[32mLes informations ont été ajoutées au fichier docker-compose.yml.\033[0m"