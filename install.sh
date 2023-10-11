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
    plex_debrid
    echo -e "\e[1;33mMenu d'options :\e[0m"
    for i in "${!script_names[@]}"; do
        echo -e "\e[1;33m$((i + 1)).\e[0m \e[1;32m${script_names[i]}.\e[0m"
    done
}

plex_debrid() {
text="Plex Debrid"
colors=("36") # Couleurs ANSI
reset_color="\e[0m"

for color in "${colors[@]}"; do
  echo -e "\e[${color}m$(figlet -f slant "$text")${reset_color}"
done
}

# Fonction pour exécuter un script
executer_script() {
    script_path="$1"
    echo -e "\e[1;33mExécution de $script_path :\e[0m"
    "$script_path"
    read -p "Appuyez sur Entrée pour revenir au menu..."
}

function main_menu {
  while true; do
    clear
    plex_debrid
    echo -e "\e[1;33mMenu\e[0m"

    echo -e "\e[1;32m 1. Installation *arr + rclone + rdtclient + plex \e[0m"
    echo -e "\e[1;32m 2. Installation Plex debrid \e[0m"
    echo -e "\e[1;32m 3. Quitter \e[0m"

    read -p "Entrer votre choix: " choice

    case $choice in
        1)
          # Rendre les scripts exécutables s'ils ne le sont pas déjà
          for script_path in "${script_paths[@]}"; do
              if [ ! -x "$script_path" ]; then
                chmod +x "$script_path"
              fi
          done

          # Boucle principale du menu
          while true; do
              afficher_menu
              read -p "Sélectionnez une option (1-${#script_names[@]}, Q pour revenir au menu général) : " choix
              if [ "$choix" == "Q" ] || [ "$choix" == "q" ]; then
                main_menu
              fi

              if [[ "$choix" =~ ^[0-9]+$ ]] && [ "$choix" -ge 1 ] && [ "$choix" -le ${#script_names[@]} ]; then
                index=$((choix - 1))
                executer_script "${script_paths[index]}"
              else
                echo -e "\e[31mOption invalide. Veuillez sélectionner une option valide.\e[0m"
                read -p "Appuyez sur Entrée pour continuer..."
              fi
          done
          ;;

        2)
          # Liste des fichiers à afficher dans le menu
          scripts=("install_docker.sh" "config_setup.sh" "conf_wireguard.sh" "install_applis.sh" "install_rclone.sh" "install_plex_debrid.sh")
 
          # Noms personnalisés pour les scripts
          script_names=("Installation de docker" "Config Setup variables" "Créer .conf de Wireguard" "Installation des applis" "Installation de Rclone-RD" "Installation de Plex_Debrid" )

          # Afficher un menu interactif
          while true; do
            clear


            # Afficher les fichiers disponibles
            clear
            plex_debrid
            echo -e "\e[1;33mMenu d'options :\e[0m"
            for i in "${!script_names[@]}"; do
              echo -e "\e[1;33m$((i + 1)).\e[0m \e[1;32m${script_names[i]}.\e[0m"
            done

            read -p "Sélectionnez une option (1-${#scripts[@]}, Q pour revenir au menu général) : " choix
            if [ "$choix" == "Q" ] || [ "$choix" == "q" ]; then
              main_menu
            
            elif [[ "$choix" =~ ^[0-9]+$ && "$choix" -ge 1 && "$choix" -le ${#scripts[@]} ]]; then
              select_file="${scripts[choix - 1]}"
              path="$scripts_dir/$select_file"
              echo "Vous avez sélectionné : $path"
              source $path
             sleep 10s
            else
              echo "Sélection invalide. Appuyez sur Entrée pour continuer."
              read -r
            fi
          done
          ;;
        
        esac
  done
}
clear
plex_debrid
main_menu
