#!/bin/bash

# Répertoire complet où se trouvent les scripts (à la racine)
scripts_dir="$(dirname "$0")/includes/scripts"

# Liste des noms de scripts à exécuter dans l'ordre spécifié
scripts=("install_full.sh" "install_docker.sh" "create_docker-compose.sh" "conf_wireguard.sh" "install_container.sh")

# Noms personnalisés pour les scripts
script_names=("Installation complète" "Installation de docker" "Personnaliser docker-compose.yml" "Créer .conf de Wireguard" "Installation des containers")

# Chemin complet vers les scripts
script_paths=()
for script in "${scripts[@]}"; do
    script_paths+=("$scripts_dir/$script")
done

# Fonction pour afficher le menu
afficher_menu() {
    clear
    echo "Menu d'options :"
    for i in "${!script_names[@]}"; do
        echo "$((i + 1)). ${script_names[i]}"
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
done

# Boucle principale du menu
while true; do
    afficher_menu

    read -p "Sélectionnez une option (1-${#script_names[@]}, Q pour quitter) : " choix

    if [ "$choix" == "Q" ] || [ "$choix" == "q" ]; then
        echo "Au revoir !"
        exit 0
    fi

    if [[ "$choix" =~ ^[0-9]+$ ]] && [ "$choix" -ge 1 ] && [ "$choix" -le ${#script_names[@]} ]; then
        index=$((choix - 1))
        executer_script "${script_paths[index]}"
    else
        echo "Option invalide. Veuillez sélectionner une option valide."
        read -p "Appuyez sur Entrée pour continuer..."
    fi
done
