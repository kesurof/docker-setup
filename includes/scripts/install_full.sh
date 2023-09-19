#!/bin/bash

# Exécutez les scripts dans l'ordre spécifié
echo "Exécution de install_docker.sh :"
./install_docker.sh

echo "Exécution de create_docker-compose.sh :"
./create_docker-compose.sh

echo "Exécution de conf_wireguard.sh :"
./conf_wireguard.sh

echo "Exécution de install_container.sh :"
./install_container.sh

echo "Exécution de install_rclone.sh :"
./install_rclone.sh

# Vérifiez si l'installation de rclone est terminée
if [ $? -ne 0 ]; then
    echo "Installation de rclone terminée."
else
    echo "Installation de rclone a échoué."
fi

# Vous pouvez ajouter d'autres scripts ici, dans l'ordre souhaité.
