import os
import yaml
import docker
from dotenv import load_dotenv

# Chemin par défaut pour le fichier .env
env_file_path = os.path.expanduser("~")
env_file = os.path.join(env_file_path, ".env")

# Charger les variables d'environnement depuis le fichier .env
load_dotenv(env_file)

# Remplir le modèle YAML avec les variables d'environnement
def fill_yaml_template(template_file, env_vars):
    with open(template_file, "r") as file:
        template = yaml.safe_load(file)

    for key, value in env_vars.items():
        for service in template.get("services", {}).values():
            if "environment" not in service:
                service["environment"] = {}
            service["environment"][key] = value

    return template

# Récupérer la liste des applications à partir du fichier docker-compose.yml
def get_application_list(yaml_data):
    services = yaml_data.get("services", {})
    application_list = [service.get("container_name") for service in services.values() if service.get("container_name")]
    return application_list

# Installer les applications sélectionnées
def install_applications(applications_to_install):
    client = docker.from_env()
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

if __name__ == "__main__":
    app_settings_dir = os.getenv("APP_SETTINGS_DIR")
    if not app_settings_dir:
        print("La variable d'environnement APP_SETTINGS_DIR n'est pas définie.")
    else:
        env_vars = dict(os.environ)  # Copier toutes les variables d'environnement actuelles
        if not env_vars:
            print("Aucune variable d'environnement trouvée.")
        else:
            yaml_template_file = os.path.join(app_settings_dir, "docker-compose.yml")
            if os.path.exists(yaml_template_file):
                yaml_data = fill_yaml_template(yaml_template_file, env_vars)

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
            else:
                print(f"Le fichier docker-compose.yml n'existe pas dans le répertoire {app_settings_dir}.")
