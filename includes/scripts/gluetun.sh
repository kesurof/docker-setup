#!/bin/bash
clear

          echo -e "\e[36m############################################################################################\e[0m"
          echo -e "\e[36m###                        INSTALLATION GLUETUN                                          ###\e[0m"
          echo -e "\e[36m###                                                                                      ###\e[0m"
          echo -e "\e[36m###   Gluetun supporte nativement l'intégration Wireguard pour les providers suivant:    ###\e[0m"
          echo -e "\e[36m###   AirVPN, Ivpn, Mullvad, NordVPN, Surfshark, Windscribe                              ###\e[0m"
          echo -e "\e[36m###   Se référer à la page du wiki pour la configuration de ces vpn                      ###\e[0m"
          echo -e "\e[36m###   Gluetun supporte également une configuration wireguard personnalisée               ###\e[0m"
          echo -e "\e[36m###   pour certains clients notamment Torguard and VPN Unlimited                          ###\e[0m"
          echo -e "\e[36m###                                                                                      ###\e[0m"
          echo -e "\e[36m###   Toutes les informations nécessaires (quelque soit le provider)                     ###\e[0m"
          echo -e "\e[36m###   demandées dans le script figurent dans le lien ci dessous                          ###\e[0m"
          echo -e "\e[36m###   wiki: https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers              ###\e[0m"
          echo -e "\e[36m###                                                                                      ###\e[0m"
          echo -e "\e[36m###                                                                                      ###\e[0m"
          echo -e "\e[36m############################################################################################\e[0m"
          echo ""


source /home/$USER/.env
source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"
rm /home/$USER/seedbox/gluetun.yml > /dev/null 2>&1
rm /home/$USER/seedbox/yml/gluetun.yml > /dev/null 2>&1
cp $USER_HOME/docker-setup/includes/templates/gluetun.yml $USER_HOME/seedbox/gluetun.yml

grep "VPN_SERVICE_PROVIDER" $USER_HOME/.env > /dev/null 2>&1
if [ $? -eq 0 ]; then
  sed -i '18,25d' /home/$USER/.env > /dev/null 2>&1
fi

#demander à l'utilisateur s'il souhaite une config custum
echo -e "\e[32mEst ce que votre VPN demande une config custom ? (O/N) \e[0m"
read reponse

