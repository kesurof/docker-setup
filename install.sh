#!/bin/bash

# Répertoire complet où se trouvent les scripts (à la racine)
scripts_dir="$(dirname "$0")/includes/scripts"

# Liste des noms de scripts à exécuter dans l'ordre spécifié
scripts=("install_full.sh" "install_docker.sh" "create_docker-compose.sh" "conf_wireguard.sh" "install_container.sh" "install_rclone.sh")

# Noms personnalisés pour les scripts
script_names=("Installation complète" "Installation de docker" "Personnaliser docker-compose.yml" "Créer .conf de Wireguard" "Installation des containers" "Installation de Rclone-RD")

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
for ((i=0; i<${#script_names[@]}; i++)); do
    afficher_menu
    index="$i"
    executer_script "${script_paths[index]}"
done

echo -e "\e[31mInstallation terminée.\e[0m"
