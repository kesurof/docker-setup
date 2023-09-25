#!/bin/bash

# Répertoire complet où se trouvent les scripts (à la racine)
scripts_dir="$(dirname "$0")/includes/scripts"

# Liste des noms de scripts à exécuter dans l'ordre spécifié
scripts=("install_full.sh" "install_docker.sh" "config_setup.sh" "conf_wireguard.sh" "install_container.sh" "install_rclone.sh" "generator_yml.sh")

# Noms personnalisés pour les scripts
script_names=("Installation complète" "Installation de docker" "Config Setup variables" "Créer .conf de Wireguard" "Installation des containers" "Installation de Rclone-RD" "Générateur YML")

# Chemin complet vers les scripts
script_paths=()
for script in "${scripts[@]}"; do
    script_paths+=("$scripts_dir/$script")
done

# Fonction pour afficher le menu
afficher_menu() {
    clear
    echo -e "\e[32mMenu d'options :\e[0m"
    for i in "${!script_names[@]}"; do
        echo -e "\e[1;33m$((i + 1)).\e[0m ${script_names[i]}"
    done
    echo -e "\e[31mQ. Quitter\e[0m"
}

# Fonction pour exécuter un script
executer_script() {
    script_path="$1"
    echo -e "\e[1;33mExécution de $script_path :\e[0m"
    "$script_path"
    read -p "Appuyez sur Entrée pour revenir au menu..."
}

# Rendre les scripts exécutables s'ils ne le sont pas déjà
for script_path in "${script_paths[@]}"; do
    if [ ! -x "$script_path" ]; then
        chmod +x "$script_path"
    fi
done

# Boucle principale du menu
while true; do
    afficher_menu

    read -p "Sélectionnez une option (1-${#script_names[@]}, Q pour quitter) : " choix

    if [ "$choix" == "Q" ] || [ "$choix" == "q" ]; then
        echo -e "\e[31mAu revoir !\e[0m"
        exit 0
    fi

    if [[ "$choix" =~ ^[0-9]+$ ]] && [ "$choix" -ge 1 ] && [ "$choix" -le ${#script_names[@]} ]; then
        index=$((choix - 1))
        executer_script "${script_paths[index]}"
    else
        echo -e "\e[31mOption invalide. Veuillez sélectionner une option valide.\e[0m"
        read -p "Appuyez sur Entrée pour continuer..."
    fi
done