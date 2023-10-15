#!/bin/bash

  SETTINGS_SOURCE=/home/$USER/docker-setup
  # On rentre dans le venv
  source ${SETTINGS_SOURCE}/venv/bin/activate
  # On charge les fonctions
  source ${SETTINGS_SOURCE}/includes/scripts/functions.sh

  PYTHONPATH=${SETTINGS_SOURCE}/venv/lib/$(ls ${SETTINGS_SOURCE}/venv/lib)/site-packages
  export PYTHONPATH
  # la fonction nous a probablement fait sortir du venv, on le recharge
  source ${SETTINGS_SOURCE}/venv/bin/activate



