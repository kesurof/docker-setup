#!/bin/bash

# Vérifier si pip est installé
if ! command -v pip &> /dev/null; then
  echo "pip n'est pas installé. Installation de pip..."
  sudo apt-get update
  sudo apt-get install -y python3-pip
fi

# Vérifier si PyYAML est installé
if ! python3 -c "import yaml" &> /dev/null; then
  echo "PyYAML n'est pas installé. Installation de PyYAML..."
  sudo pip install pyyaml
fi

# Vérifier si python-dotenv est installé
if ! python3 -c "import dotenv" &> /dev/null; then
  echo "python-dotenv n'est pas installé. Installation de python-dotenv..."
  sudo pip install python-dotenv
fi

echo "Toutes les dépendances ont été installées avec succès."
