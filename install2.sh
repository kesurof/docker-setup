#!/bin/bash

# Chemin complet vers le répertoire des scripts
scripts_dir="/chemin/complet/vers/le/repertoire/includes/scripts"

# Liste des noms de scripts à exécuter dans l'ordre spécifié
scripts=("install_docker.sh" "create_docker-compose.sh" "conf_wireguard.sh" "install_container.sh")

# Chemin complet vers les scripts
script_paths=()
for script in "${scripts[@]}"; do
    script_paths+=("$scripts_dir/$script")
done

# Fonction pour afficher le menu
afficher_menu() {
    clear
    echo "Menu d'options :"
    for ((i = 0; i < ${#scripts[@]}; i++)); do
        echo "$((i + 1)). Exécuter ${scripts[i]}"
    done
    echo "Q. Quitter"
}

# Fonction pour exécuter un script
executer_script() {
    script_path="$1"
    echo "Exécution de $script_path :"
    "$script_path"
    read -p "Appuyez sur Entrée pour revenir au menu..."
}

# Rendre les scripts exécutables s'ils ne le sont pas déjà
for script_path in "${script_paths[@]}"; do
    if [ ! -x "$script_path" ]; then
        chmod +x "$script_path"
    fi
}

# Boucle principale du menu
while true; do
    afficher_menu

    read -p "Sélectionnez une option (1-${#scripts[@]}, Q pour quitter) : " choix

    if [ "$choix" == "Q" ] || [ "$choix" == "q" ]; then
        echo "Au revoir !"
        exit 0
    fi

    if [[ "$choix" =~ ^[0-9]+$ ]] && [ "$choix" -ge 1 ] && [ "$choix" -le ${#scripts[@]} ]; then
        index=$((choix - 1))
        executer_script "${script_paths[index]}"
    else
        echo "Option invalide. Veuillez sélectionner une option valide."
        read -p "Appuyez sur Entrée pour continuer..."
    fi
done
