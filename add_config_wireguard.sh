#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
    echo -e "\033[33m$1\033[0m"
}

# Demander à l'utilisateur le chemin d'installation des volumes des containers (par défaut /home/$USER/seedbox/app_settings)
ask_question "Veuillez entrer le chemin d'installation des volumes des containers (par défaut /home/$USER/seedbox/app_settings) : "
read container_volumes_path

# Utiliser le chemin par défaut si l'utilisateur n'a rien saisi
if [ -z "$container_volumes_path" ]; then
    container_volumes_path="/home/$USER/seedbox/app_settings"
fi

# Chemin complet pour enregistrer le fichier wg0.conf
wg0_config_path="$container_volumes_path/wireguard/config/wg0.conf"

# Vérifier si le répertoire $container_volumes_path/wireguard/config existe, sinon le créer
if [ ! -d "$container_volumes_path/wireguard/config" ]; then
    ask_question "Le répertoire $container_volumes_path/wireguard/config n'existe pas. Voulez-vous le créer ? (Oui/Non) "
    read create_dir_choice
    if [ "$create_dir_choice" = "oui" ] || [ "$create_dir_choice" = "Oui" ] || [ "$create_dir_choice" = "o" ] || [ "$create_dir_choice" = "O" ]; then
        mkdir -p "$container_volumes_path/wireguard/config"
        echo "Le répertoire $container_volumes_path/wireguard/config a été créé."
    else
        echo "Le répertoire $container_volumes_path/wireguard/config n'a pas été créé. Le fichier WireGuard ne sera pas enregistré."
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
echo "Le code de configuration WireGuard a été enregistré dans $wg0_config_path."
