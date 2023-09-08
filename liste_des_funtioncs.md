# Fonctions du premier script

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Fonction pour créer un répertoire s'il n'existe pas
function create_directory() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

# Fonction pour demander à l'utilisateur de continuer ou d'annuler
function ask_with_default() {
  ask_question "$1"
  read user_input
  if [ -z "$user_input" ]; then
    user_input="$2"
  fi
  echo "$user_input"
}

# Fonctions du deuxième script

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
  if ! groups "$USER" | grep &>/dev/null '\bdocker\b'; then
    echo "L'utilisateur n'appartient pas au groupe Docker. Ajout de l'utilisateur au groupe Docker..."
    sudo usermod -aG docker "$USER"
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
  # ...
}

# Fonctions du troisième script

# Fonction pour afficher une question en jaune
function ask_question() {
  echo -e "\033[33m$1\033[0m"
}

# Fonction pour créer un répertoire s'il n'existe pas
function create_directory() {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    ask_question "Le répertoire $directory n'existe pas. Voulez-vous le créer ? (Oui/Non) "
    read create_dir_choice
    if [ "$create_dir_choice" = "oui" ] || [ "$create_dir_choice" = "Oui" ] || [ "$create_dir_choice" = "o" ] || [ "$create_dir_choice" = "O" ]; then
      mkdir -p "$directory"
      echo "Le répertoire $directory a été créé."
    else
      echo "Le répertoire $directory n'a pas été créé. Le fichier WireGuard ne sera pas enregistré."
      exit 1
    fi
  fi
}

# Fonction pour enregistrer le code de configuration WireGuard
function save_wireguard_config() {
  # ...
}

# Début du script du troisième script
# ...
