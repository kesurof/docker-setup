#!/bin/bash

# Chemin par défaut pour le fichier .env
env_file_path="/home/$(logname)"
env_file="$env_file_path/.env"

# Fonction pour charger toutes les variables depuis le fichier .env
load_env_variables() {
  local env_file="$1"
  if [ -f "$env_file" ]; then
    source "$env_file"
  else
    echo "Le fichier .env n'a pas été trouvé à $env_file. Assurez-vous qu'il existe avant de continuer."
    exit 1
  fi
}

# Charger toutes les variables depuis le fichier .env
load_env_variables "$env_file"


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
    docker_compose_file="$APP_SETTINGS_DIR/${line}.yml"
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

choose_services
install_service
  echo -e "\nInstallation compose terminée, Appuyer sur [ENTREE] pour retourner au menu..."
  read -r
main_menu

