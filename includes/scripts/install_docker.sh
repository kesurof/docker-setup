#!/bin/bash

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Fonction pour vérifier si l'utilisateur a les droits sudo
function check_sudo_rights() {
  if [ "$(id -u)" -eq 0 ]; then
    echo "Ce script ne doit pas être exécuté en tant que superutilisateur (root). Utilisez un utilisateur avec les droits sudo."
    exit 1
  fi
}

# Fonction pour vérifier si l'utilisateur appartient au groupe Docker
function check_docker_group_membership() {
  if ! groups "$(logname)" | grep &>/dev/null '\bdocker\b'; then
    echo "L'utilisateur n'appartient pas au groupe Docker. Ajout de l'utilisateur au groupe Docker..."
    sudo usermod -aG docker "$(logname)"
    if [ $? -eq 0 ]; then
      echo "L'utilisateur a été ajouté au groupe Docker avec succès. Veuillez vous déconnecter/reconnecter et relancer le script pour continuer."
      exit 1
    else
      echo "Impossible d'ajouter l'utilisateur au groupe Docker. Veuillez le faire manuellement et réexécutez le script."
      exit 1
    fi
  fi
}

# Fonction pour demander à l'utilisateur de continuer ou d'annuler
function ask_to_continue() {
  ask_question "Voulez-vous continuer l'installation ? (Oui/Non) "
  read continue_choice
  if [ "$continue_choice" != "oui" ] && [ "$continue_choice" != "Oui" ] && [ "$continue_choice" != "o" ] && [ "$continue_choice" != "O" ]; then
    echo "Installation annulée."
    exit 1
  fi
}

# Fonction pour installer Docker et Docker Compose
function install_docker() {
  local distro=$(lsb_release -si)
  local version=$(lsb_release -sr)
  local docker_repo

  if [ "$distro" != "Ubuntu" ] && [ "$distro" != "Debian" ]; then
    echo "Ce script ne prend en charge que les distributions Ubuntu 20.04/22.04 et Debian11/12."
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

  ask_question "Voulez-vous installer Docker ? (Oui/Non) "
  read choice

  if [ "$choice" = "oui" ] || [ "$choice" = "Oui" ] || [ "$choice" = "o" ] || [ "$choice" = "O" ]; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL $docker_repo/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $docker_repo $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "Installation de Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    sudo docker --version
    sudo docker-compose --version

    echo -e "\e[32mDocker et Docker Compose ont été installés avec succès.\e[0m"
  fi
}

# Début du script
check_sudo_rights
check_docker_group_membership
ask_to_continue
install_docker
