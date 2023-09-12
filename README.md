# Docker Setup

Docker Setup est un script Bash d'automatisation conçu pour simplifier l'installation et la configuration d'un environnement Docker pour les applications de serveur populaires. Il vise à faciliter la mise en place d'une seedbox, d'un serveur Plex, et d'autres services dans un environnement Docker sur des distributions Linux telles qu'Ubuntu et Debian.

## Avantages

- Installation rapide et automatisée de plusieurs services Docker.
- Configuration simplifiée à l'aide d'une interface en ligne de commande.
- Support des distributions Linux populaires (Ubuntu et Debian).
- Personnalisation flexible grâce aux options interactives.
- Gestion de l'installation de Docker et Docker Compose.
- Facilité d'utilisation, idéal pour les utilisateurs avec des connaissances de base en Docker.

1. **Vérification des droits d'utilisateur** : Le script commence par vérifier si l'utilisateur exécute le script en tant que superutilisateur (root). Si c'est le cas, il affiche un message d'erreur et quitte. Cela évite d'exécuter le script en tant que superutilisateur, ce qui pourrait être dangereux.

2. **Vérification de l'appartenance au groupe Docker** : Le script vérifie si l'utilisateur appartient au groupe Docker en utilisant la commande `groups`. Si l'utilisateur n'appartient pas au groupe Docker, il lui offre la possibilité d'être ajouté au groupe en utilisant `sudo usermod`. Le script gère également les cas où l'ajout au groupe Docker échoue.

3. **Détection de la distribution Linux** : Le script utilise la commande `lsb_release` pour détecter la distribution Linux en cours d'exécution (Ubuntu ou Debian). Si la distribution n'est pas prise en charge, il affiche un message d'erreur et quitte.

4. **Configuration du référentiel Docker** : En fonction de la distribution et de la version détectées, le script configure le référentiel Docker approprié en utilisant les variables `docker_repo`.

5. **Demande du chemin d'installation des volumes des containers** : L'utilisateur est invité à fournir un chemin pour l'installation des volumes des containers. Si aucun chemin n'est fourni, le chemin par défaut est utilisé.

6. **Installation de Docker et Docker Compose** : L'utilisateur est invité à choisir s'il souhaite installer Docker. Si la réponse est positive, le script ajoute la clé GPG Docker, configure le référentiel Docker, met à jour les informations du package, et installe Docker et Docker Compose.

7. **Saisie des informations utilisateur** : Le script demande à l'utilisateur de saisir différentes informations, telles que la clé API RealDebrid, l'adresse du serveur Plex, l'identifiant Plex et le token Plex.

8. **Création du répertoire WireGuard (le cas échéant)** : Le script vérifie si le répertoire pour la configuration WireGuard existe. Si ce n'est pas le cas, il demande à l'utilisateur s'il souhaite le créer.

9. **Saisie du code de configuration WireGuard** : L'utilisateur est invité à coller le code de configuration WireGuard. Le script enregistre ce code dans un fichier.

10. **Génération du fichier docker-compose.yml** : Le script génère un fichier `docker-compose.yml` contenant les services à déployer, y compris Nginx Proxy Manager, Portainer, Plex, et d'autres, avec les informations fournies par l'utilisateur.

11. **Fin du script** : Le script se termine après avoir généré le fichier `docker-compose.yml`.


Voici un exemple de documentation que vous pouvez ajouter dans le fichier `README.md` de votre projet GitHub pour présenter le projet, ses avantages et fournir une procédure d'installation pas à pas :


## Prérequis

Avant d'installer Docker Setup, assurez-vous de disposer des éléments suivants sur votre système :

- **Utilisateur** : Vous devez créer un utilisateur non root et lui accorder les droits suivants **(remplacer USER par le votre à créer)** :
  
  ```bash
  adduser USER
  ```
  ```bash
  usermod -aG sudo USER && groupadd docker && usermod -aG docker USER
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
   git clone https://github.com/kesurof/docker-setup.git
   ```

2. **Accédez au répertoire du script** : Utilisez la commande `cd` pour accéder au répertoire du script que vous venez de cloner. Par exemple :

   ```bash
   cd docker-setup
   ```

3. **Exécutez le script** : Après avoir accédé au répertoire, assurez-vous que le script est exécutable en utilisant la commande `chmod` si nécessaire :

   ```bash
   chmod +x install.sh
   ```

   Ensuite, exécutez le script :

   ```bash
   ./install.sh
   ```
   **en version rapide**
   ```bash
   git clone https://github.com/kesurof/docker-setup.git && cd docker-setup && chmod +x install.sh && ./install.sh
   ```

4. **Suivez les instructions du script** : Pendant l'exécution du script, il vous demandera peut-être des informations spécifiques ou des confirmations. Assurez-vous de suivre ces instructions et de fournir les informations requises.

5. **Attendez la fin de l'installation** : Le script continuera à s'exécuter jusqu'à ce qu'il ait terminé toutes les étapes d'installation. Attendez qu'il affiche un message de confirmation ou de réussite.

6. **Vérifiez l'installation** : Une fois le script terminé, vérifiez que les composants ou les configurations que vous souhaitiez installer sont opérationnels. Cela peut inclure le lancement de services Docker, la vérification de fichiers de configuration, etc.


