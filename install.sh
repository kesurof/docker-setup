#!/bin/bash

export NEWT_COLORS='
  window=,white
  border=green,blue
  textbox=black,white
'
# Absolute path to this script.
CURRENT_SCRIPT=$(readlink -f "$0")
# Absolute path this script is in.
SETTINGS_SOURCE=$(dirname "$CURRENT_SCRIPT")
export SETTINGS_SOURCE
# Architecture
TARGETPLATFORM=$(dpkg --print-architecture)
export TARGETPLATFORM

env="/home/$USER/.env"
if [ -f "$env" ]; then
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
 
  #lancement menu
  source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"
  main_menu

elif [ -e "/usr/bin/docker" ]; then
  #lancement menu
  source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"
  main_menu

else
  source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"
  source "${SETTINGS_SOURCE}/includes/scripts/prerequis.sh"
  echo -e  "\e[32mL'installation des prérequis est maintenant terminée, vous devez vous déconnecter/reconnecter puis relancer ./install.sh "sans sudo"\e[0m"
fi
