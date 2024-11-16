#!/bin/bash

# Überprüfen, ob das Betriebssystem Ubuntu oder Debian ist
os_info=$(cat /etc/os-release)
if ! echo "$os_info" | grep -qE "ID=(ubuntu|debian)"; then
    echo "Das Betriebssystem ist weder Ubuntu noch Debian. Skript wird abgebrochen."
    exit 1
fi

echo "Das Betriebssystem ist kompatibel. Skript wird fortgesetzt."

# Repository aktualisieren
echo "Aktualisiere Repositories..."
sudo apt update && sudo apt upgrade -y


# Neuen Benutzer erstellen
# new_user="vpn"
# echo "Erstelle Benutzer '$new_user'..."
# sudo useradd -m -s /bin/bash "$new_user"
# sudo passwd "$new_user"
# sudo usermod -aG sudo "$new_user"

#sudo su - $new_user

# Docker und Docker Compose sicherstellen
echo "Stelle sicher, dass Docker und Docker Compose installiert sind..."
if ! command -v docker &> /dev/null; then
    echo "Docker ist nicht installiert. Installiere Docker..."
    # Docker GPG-Schlüssel hinzufügen
    sudo mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]')/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    #  Docker Repository hinzufügen
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(lsb_release -si | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose ist nicht installiert. Installiere Docker Compose..."
    sudo apt install -y docker-compose-plugin
    #sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    #sudo chmod +x /usr/local/bin/docker-compose
fi
# Benutzer zur Docker-Gruppe hinzufügen
# echo "Füge Benutzer '$new_user' zur Docker-Gruppe hinzu..."
# sudo usermod -aG docker "$new_user"


# GitHub URL of the docker-compose.yml file (raw version)
GITHUB_URL="https://raw.githubusercontent.com/devops-halim/wireguard/refs/heads/main/docker-compose.yml"

# Step 1: Download docker-compose.yml from GitHub
echo "Downloading docker-compose.yml from GitHub..."
curl -L "$GITHUB_URL" -o "docker-compose.yml"


# Verzeichnis des Skripts bestimmen
docker_compose_dir="$(dirname "$(realpath "$0")")"

# Überprüfen, ob docker-compose.yml existiert
if [ ! -f "$docker_compose_dir/docker-compose.yml" ]; then
    echo "Die Datei docker-compose.yml wurde im Verzeichnis $docker_compose_dir nicht gefunden!"
    exit 1
fi

# Docker Compose starten
echo "Starte Docker Compose im Verzeichnis $docker_compose_dir..."
cd "$docker_compose_dir" || exit
docker compose up -d

echo "Docker Compose wurde erfolgreich gestartet!"