C'est tout ! Vous avez maintenant installé et exécuté le script à partir du dépôt GitHub. Assurez-vous de suivre les instructions spécifiques au script et aux composants que vous installez pour garantir une installation correcte et sécurisée.

## Structure des Dossiers

Après l'installation de Docker Setup, le script créera une structure de dossiers pour organiser les données et les configurations des différents services Docker. Voici la structure des dossiers créés :

- **nginx-proxy-manager/data** : Les données de Nginx Proxy Manager.
- **nginx-proxy-manager/letsencrypt** : Les certificats SSL générés par Let's Encrypt pour les domaines configurés.
- **portainer** : Les données de Portainer, un gestionnaire de conteneurs Docker.
- **plex/config** : Les fichiers de configuration de Plex Media Server.
- **plex/transcode** : L'emplacement où Plex stocke les fichiers transcodés.
- **wireguard/config** : Les fichiers de configuration de WireGuard pour les connexions VPN.
- **overseerr/config** : Les fichiers de configuration d'Overseerr, une application de demande de contenu.
- **tautulli/config** : Les fichiers de configuration de Tautulli, un moniteur de serveur Plex.
- **jackett/config** : Les fichiers de configuration de Jackett, un agrégateur de torrents.

Chacun de ces dossiers contient les données et configurations spécifiques à chaque service Docker pour faciliter la gestion et la sauvegarde des données.

## Script d'installation - Installer Rclone-RD et Plex_Debrid

**-> Le script ./install.sh doit être lancé avec sudo uniquement pour ce choix (N°6).**

Le script d'installation est conçu pour simplifier la configuration d'un environnement de téléchargement et de streaming utilisant les services Real Debrid, Rclone, et Plex Debrid sur un système Linux. Il automatise l'installation et la configuration de ces composants pour une utilisation plus facile et plus efficace.

---

## Avantages

1. **Simplicité d'installation** : Le script automatise le processus d'installation de plusieurs composants, éliminant ainsi la nécessité de configurer manuellement chaque service.

2. **Gestion des dépendances** : Le script vérifie et installe automatiquement les dépendances nécessaires, telles que Python 3, python3-venv, et pip3, garantissant que le système est prêt à exécuter les services.

3. **Configuration de Rclone** : Rclone est configuré pour monter un lecteur Real Debrid, simplifiant ainsi l'accès aux fichiers hébergés dans le cloud.

4. **Installation de Plex Debrid** : Le script installe et configure Plex Debrid, permettant de gérer et de télécharger des médias à partir de Real Debrid.

5. **Intégration avec systemd** : Les services Rclone et Plex Debrid sont configurés en tant que services systemd, ce qui garantit qu'ils sont toujours en cours d'exécution, même après le redémarrage du système.

---

## Fonctionnement du script

Le script fonctionne de la manière suivante :

1. **Chargement des variables d'environnement** : Le script charge les variables d'environnement à partir d'un fichier `.env`, qui doit être situé dans le répertoire personnel de l'utilisateur. Si le fichier n'est pas trouvé, le script affiche un message d'erreur et s'arrête.

2. **Vérification des droits d'administration** : Le script vérifie si l'utilisateur exécute le script en tant qu'administrateur (sudo). Si ce n'est pas le cas, il affiche un avertissement et s'arrête.

3. **Vérification des dépendances** : Le script vérifie si Python 3, python3-venv, et pip3 sont installés. S'ils ne le sont pas, il les installe automatiquement.

4. **Installation de Rclone** : Si Rclone n'est pas déjà installé, le script télécharge et installe la version de Rclone spécifiée. Il configure également le répertoire de configuration Rclone.

5. **Création du répertoire Rclone** : Si le répertoire spécifié pour Rclone n'existe pas, le script le crée.

6. **Changement de propriétaire et permissions** : Le script change le propriétaire du répertoire Rclone à l'utilisateur actuel et accorde les droits d'écriture.

7. **Configuration des services systemd** : Le script configure les services systemd pour Rclone et Plex Debrid en créant les fichiers de service nécessaires.

8. **Ajout de user_allow_other à fuse.conf** : Le script modifie le fichier `/etc/fuse.conf` pour autoriser l'utilisateur à monter le lecteur Rclone.

9. **Redémarrage du service Rclone** : Le script redémarre le service Rclone pour prendre en compte les modifications.

10. **Attente et vérification** : Le script attend quelques secondes, puis affiche le statut des services Rclone et Plex Debrid pour vérification.

11. **Installation terminée** : Le script affiche un message de confirmation lorsque l'installation est terminée.

---

## Utilisation

Pour utiliser le script d'installation, suivez ces étapes :

1. Assurez-vous que vous exécutez le script en tant qu'administrateur (utilisez `sudo ./install.sh`).

2. Assurez-vous que le fichier `.env` contenant les variables d'environnement appropriées est présent dans le répertoire personnel de l'utilisateur.

4. Suivez les messages du script pour vérifier l'installation et la configuration des différents composants.

5. Une fois le script terminé, vérifiez le statut des services Rclone et Plex Debrid en utilisant `sudo systemctl status rclone.service` et `sudo systemctl status plex_debrid.service`.

---

Ce script simplifie grandement la mise en place d'un environnement de téléchargement et de streaming basé sur Real Debrid, Rclone et Plex Debrid. Suivez les étapes d'installation pour profiter rapidement de ces services sur votre système Linux.
---
