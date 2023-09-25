#!/usr/bin/env python3

import os
import yaml
import subprocess
import sys

def create_virtual_environment(venv_dir):
    if not os.path.exists(venv_dir):
        print(f"Création de l'environnement virtuel dans {venv_dir}...")
        subprocess.call([sys.executable, "-m", "venv", venv_dir])

def activate_virtual_environment(venv_dir):
    activate_script = os.path.join(venv_dir, "bin", "activate")
    if os.name == 'posix':
        activate_script = "source " + activate_script
    elif os.name == 'nt':
        activate_script = os.path.join(venv_dir, "Scripts", "activate.bat")

    os.system(activate_script)

def install_pip():
    try:
        import pip
    except ImportError:
        print("pip n'est pas installé. Installation de pip...")
        subprocess.call(["sudo", "apt-get", "update"])
        subprocess.call(["sudo", "apt-get", "install", "-y", "python3-pip"])

def install_docker_module(venv_dir):
    try:
        import docker
    except ImportError:
        print("Installation du module Docker dans l'environnement virtuel...")
        subprocess.call([os.path.join(venv_dir, "bin", "pip"), "install", "docker"])

def install_dotenv_module(venv_dir):
    try:
        import dotenv
    except ImportError:
        print("Installation du module python-dotenv dans l'environnement virtuel...")
        subprocess.call([os.path.join(venv_dir, "bin", "pip"), "install", "python-dotenv"])

def main():
    # Définir le chemin absolu du répertoire où vous souhaitez créer l'environnement virtuel
    user_home = os.path.expanduser("~")
    venv_dir = os.path.join(user_home, "venv_container")

    # Créer et activer l'environnement virtuel
    create_virtual_environment(venv_dir)
    activate_virtual_environment(venv_dir)

    # Installer pip si nécessaire
    install_pip()

    # Installer le module Docker dans l'environnement virtuel
    install_docker_module(venv_dir)

    # Installer le module python-dotenv dans l'environnement virtuel
    install_dotenv_module(venv_dir)

    # Charger les variables d'environnement depuis le fichier .env
    try:
        from dotenv import load_dotenv
        env_file_path = user_home
        env_file = os.path.join(env_file_path, ".env")
        load_dotenv(env_file)
    except ImportError:
        print("Le module python-dotenv n'a pas été installé correctement dans l'environnement virtuel.")


    # Charger le modèle YAML
    app_settings_dir = os.getenv("APP_SETTINGS_DIR")
    if not app_settings_dir:
        print("La variable d'environnement APP_SETTINGS_DIR n'est pas définie.")
        return

    yaml_template_file = os.path.join(app_settings_dir, "docker-compose.yml")
    if not os.path.exists(yaml_template_file):
        print(f"Le fichier docker-compose.yml n'existe pas dans le répertoire {app_settings_dir}.")
        return

    with open(yaml_template_file, "r") as file:
        yaml_data = yaml.safe_load(file)

    # Remplir le modèle YAML avec les variables d'environnement
    env_vars = dict(os.environ)
    for key, value in env_vars.items():
        for service in yaml_data.get("services", {}).values():
            if "environment" not in service:
                service["environment"] = {}
            service["environment"][key] = value

    # Installer les applications sélectionnées
    client = docker.from_env()

    def get_application_list(yaml_data):
        services = yaml_data.get("services", {})
        return [service.get("container_name") for service in services.values() if service.get("container_name")]

    def install_applications(applications_to_install):
        for app_name in applications_to_install:
            service_name = yaml_data["services"].get(app_name, {}).get("container_name")
            if service_name:
                service = client.containers.get(service_name)
                if service:
                    print(f"Le conteneur {service_name} existe déjà.")
                else:
                    image = yaml_data["services"].get(app_name, {}).get("image")
                    if image:
                        print(f"Création du conteneur {service_name} à partir de l'image {image}...")
                        client.containers.run(image, detach=True, name=service_name)
                    else:
                        print(f"Image non trouvée pour l'application {app_name}.")
            else:
                print(f"Application {app_name} non trouvée dans le fichier docker-compose.yml.")

    print("Liste des applications disponibles :")
    applications = get_application_list(yaml_data)
    for i, app_name in enumerate(applications, start=1):
        print(f"{i}. {app_name}")

    selection = input("Sélectionnez les applications à installer (séparées par des espaces) : ")
    selected_applications = selection.split()

    if selected_applications:
        install_applications(selected_applications)
    else:
        print("Aucune application sélectionnée.")

    # Désactiver l'environnement virtuel
    os.system("deactivate")
    print("Toutes les dépendances ont été installées avec succès dans l'environnement virtuel.")

if __name__ == "__main__":
    main()
