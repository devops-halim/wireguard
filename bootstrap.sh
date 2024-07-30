#!/bin/bash

# Überprüfen und Installieren von Ansible, Docker und Docker Compose
echo "Überprüfen und Installieren der benötigten Pakete..."

# Update Paketindex
sudo apt-get update -y

# Installieren von Ansible
if ! [ -x "$(command -v ansible)" ]; then
  echo "Ansible wird installiert..."
  sudo apt-get install -y ansible unzip
else
  echo "Ansible ist bereits installiert."
fi

# Installieren von Docker
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker wird installiert..."
  sudo apt-get install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
else
  echo "Docker ist bereits installiert."
fi

# Installieren von Docker Compose
if ! [ -x "$(command -v docker-compose)" ]; then
  echo "Docker Compose wird installiert..."
  sudo apt-get install -y docker-compose
else
  echo "Docker Compose ist bereits installiert."
fi

# Installieren von Certbot und Plugin für Nginx
if ! [ -x "$(command -v certbot)" ]; then
  echo "Certbot wird installiert..."
  sudo apt-get install -y certbot python3-certbot-nginx
else
  echo "Certbot ist bereits installiert."
fi

# Benutzer nach Eingaben fragen
read -p "Geben Sie Ihre DNS-Domain ein (z.B., example.com): " SERVER_DOMAIN
read -p "Geben Sie Ihr JWT-Secret ein: " JWT_SECRET
read -p "Geben Sie Ihren Benutzernamen für Authelia ein: " USERNAME
read -p "Geben Sie Ihre E-Mail für Authelia ein: " USER_EMAIL
read -sp "Geben Sie Ihr Passwort für Authelia ein: " USER_PASSWORD
echo

# Passwort hash erstellen
USER_PASSWORD_HASH=$(echo -n $USER_PASSWORD | htpasswd -ni $USERNAME)

# Arbeitsverzeichnis erstellen
WORK_DIR="/opt/wireguard-setup"
mkdir -p $WORK_DIR
cd $WORK_DIR

# Repository herunterladen und extrahieren
GITHUB_REPO_URL="https://github.com/devops-halim/wireguard/archive/refs/heads/main.zip"
wget $GITHUB_REPO_URL -O repo.zip
unzip repo.zip
mv wireguard-main/* ./
rm -rf wireguard-main repo.zip

# Umgebungsvariablen in Konfigurationsdateien einfügen
# Docker Compose Datei bearbeiten
sed -i "s/\$SERVER_DOMAIN/$SERVER_DOMAIN/g" docker/docker-compose.yml

# Authelia Konfigurationsdatei bearbeiten
sed -i "s/\$SERVER_DOMAIN/$SERVER_DOMAIN/g" docker/authelia/configuration.yml
sed -i "s/\$JWT_SECRET/$JWT_SECRET/g" docker/authelia/configuration.yml

# Authelia Benutzerdatenbank bearbeiten
sed -i "s/\$USERNAME/$USERNAME/g" docker/authelia/users_database.yml
sed -i "s/\$USER_PASSWORD_HASH/$USER_PASSWORD_HASH/g" docker/authelia/users_database.yml
sed -i "s/\$USER_EMAIL/$USER_EMAIL/g" docker/authelia/users_database.yml

# NGINX Konfigurationsdatei bearbeiten
sed -i "s/\$SERVER_DOMAIN/$SERVER_DOMAIN/g" docker/nginx/default.conf

# Ansible-Playbook ausführen
cd ansible
ansible-playbook -i "localhost," -c local playbook.yml






# #!/bin/bash

# # Überprüfen und Installieren von Ansible, Docker und Docker Compose
# echo "Überprüfen und Installieren der benötigten Pakete..."

# # Update Paketindex
# sudo apt-get update -y

# # Installieren von Ansible
# if ! [ -x "$(command -v ansible)" ]; then
#   echo "Ansible wird installiert..."
#   sudo apt-get install -y ansible unzip
# else
#   echo "Ansible ist bereits installiert."
# fi

# # Installieren von Docker
# if ! [ -x "$(command -v docker)" ]; then
#   echo "Docker wird installiert..."
#   sudo apt-get install -y docker.io
#   sudo systemctl start docker
#   sudo systemctl enable docker
# else
#   echo "Docker ist bereits installiert."
# fi

# # Installieren von Docker Compose
# if ! [ -x "$(command -v docker-compose)" ]; then
#   echo "Docker Compose wird installiert..."
#   sudo apt-get install -y docker-compose
# else
#   echo "Docker Compose ist bereits installiert."
# fi

# # Installieren von Certbot und Plugin für Nginx
# if ! [ -x "$(command -v certbot)" ]; then
#   echo "Certbot wird installiert..."
#   sudo apt-get install -y certbot python3-certbot-nginx
# else
#   echo "Certbot ist bereits installiert."
# fi

# # Benutzer nach Eingaben fragen
# read -p "Geben Sie Ihre DNS-Domain ein (z.B., example.com): " SERVER_DOMAIN
# read -p "Geben Sie Ihr JWT-Secret ein: " JWT_SECRET
# read -p "Geben Sie Ihren Benutzernamen für Authelia ein: " USERNAME
# read -p "Geben Sie Ihre E-Mail für Authelia ein: " USER_EMAIL
# read -sp "Geben Sie Ihr Passwort für Authelia ein: " USER_PASSWORD
# echo

# # Passwort hash erstellen
# USER_PASSWORD_HASH=$(echo -n $USER_PASSWORD | htpasswd -ni $USERNAME)

# # Arbeitsverzeichnis erstellen
# mkdir -p /opt/wireguard-setup/ansible/roles/wireguard_role/tasks
# mkdir -p /opt/wireguard-setup/docker/authelia
# mkdir -p /opt/wireguard-setup/docker/nginx

# cd /opt/wireguard-setup

# # Repository herunterladen und extrahieren
# GITHUB_REPO_URL="https://github.com/devops-halim/wireguard/archive/refs/heads/main.zip"
# REPO_NAME="wireguard"
# wget $GITHUB_REPO_URL -O repo.zip
# unzip repo.zip
# cd ansible
# ansible-playbook -i "localhost," -c local playbook.yml