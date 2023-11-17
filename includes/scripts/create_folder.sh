#!/bin/bash
echo ""
echo -e "\e[32mEcrire les noms de dossiers à créer dans Medias ex: Films Series\e[0m \e[36m(touche Entrée après chaque saisie)\e[0m .. \e[32mpuis stop une fois terminé\e[0m"   				
while :
do		
  read -p "" EXCLUDEPATH
  mkdir -p /home/$USER/Medias/$EXCLUDEPATH
  chown -R $USER:$USER /home/$USER/Medias/$EXCLUDEPATH
  if [[ "$EXCLUDEPATH" = "STOP" ]] || [[ "$EXCLUDEPATH" = "stop" ]]; then
    rm -rf /home/$USER/Medias/$EXCLUDEPATH
    break
  fi
done
