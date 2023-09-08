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

while true; do
    choix=$(dialog --clear --backtitle "Menu d'options" --title "Sélectionnez une option" \
        --menu "Utilisez les touches haut/bas pour naviguer et la touche Entrée pour sélectionner :" \
        15 50 6 "${script_names[@]}" "Quitter" 3>&1 1>&2 2>&3)

    if [ "$choix" == "Quitter" ]; then
        echo "Au revoir !"
        exit 0
    fi

    index=0
    for name in "${script_names[@]}"; do
        if [ "$choix" == "$name" ]; then
            executer_script "${script_paths[index]}"
            break
        fi
        index=$((index + 1))
    done
done
