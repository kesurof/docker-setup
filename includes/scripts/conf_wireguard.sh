#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
echo -e "\033[33m$1\033[0m"
}

echo "Veuillez fournir les informations suivantes :"

# Chemin complet pour enregistrer le fichier wg0.conf
folder_app_settings="/home/$USER/seedbox/app_settings"  # Définissez le chemin ici
wg0_config_path="$folder_app_settings/wireguard/config/wg0.conf"

# Vérifier si le répertoire $folder_app_settings/wireguard/config existe, sinon le créer
if [ ! -d "$folder_app_settings/wireguard/config" ]; then
  ask_question "Le répertoire $folder_app_settings/wireguard/config n'existe pas. Voulez-vous le créer ? (Oui/Non) "
  read create_dir_choice
  if [ "$create_dir_choice" = "oui" ] || [ "$create_dir_choice" = "Oui" ] || [ "$create_dir_choice" = "o" ] || [ "$create_dir_choice" = "O" ]; then
    mkdir -p "$folder_app_settings/wireguard/config"
    echo "Le répertoire $folder_app_settings/wireguard/config a été créé."
  else
    echo "Le répertoire $folder_app_settings/wireguard/config n'a pas été créé. Le fichier WireGuard ne sera pas enregistré."
    exit 1
  fi
fi

# Demander à l'utilisateur de coller le code de configuration WireGuard
ask_question "Veuillez coller le code de configuration WireGuard ci-dessous (appuyez sur Entrée puis Ctrl+D pour terminer) : "
wireguard_config=""
while IFS= read -r line; do
  wireguard_config+="$line\n"
done

# Enregistrez le code de configuration WireGuard dans le fichier
echo -e "$wireguard_config" > "$wg0_config_path"
echo -e "\e[32mLe code de configuration WireGuard a été enregistré dans $wg0_config_path.\e[0m"
