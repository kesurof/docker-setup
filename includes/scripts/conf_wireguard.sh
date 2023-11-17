#!/bin/bash

source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"


# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Fonction pour créer un répertoire s'il n'existe pas
function create_directory() {
  if [ ! -d "$1" ]; then
    sudo mkdir -p "$1"  # Utilisez "sudo" pour créer des répertoires avec les autorisations nécessaires
  fi
  # Définir les permissions rwxr-xr-x pour le répertoire
  sudo chmod 755 "$1"

  # Définir le propriétaire et le groupe du répertoire comme $USER:$USER
  sudo chown "$USER:$USER" "$1"
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

# À partir de ce point, toutes les variables du fichier .env sont disponibles, y compris $APP_SETTINGS_DIR

# Fonction pour demander à l'utilisateur de continuer ou d'annuler
function ask_to_continue() {
  ask_question "Voulez-vous continuer la configuration de WireGuard ? (Oui/Non) "
  read continue_choice
  if [ "$continue_choice" != "oui" ] && [ "$continue_choice" != "Oui" ] && [ "$continue_choice" != "o" ] && [ "$continue_choice" != "O" ]; then
    echo "Installation annulée."
    exit 1
  fi
}

# Chemin complet pour enregistrer le fichier wg0.conf
wg0_config_path="$APP_SETTINGS_DIR/wireguard/config/wg0.conf"

# Vérifier si le fichier wg0.conf existe
if [ -e "$wg0_config_path" ]; then
  echo -e "\e[33mLe fichier $wg0_config_path existe déjà.\e[0m"
  echo -e "\e[32mVoulez-vous le supprimer ? (Oui/Non)\e[0m"
  read remove_file_choice
  if [ "$remove_file_choice" = "oui" ] || [ "$remove_file_choice" = "Oui" ] || [ "$remove_file_choice" = "o" ] || [ "$remove_file_choice" = "O" ]; then
    sudo rm -f "$wg0_config_path"  # Utilisez "sudo" pour supprimer le fichier avec les autorisations nécessaires
    echo -e "\e[33mLe fichier $wg0_config_path a été supprimé.\e[0m"
  else
    echo -e "\e[33mLe fichier $wg0_config_path ne sera pas supprimé. Le script est terminé..\e[0m"
    echo -e "\e[32mAppuyez sur Entrée pour revenir au menu principal.\e[0m"
    read -r
    main_menu
  fi
fi

# Vérifier et créer le répertoire si nécessaire
if [ ! -d "$APP_SETTINGS_DIR/wireguard/config" ]; then
  echo -e "\e[32mLe répertoire $APP_SETTINGS_DIR/wireguard/config n'existe pas. Voulez-vous le créer ? (Oui/Non) \e[0m"
  read create_dir_choice
  if [ "$create_dir_choice" = "oui" ] || [ "$create_dir_choice" = "Oui" ] || [ "$create_dir_choice" = "o" ] || [ "$create_dir_choice" = "O" ]; then
    create_directory "$APP_SETTINGS_DIR/wireguard/config"
    echo -e "\e[33mLe répertoire $APP_SETTINGS_DIR/wireguard/config a été créé et les permissions ont été définies.\e[0m"
  else
    echo -e "\e[33mLe répertoire $APP_SETTINGS_DIR/wireguard/config n'a pas été créé. Le fichier WireGuard ne sera pas enregistré.\e[0m"
    echo -e "\e[32mAppuyez sur Entrée pour revenir au menu principal.\e[0m"
    read -r
    main_menu
  fi
fi

# Assurer les autorisations pour l'utilisateur actuel
create_directory "$APP_SETTINGS_DIR/wireguard"

# Enregistrer le code de configuration WireGuard
echo -e "\e[32mVeuillez coller le code de configuration WireGuard ci-dessous (appuyez sur Entrée puis Ctrl+D pour terminer) : \e[0m"
wireguard_config=""
while IFS= read -r line; do
  wireguard_config+="$line\n"
done

# Enregistrez le code de configuration WireGuard dans le fichier
echo -e "$wireguard_config" | sudo tee "$wg0_config_path"
sudo chmod 755 "$wg0_config_path"  # Appliquer les permissions rwxr-xr-x au fichier
echo -e "\e[33mLe code de configuration WireGuard a été enregistré dans $wg0_config_path avec les permissions rwxr-xr-x.\e[0m"
echo -e "\e[32mAppuyez sur Entrée pour revenir au menu principal.\e[0m"
read -r
main_menu

