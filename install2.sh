#!/bin/bash

# Répertoire complet où se trouvent les scripts (à la racine)
scripts_dir="$(dirname "$0")/includes/scripts"

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

# Fonction pour exécuter un script après avoir appliqué chmod +x
executer_script() {
    script_path="$1"
    if [ -x "$script_path" ]; then
        script_name=$(basename "$script_path")
        echo "Exécution de $script_name :"
        "$script_path"
        read -p "Appuyez sur Entrée pour revenir au menu..."
    else
        echo "Le script $script_path n'est pas exécutable."
        read -p "Appuyez sur Entrée pour revenir au menu..."
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
