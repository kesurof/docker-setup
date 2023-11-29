#!/bin/bash

source /home/$USER/.env

# Fonction pour afficher du texte en jaune
function afficher_texte_jaune() {
    echo -e "\e[93m$1\e[0m"
}

# Fonction pour afficher du texte en vert
function afficher_texte_vert() {
    echo -e "\e[32m$1\e[0m"
}

# Créez le répertoire scripts dans le répertoire personnel s'il n'existe pas déjà
mkdir -p "$HOME/scripts"

cd "$(dirname "$0")"

# Supprimer le script principal s'il existe déjà
if [ -e "$HOME/scripts/backup_arr.sh" ]; then
    rm "$HOME/scripts/backup_arr.sh"
    afficher_texte_jaune "Le fichier backup_arr.sh existant a été supprimé."
fi

# Copiez le script principal dans le répertoire scripts
cp ../templates/backup_arr.sh "$HOME/scripts/backup_arr.sh"

# Rendez le script principal exécutable
chmod +x "$HOME/scripts/backup_arr.sh"

# Fonction pour demander et mettre à jour la valeur dans le fichier .env
update_value() {
    local env_file="/home/$USER/.env"
    local key=$1
    local current_value=$(grep "^$key=" "$env_file" | cut -d'=' -f2)

    if [ -n "$current_value" ]; then
        read -p "$(afficher_texte_jaune "$key (actuel: $current_value) : ")" new_value
    else
        read -p "$(afficher_texte_jaune "$key : ")" new_value
    fi

    echo "$(afficher_texte_vert "Nouvelle valeur : $new_value")"

    if [ -n "$new_value" ]; then
        # Mettre à jour la valeur dans le fichier .env
        if grep -q "^$key=" "$env_file"; then
            sed -i "s/^$key=.*/$key=$new_value/" "$env_file"
        else
            echo "$key=$new_value" >> "$env_file"
        fi
    fi
}

# Mettre à jour les valeurs dans le fichier .env
update_value "RADARR_API_KEY"
update_value "SONARR_API_KEY"
update_value "PROWLARR_API_KEY"

# Tâche à ajouter
new_cron_task="0 2 */2 * * $HOME/scripts/backup_arr.sh >> $HOME/Logs/crontab/backups/backup_log_\$(date +\%Y\%m\%d_\%H\%M\%S).txt 2>&1"

# Vérifier si la tâche existe déjà dans crontab
if ! (crontab -l 2>/dev/null | grep -Fxq "$new_cron_task"); then
    # Ajouter la tâche dans crontab
    (crontab -l ; echo "$new_cron_task") | crontab -
    afficher_texte_vert "La tâche a été ajoutée dans crontab."
else
    afficher_texte_jaune "La tâche existe déjà dans crontab. Aucune modification nécessaire."
fi


# Exécutez le backup pour créer les dossiers
$HOME/scripts/backup_arr.sh
