# Docker Setup

Ce script simplifie grandement la mise en place d'un environnement docker de streaming basé sur Real Debrid, Rclone et RDTclient.
Suivez les étapes d'installation pour profiter rapidement de ces services sur votre système Linux.

## Avantages

- Installation rapide et automatisée de plusieurs services Docker.
- Configuration simplifiée à l'aide d'une interface en ligne de commande.
- Support des distributions Linux populaires (Ubuntu et Debian).
- Personnalisation flexible grâce aux options interactives.
- Gestion de l'installation de Docker et Docker Compose.
- Facilité d'utilisation, idéal pour les utilisateurs avec des connaissances de base en Docker.


## Prérequis

Avant d'installer Docker Setup, assurez-vous de disposer des éléments suivants sur votre système :

- **Utilisateur** : Vous devez créer un utilisateur non root et lui accorder les droits suivants **(remplacer USER par le votre à créer)** :
  
  ```bash
  adduser USER
  ```
  ```bash
  sudo usermod -aG sudo kesurof && sudo groupadd docker && sudo usermod -aG docker kesurof
  ```
- Vous devez ensuite vous déconnecter de root, afin de vous connecter avec le nouvel utilisateur

- **Git, fuse et mise à jour** : Installez Git et mettre à jour :
  
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y && sudo apt install git -y && sudo apt install fuse -y
   ```
   
## Procédure d'Installation

Suivez ces étapes pour installer Docker Setup sur votre système :

1. **Clonez le dépôt** : Ouvrez votre terminal et exécutez la commande suivante pour cloner le dépôt GitHub dans votre répertoire actuel (ou dans le répertoire de votre choix) :

   ```bash
   git clone https://github.com/kesurof/docker-setup.git && cd docker-setup
   ```

2. **Exécutez le script** : Après avoir accédé au répertoire, assurez-vous que le script est exécutable en utilisant la commande `chmod` si nécessaire :

   ```bash
   sudo ./install.sh
   ```
   **Une fois les premiers éléments installé, un message vous demandera de vous déconnecter puis reconnecter, ensuite lancer la commande san sudo**
   ```bash
   ./install.sh
   ```

3. **Suivez les instructions du script** : Pendant l'exécution du script, il vous demandera peut-être des informations spécifiques ou des confirmations. Assurez-vous de suivre ces instructions et de fournir les informations requises.

4. **Attendez la fin de l'installation** : Le script continuera à s'exécuter jusqu'à ce qu'il ait terminé toutes les étapes d'installation. Attendez qu'il affiche un message de confirmation ou de réussite.

5. **Vérifiez l'installation** : Une fois le script terminé, vérifiez que les composants ou les configurations que vous souhaitiez installer sont opérationnels. Cela peut inclure le lancement de services Docker, la vérification de fichiers de configuration, etc.


C'est tout ! Vous avez maintenant installé et exécuté le script à partir du dépôt GitHub. Assurez-vous de suivre les instructions spécifiques au script et aux composants que vous installez pour garantir une installation correcte et sécurisée.
