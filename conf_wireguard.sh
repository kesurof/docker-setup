#!/bin/bash

#Ce code divise le script en fonctions distinctes pour faciliter la lecture et la maintenance.
#La fonction create_directory gère la création du répertoire si nécessaire,
#et la fonction save_wireguard_config gère l'enregistrement du code de configuration WireGuard dans le fichier spécifié.

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Fonction pour créer un répertoire s'il n'existe pas
function create_directory() {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    ask_question "Le répertoire $directory n'existe pas. Voulez-vous le créer ? (Oui/Non) "
    read create_dir_choice
    if [ "$create_dir_choice" = "oui" ] || [ "$create_dir_choice" = "Oui" ] || [ "$create_dir_choice" = "o" ] || [ "$create_dir_choice" = "O" ]; then
      mkdir -p "$directory"
      echo "Le répertoire $directory a été créé."
    else
      echo "Le répertoire $directory n'a pas été créé. Le fichier WireGuard ne sera pas enregistré."
      exit 1
    fi
  fi
}

# Fonction pour enregistrer le code de configuration WireGuard
function save_wireguard_config() {
  local config_path="$1"
  ask_question "Veuillez coller le code de configuration WireGuard ci-dessous (appuyez sur Entrée puis Ctrl+D pour terminer) : "
  local wireguard_config=""
  while IFS= read -r line; do
    wireguard_config+="$line\n"
  done

  # Enregistrez le code de configuration WireGuard dans le fichier
  echo -e "$wireguard_config" > "$config_path"
  echo -e "\e[32mLe code de configuration WireGuard a été enregistré dans $config_path.\e[0m"
}

# Début du script
echo "Veuillez fournir les informations suivantes :"

# Chemin complet pour enregistrer le fichier wg0.conf
folder_app_settings="/home/$USER/seedbox/app_settings"  # Définissez le chemin ici
wg0_config_path="$folder_app_settings/wireguard/config/wg0.conf"

# Vérifier et créer le répertoire si nécessaire
create_directory "$folder_app_settings/wireguard/config"

# Enregistrer le code de configuration WireGuard
save_wireguard_config "$wg0_config_path"
