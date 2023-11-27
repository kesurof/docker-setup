#!/bin/bash
clear

          echo -e "\e[32m##################################################\e[0m"
          echo -e "\e[32m###          INSTALLATION GLUETUN              ###\e[0m"
          echo -e "\e[32m##################################################\e[0m"
          echo ""


source /home/$USER/.env
source "${SETTINGS_SOURCE}/includes/scripts/functions.sh"

if [ $(grep -c "VPN_SERVICE_PROVIDER" $USER_HOME/.env) -eq 1 ]; then
sed -i '18,22d' /home/corinne/.env > /dev/null 2>&1
fi

cp $USER_HOME/docker-setup/includes/templates/gluetun.yml $USER_HOME/seedbox/gluetun.yml

echo -e "\e[32mNom de votre provider: \e[0m"
read PROVIDER
PROVIDER=$(echo $PROVIDER  | tr ‘[A-Z]’ ‘[a-z]’)
echo VPN_SERVICE_PROVIDER=$PROVIDER >> $USER_HOME/.env

echo -e "\e[32mNom du protocole (openvpn ou wireguard): \e[0m"
read PROTOCOLE
PROTOCOLE=$(echo $PROTOCOLE  | tr ‘[A-Z]’ ‘[a-z]’)
echo VPN_TYPE=$PROTOCOLE >> $USER_HOME/.env

if [[ "$PROTOCOLE" = "openvpn" ]]; then
  echo -e "\e[32mNom d'utilisateur de votre compte openvpn: \e[0m"
  read USER_VPN
  USER_VPN=$(echo $USER_VPN  | tr ‘[A-Z]’ ‘[a-z]’)
  echo OPENVPN_USER=$USER_VPN >> $USER_HOME/.env
  sed -i "/# - OPENVPN_USER/c\      - OPENVPN_USER={{OPENVPN_USER}}" "$USER_HOME/seedbox/gluetun.yml"

  echo -e "\e[32mMot de passe de votre compte openvpn: \e[0m"
  read PASSWORD_VPN
  PASSWORD_VPN=$(echo $PASSWORD_VPN  | tr ‘[A-Z]’ ‘[a-z]’)
  echo OPENVPN_PASSWORD=$PASSWORD_VPN >> $USER_HOME/.env
  sed -i "/# - OPENVPN_PASSWORD/c\      - OPENVPN_PASSWORD={{OPENVPN_PASSWORD}}" "$USER_HOME/seedbox/gluetun.yml"
elif [[ "$PROTOCOLE" = "wireguard" ]]; then
  echo -e "\e[32mClé privée de votre compte wireguard: \e[0m"
  read PRIVATE_KEY
  echo WIREGUARD_PRIVATE_KEY=$PRIVATE_KEY >> $USER_HOME/.env
  sed -i "/# - WIREGUARD_PRIVATE_KEY/c\      - WIREGUARD_PRIVATE_KEY={{WIREGUARD_PRIVATE_KEY}}=" "$USER_HOME/seedbox/gluetun.yml"

  echo -e "\e[32mEntrer l'adresse de wireguard: \e[0m"
  read ADDRESSE
  ADDRESSE=$(echo $ADDRESSE  | tr ‘[A-Z]’ ‘[a-z]’)
  echo WIREGUARD_ADDRESSES=$ADDRESSE >> $USER_HOME/.env
  sed -i "/# - WIREGUARD_ADDRESSES/c\      - WIREGUARD_ADDRESSES={{WIREGUARD_ADDRESSES}}" "$USER_HOME/seedbox/gluetun.yml"
fi

echo -e "\e[32mLocalité du serveur vpn: \e[0m"
read COUNTRIES
COUNTRIES=$(echo $COUNTRIES  | tr ‘[A-Z]’ ‘[a-z]’)
echo SERVER_COUNTRIES=$COUNTRIES >> $USER_HOME/.env

# Lancement de gluetun
source $USER_HOME/.env
echo gluetun >> $SERVICESPERUSER
install_service


