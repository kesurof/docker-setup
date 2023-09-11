#!/bin/bash

# Répertoire complet où se trouvent les scripts
scripts_dir="$(dirname "$0")"

# Liste des noms de scripts à exécuter dans l'ordre spécifié
scripts=("install_docker.sh" "create_docker-compose.sh" "conf_wireguard.sh" "install_container.sh" "rclone_and_plex_debrid.sh")

# Chemin complet vers les scripts
script_paths=()
for script in "${scripts[@]}"; do
    script_paths+=("$scripts_dir/$script")
done

# Exécute les scripts existants dans le répertoire
for script_path in "${script_paths[@]}"; do
    if [ -f "$script_path" ]; then
        chmod +x "$script_path" # Assurez-vous que le script soit exécutable
        echo "Exécution de $script_path :"
        "$script_path"
    else
        echo "Le script $script_path n'existe pas dans ce répertoire."
    fi
done

# Exécute les scripts après avoir appliqué chmod +x
for script_path in "${script_paths[@]}"; do
    if [ -x "$script_path" ]; then
        script_name=$(basename "$script_path")
        echo "Exécution de $script_name :"
        "$script_path"
    fi
done
