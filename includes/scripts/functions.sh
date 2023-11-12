#!/bin/bash

# Fonction pour afficher du texte en jaune
function afficher_texte_jaune() {
  echo -e "\e[93m$1\e[0m"
}

# Vérifier l'appartenance à un groupe Docker
function check_docker_group() {
if ! groups "$(logname)" | grep &>/dev/null '\bdocker\b'; then
  echo "L'utilisateur n'appartient pas au groupe Docker. Ajout de l'utilisateur au groupe Docker..."
  sudo usermod -aG docker "$(logname)"
  if [ $? -eq 0 ]; then
    echo "IMPORTANT !"
    echo "==================================================="
    echo "Votre utilisateur n'était pas dans le groupe docker"
    echo "Il a été ajouté, mais vous devez vous déconnecter/reconnecter pour que la suite du process puisse fonctionner"
    echo "===================================================="
    echo "L'utilisateur a été ajouté au groupe Docker avec succès. Veuillez vous déconnecter/reconnecter et relancer le script pour continuer."
    exit 1
  else
    echo "Impossible d'ajouter l'utilisateur au groupe Docker. Veuillez le faire manuellement et réexécutez le script."
    exit 1
  fi
fi
}

# logo
plex_debrid() {
text="Plex Debrid"
colors=("36") # Couleurs ANSI
reset_color="\e[0m"

for color in "${colors[@]}"; do
  echo -e "\e[${color}m$(figlet -f slant "$text")${reset_color}"
done
}

function install_docker() {
# Installer Docker et Docker Compose
distro=$(lsb_release -si)
version=$(lsb_release -sr)
docker_repo=""

if [ "$distro" != "Ubuntu" ] && [ "$distro" != "Debian" ]; then
  echo "Ce script ne prend en charge que les distributions Ubuntu 20.04/22.04 et Debian 11/12."
  exit 1
fi

if [ "$distro" == "Ubuntu" ]; then
  if [ "$version" == "20.04" ] || [ "$version" == "22.04" ]; then
    docker_repo="https://download.docker.com/linux/ubuntu"
  else
    echo "La version Ubuntu $version n'est pas prise en charge."
    exit 1
  fi
elif [ "$distro" == "Debian" ]; then
  if [ "$version" == "11" ] || [ "$version" == "12" ]; then
    docker_repo="https://download.docker.com/linux/debian"
  else
    echo "La version Debian $version n'est pas prise en charge."
    exit 1
  fi
fi
  for pkg in docker.io docker-ce docker-ce-cli containerd.io; do sudo apt remove --purge -y $pkg; done
  apt-get update
  apt-get install -y ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL $docker_repo/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $docker_repo $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io

  echo "Installation de Docker Compose..."
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  chmod 666 /var/run/docker.sock

  docker --version
  docker-compose --version

  echo -e "\e[32mDocker et Docker Compose ont été installés avec succès.\e[0m"
}

function main_menu {
# Répertoire complet où se trouvent les scripts (à la racine)
scripts_dir="/home/$USER/docker-setup/includes/scripts"
cd $scripts_dir

  while true; do
    clear
    plex_debrid
    echo -e "\e[1;33mMenu\e[0m"

    echo -e "\e[1;32m 1. Installation \e[0m"
    echo -e "\e[1;32m 2. Gestion des Applications \e[0m"
    if [ ! -d "/home/$USER/seedbox/app_settings/plex_debrid" ];then
      echo -e "\e[1;32m 3. Installation plex_debrid \e[0m"
    else
      echo -e "\e[1;33m 3. Lancer la console plex_debrid \e[0m"
    fi
    echo -e "\e[1;32m 4. Quitter \e[0m"

    read -p "Entrer votre choix: " choice

    case $choice in
        1)
          # Liste des fichiers à afficher dans le menu
 
            # liste des scripts à installer
            scripts=("install_full.sh" "config_setup.sh" "conf_wireguard.sh")
 
            # Noms personnalisés pour les scripts
            script_names=("Installation complète" "Config Setup variables" "Créer .conf de Wireguard")
   
          # Afficher un menu interactif
          while true; do
            clear

            # Afficher les fichiers disponibles
            clear
            plex_debrid
            echo -e "\e[1;33mMenu d'options :\e[0m"
            for i in "${!script_names[@]}"; do
              echo -e "\e[1;33m$((i + 1)).\e[0m \e[1;32m${script_names[i]}\e[0m"
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
        2)
          # Installation des applis
          source install_applis.sh
          main_menu 
          ;;
        3)
          # plex_debrid
          if [ ! -d "/home/$USER/seedbox/app_settings/plex_debrid" ];then
            source install_plex_debrid.sh
            main_menu
          else
            source console_plex_debrid.sh 
          fi
         ;;
        4)
        exit 1       
        esac
  done
}

function choose_services() {
  echo ""
  echo -e "\e[1;32m### SERVICES ###\e[0m"
  echo "DEBUG ${SERVICESAVAILABLE}"
  echo -e " ${BWHITE}--> Services en cours d'installation : ${NC}"
  rm -Rf "${SERVICESPERUSER}" >/dev/null 2>&1
  menuservices="/tmp/menuservices.txt"
  if [[ -e "${menuservices}" ]]; then
    rm "${menuservices}"
  fi

  for app in $(cat ${SERVICESAVAILABLE}); do
    service=$(echo ${app} | cut -d\- -f1)
    desc=$(echo ${app} | cut -d\- -f2)
    echo "${service} ${desc} off" >>/tmp/menuservices.txt
  done
  SERVICESTOINSTALL=$(
    whiptail --title "Gestion des Applications" --checklist \
      "Appuyer sur la barre espace pour la sélection" 28 64 21 \
      $(cat /tmp/menuservices.txt) 3>&1 1>&2 2>&3
  )
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    rm /tmp/menuservices.txt
    touch $SERVICESPERUSER
    for APPDOCKER in $SERVICESTOINSTALL; do
      echo -e "	\e[1;32m* $(echo $APPDOCKER | tr -d '"')\e[0m"
      echo -e  $(echo ${APPDOCKER,,} | tr -d '"') >>"${SERVICESPERUSER}"
    done
  else
    return
  fi
}

function install_service() {
  for line in $(cat $SERVICESPERUSER); do
    app_settings_dir="/home/$(logname)/seedbox/app_settings"
    cp $SETTINGS_SOURCE/includes/templates/${line}.yml "$app_settings_dir"
    # Remplacer les variables dans docker-compose.yml en utilisant les valeurs du .env
    env_vars=$(grep -oE '\{\{[A-Za-z_][A-Za-z_0-9]*\}\}' "$app_settings_dir/${line}.yml")

      for var in $env_vars; do
        var_name=$(echo "$var" | sed 's/[{}]//g')
        var_value=$(grep "^$var_name=" "$env_file" | cut -d'=' -f2)
        sed -i "s|{{${var_name}}}|${var_value}|g" "$app_settings_dir/${line}.yml"
      done

   launch_service "${line}"

  done
}

function launch_service() {
  cd $app_settings_dir
  line=$1
  docker-compose -f --log-level ERROR "$line.yml" up -d
  cd $SETTINGS_SOURCE
}