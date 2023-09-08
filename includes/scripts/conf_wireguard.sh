#!/bin/bash

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

# Fonction pour vérifier si le fichier existe et demander à l'utilisateur s'il doit être supprimé
function check_and_remove_file() {
  local file_path="$1"
  if [ -e "$file_path" ]; then
    ask_question "Le fichier $file_path existe déjà. Voulez-vous le supprimer ? (Oui/Non) "
    read remove_file_choice
    if [ "$remove_file_choice" = "oui" ] || [ "$remove_file_choice" = "Oui" ] || [ "$remove_file_choice" = "o" ] || [ "$remove_file_choice" = "O" ]; then
      rm -f "$file_path"
      echo "Le fichier $file_path a été supprimé."
    else
      echo "Le fichier $file_path ne sera pas supprimé. Le script est terminé."
      exit 0
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

# Vérifier si le fichier wg0.conf existe et demander s'il doit être supprimé
check_and_remove_file "$wg0_config_path"

# Assurer les autorisations pour l'utilisateur actuel
sudo chown -R "$USER:$USER" "$folder_app_settings/wireguard"

# Enregistrer le code de configuration WireGuard
save_wireguard_config "$wg0_config_path"
