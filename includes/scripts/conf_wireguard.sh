#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Fonction pour demander à l'utilisateur de continuer ou d'annuler
function ask_to_continue() {
  ask_question "Voulez-vous continuer la configuration de wireguard ? (Oui/Non) "
  read continue_choice
  if [ "$continue_choice" != "oui" ] && [ "$continue_choice" != "Oui" ] && [ "$continue_choice" != "o" ] && [ "$continue_choice" != "O" ]; then
    echo "Installation annulée."
    exit 1
  fi
}

echo "Veuillez fournir les informations suivantes :"

# Chemin complet pour enregistrer le fichier wg0.conf
folder_app_settings="/home/$USER/seedbox/app_settings"  # Définissez le chemin ici
wg0_config_path="$folder_app_settings/wireguard/config/wg0.conf"

# Vérifier si le fichier wg0.conf existe
if [ -e "$wg0_config_path" ]; then
  echo -e "\033[33mLe fichier $wg0_config_path existe déjà.\033[0m"
  echo -e "\033[33mVoulez-vous le supprimer ? (Oui/Non)\033[0m"
  read remove_file_choice
  if [ "$remove_file_choice" = "oui" ] || [ "$remove_file_choice" = "Oui" ] || [ "$remove_file_choice" = "o" ] || [ "$remove_file_choice" = "O" ]; then
    rm -f "$wg0_config_path"
    echo "Le fichier $wg0_config_path a été supprimé."
  else
    echo "Le fichier $wg0_config_path ne sera pas supprimé. Le script est terminé."
    exit 0
  fi
fi

# Vérifier et créer le répertoire si nécessaire
if [ ! -d "$folder_app_settings/wireguard/config" ]; then
  echo "Le répertoire $folder_app_settings/wireguard/config n'existe pas. Voulez-vous le créer ? (Oui/Non) "
  read create_dir_choice
  if [ "$create_dir_choice" = "oui" ] || [ "$create_dir_choice" = "Oui" ] || [ "$create_dir_choice" = "o" ] || [ "$create_dir_choice" = "O" ]; then
    mkdir -p "$folder_app_settings/wireguard/config"
    chmod 755 "$folder_app_settings/wireguard/config"  # Appliquer les permissions rwxr-xr-x
    echo "Le répertoire $folder_app_settings/wireguard/config a été créé et les permissions ont été définies."
  else
    echo "Le répertoire $folder_app_settings/wireguard/config n'a pas été créé. Le fichier WireGuard ne sera pas enregistré."
    exit 1
  fi
fi

# Assurer les autorisations pour l'utilisateur actuel
sudo chown -R "$USER:$USER" "$folder_app_settings/wireguard"

# Enregistrer le code de configuration WireGuard
echo "Veuillez coller le code de configuration WireGuard ci-dessous (appuyez sur Entrée puis Ctrl+D pour terminer) : "
wireguard_config=""
while IFS= read -r line; do
  wireguard_config+="$line\n"
done

# Enregistrez le code de configuration WireGuard dans le fichier
echo -e "$wireguard_config" > "$wg0_config_path"
chmod 755 "$wg0_config_path"  # Appliquer les permissions rwxr-xr-x au fichier
echo -e "Le code de configuration WireGuard a été enregistré dans $wg0_config_path avec les permissions rwxr-xr-x."

