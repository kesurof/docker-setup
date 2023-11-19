#!/bin/bash
###############################################################
# SSD : prerequis.sh                                          #
# Installe les prérequis avant l'installation d'une seedbox   #
# Si un fichier de configuration existe déjà                  #
# il ne sera pas touché                                       #
###############################################################

if [ "$USER" != "root" ]; then
  echo "Ce script doit être lancé par root ou en sudo"
  exit 1
fi

## Environmental Variables
export DEBIAN_FRONTEND=noninteractive

## Install Pre-Dependencies
apt update & apt upgrade -y
apt install -y --reinstall \
  lsb-release \
  sudo

## Install apt Dependencies
apt-get install -y --reinstall \
  nano \
  python3-dev \
  python3-pip \
  python3-venv \
  curl \
  gnupg \
  lsb-release \
  fuse3 \
  figlet

install_docker
check_docker_group

