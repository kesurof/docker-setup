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
  sudo \
  lsb-core

## Add apt repos
osname=$(lsb_release -si)
osversion=$(lsb_release -sr)

if [[ "$osname" == "Debian" ]]; then
  # Si c'est Debian, nous vérifions la version
  if [[ "$osversion" == "11" ]]; then
    # Si c'est Debian 11, nous installons python3-apt-dbg
    apt-get install -y --reinstall python3-apt-dbg
  fi

  # Ajout des dépôts
  add-apt-repository main <<< 'yes'
  add-apt-repository non-free <<< 'yes'
  add-apt-repository contrib <<< 'yes'
elif [[ "$osname" == "Ubuntu" ]]; then
  # Ajout des dépôts pour Ubuntu
  add-apt-repository main <<< 'yes'
  add-apt-repository universe <<< 'yes'
  add-apt-repository restricted <<< 'yes'
  add-apt-repository multiverse <<< 'yes'
fi

apt-get update

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

