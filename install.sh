#!/bin/bash

# Répertoire complet où se trouvent les scripts (à la racine)
scripts_dir="$(dirname "$0")/includes/scripts"

# Fonction pour afficher le menu
afficher_menu() {
    clear
    echo "Menu d'options :"
    echo "1. Lancer l'installation complète"
    echo "2. Installer docker"
    echo "3. Mettre à jour docker-compose"
    echo "4. Ajouter la config de Wireguard"
    echo "5. Lancer l'installation des containers"
    echo "6. Quitter"
}

# Fonction pour exécuter le script 1
executer_script1() {
    echo "Exécution du script 1..."
    # Insérez ici la commande pour lancer le script 1
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour exécuter le script 2
executer_script2() {
    echo "Exécution du script 2..."
    # Insérez ici la commande pour lancer le script 2
    read -p "Appuyez sur Entrée pour continuer..."
}

# Fonction pour exécuter le script 3
executer_script3() {
    echo "Exécution du script 3..."
    # Insérez ici la commande pour lancer le script 3
    read -p "Appuyez sur Entrée pour continuer..."
}

# Boucle principale
while true; do
    afficher_menu

    read -p "Sélectionnez une option (1/2/3/4) : " choix

    case $choix in
        1)
            executer_script1
            ;;
        2)
            executer_script2
            ;;
        3)
            executer_script3
            ;;
        4)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Option invalide. Veuillez sélectionner une option valide."
            read -p "Appuyez sur Entrée pour continuer..."
            ;;
    esac
done