if [[ "$reponse" = "O" ]] || [[ "$reponse" = "o" ]]; then
  echo VPN_SERVICE_PROVIDER=custom >> $USER_HOME/.env
  echo -e "\e[32mNom du protocole (openvpn ou wireguard): \e[0m"
  read VPN_TYPE
  VPN_TYPE=$(echo $VPN_TYPE | tr ‘[A-Z]’ ‘[a-z]’)
  echo VPN_TYPE=$VPN_TYPE >> $USER_HOME/.env

  if [[ $VPN_TYPE = wireguard ]]; then
    echo -e "\e[32mAdresse ip de l'Endpoint: \e[0m"
    read VPN_ENDPOINT_IP
    echo VPN_ENDPOINT_IP=$VPN_ENDPOINT_IP >> $USER_HOME/.env
    sed -i "/# - VPN_ENDPOINT_IP/c\      - VPN_ENDPOINT_IP={{VPN_ENDPOINT_IP}}" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mPort de l'Endpoint: \e[0m"
    read VPN_ENDPOINT_PORT
    echo VPN_ENDPOINT_PORT=$VPN_ENDPOINT_PORT >> $USER_HOME/.env
    sed -i "/# - VPN_ENDPOINT_PORT/c\      - VPN_ENDPOINT_PORT={{VPN_ENDPOINT_PORT}}" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mVotre clé publique: \e[0m"
    read WIREGUARD_PUBLIC_KEY
    echo WIREGUARD_PUBLIC_KEY=$WIREGUARD_PUBLIC_KEY >> $USER_HOME/.env
    sed -i "/# - WIREGUARD_PUBLIC_KEY/c\      - WIREGUARD_PUBLIC_KEY={{WIREGUARD_PUBLIC_KEY}}=" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mVotre clé privée: \e[0m"
    read WIREGUARD_PRIVATE_KEY
    echo WIREGUARD_PRIVATE_KEY=$WIREGUARD_PRIVATE_KEY >> $USER_HOME/.env
    sed -i "/# - WIREGUARD_PRIVATE_KEY/c\      - WIREGUARD_PRIVATE_KEY={{WIREGUARD_PRIVATE_KEY}}=" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mVotre clé preshared: \e[0m"
    read WIREGUARD_PRESHARED_KEY
    echo WIREGUARD_PRESHARED_KEY=$WIREGUARD_PRESHARED_KEY >> $USER_HOME/.env
    sed -i "/# - WIREGUARD_PRESHARED_KEY/c\      - WIREGUARD_PRESHARED_KEY={{WIREGUARD_PRESHARED_KEY}}=" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mEntrer la plage adresse: \e[0m"
    read WIREGUARD_ADDRESSES
    echo WIREGUARD_ADDRESSES=$WIREGUARD_ADDRESSES >> $USER_HOME/.env
    sed -i "/# - WIREGUARD_ADDRESSES/c\      - WIREGUARD_ADDRESSES={{WIREGUARD_ADDRESSES}}" "$USER_HOME/seedbox/gluetun.yml" 
  else
    echo -e "\e[32mEntrer le chemin ou se situe votre custom.conf openvpn ex: /home/toto/custom.conf \e[0m"
    read OPENVPN_CUSTOM_CONFIG
    OPENVPN_CUSTOM_CONFIG=$(echo $OPENVPN_CUSTOM_CONFIG  | tr ‘[A-Z]’ ‘[a-z]’)
    echo OPENVPN_CUSTOM_CONFIG=$OPENVPN_CUSTOM_CONFIG >> $USER_HOME/.env
    sed -i "/# - OPENVPN_CUSTOM_CONFIG/c\      - {{OPENVPN_CUSTOM_CONFIG}}:/gluetun/custom.conf:ro" "$USER_HOME/seedbox/gluetun.yml"
    sed -i "/# - CUSTOM_CONFIG/c\      - OPENVPN_CUSTOM_CONFIG=/gluetun/custom.conf:ro" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mEntrer le nom d'utilsateur openvpn \e[0m"
    read OPENVPN_USER
    OPENVPN_USER=$(echo $OPENVPN_USER  | tr ‘[A-Z]’ ‘[a-z]’)
    echo OPENVPN_USER=$OPENVPN_USER >> $USER_HOME/.env
    sed -i "/# - OPENVPN_USER/c\      - OPENVPN_USER={{OPENVPN_USER}}" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mEntrer le mot de passe de votre compte openvpn \e[0m"
    read OPENVPN_PASSWORD
    echo OPENVPN_PASSWORD=$OPENVPN_PASSWORD >> $USER_HOME/.env
    sed -i "/# - OPENVPN_PASSWORD/c\      - OPENVPN_PASSWORD={{OPENVPN_PASSWORD}}" "$USER_HOME/seedbox/gluetun.yml"
  fi
else
  echo -e "\e[32mNom de votre provider: \e[0m"
  read VPN_SERVICE_PROVIDER
  VPN_SERVICE_PROVIDER=$(echo $VPN_SERVICE_PROVIDER  | tr ‘[A-Z]’ ‘[a-z]’)
  echo VPN_SERVICE_PROVIDER=$VPN_SERVICE_PROVIDER >> $USER_HOME/.env

  echo -e "\e[32mNom du protocole (openvpn ou wireguard): \e[0m"
  read VPN_TYPE
  VPN_TYPE=$(echo $VPN_TYPE  | tr ‘[A-Z]’ ‘[a-z]’)
  echo VPN_TYPE=$VPN_TYPE >> $USER_HOME/.env
  if [[ "$VPN_TYPE" = "openvpn" ]]; then
    echo -e "\e[32mNom d'utilisateur de votre compte openvpn: \e[0m"
    read OPENVPN_USER
    OPENVPN_USER=$(echo $OPENVPN_USER  | tr ‘[A-Z]’ ‘[a-z]’)
    echo OPENVPN_USER=$OPENVPN_USER >> $USER_HOME/.env
    sed -i "/# - OPENVPN_USER/c\      - OPENVPN_USER={{OPENVPN_USER}}" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mMot de passe de votre compte openvpn: \e[0m"
    read OPENVPN_PASSWORD
    OPENVPN_PASSWORD=$(echo $OPENVPN_PASSWORD  | tr ‘[A-Z]’ ‘[a-z]’)
    echo OPENVPN_PASSWORD=$OPENVPN_PASSWORD >> $USER_HOME/.env
    sed -i "/# - OPENVPN_PASSWORD/c\      - OPENVPN_PASSWORD={{OPENVPN_PASSWORD}}" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mLocalité du serveur vpn: \e[0m"
    read SERVER_COUNTRIES
    SERVER_COUNTRIES=$(echo $SERVER_COUNTRIES  | tr ‘[A-Z]’ ‘[a-z]’)
    echo SERVER_COUNTRIES=$SERVER_COUNTRIES>> $USER_HOME/.env
    sed -i "/# - SERVER_COUNTRIES/c\      - SERVER_COUNTRIES={{SERVER_COUNTRIES}}" "$USER_HOME/seedbox/gluetun.yml"

  elif [[ "$VPN_TYPE" = "wireguard" ]]; then
    echo -e "\e[32mClé privée de votre compte wireguard: \e[0m"
    read WIREGUARD_PRIVATE_KEY
    echo WIREGUARD_PRIVATE_KEY=$WIREGUARD_PRIVATE_KEY >> $USER_HOME/.env
    sed -i "/# - WIREGUARD_PRIVATE_KEY/c\      - WIREGUARD_PRIVATE_KEY={{WIREGUARD_PRIVATE_KEY}}=" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mEntrer la plage adresse de wireguard: \e[0m"
    read WIREGUARD_ADDRESSES
    echo WIREGUARD_ADDRESSES=$WIREGUARD_ADDRESSES >> $USER_HOME/.env
    sed -i "/# - WIREGUARD_ADDRESSES/c\      - WIREGUARD_ADDRESSES={{WIREGUARD_ADDRESSES}}" "$USER_HOME/seedbox/gluetun.yml"

    echo -e "\e[32mLocalité du serveur vpn: \e[0m"
    read SERVER_COUNTRIES
    SERVER_COUNTRIES=$(echo $SERVER_COUNTRIES  | tr ‘[A-Z]’ ‘[a-z]’)
    echo SERVER_COUNTRIES=$SERVER_COUNTRIES>> $USER_HOME/.env
    sed -i "/# - SERVER_COUNTRIES/c\      - SERVER_COUNTRIES={{SERVER_COUNTRIES}}" "$USER_HOME/seedbox/gluetun.yml"
  fi
fi

# Lancement de gluetun
echo ""
source $USER_HOME/.env
echo gluetun >> $SERVICESPERUSER
install_service
rm /home/$USER/seedbox/gluetun.yml > /dev/null 2>&1
echo ""
echo -e "\e[1;32mInstallation Gluetun terminée, Appuyer sur [ENTREE]\e[0m"
read -r



