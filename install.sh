cat <<'EOF' > install.sh
#!/bin/bash

set -e

echo "🚀 Updating system..."
apt update && apt upgrade -y
apt install -y curl nano sudo ca-certificates gnupg

echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com | sh
apt install -y docker-compose-plugin

echo "📁 Creating folder structure..."
mkdir -p /mnt/storage/{immich,files,jellyfin,backups}
mkdir -p /opt/immich
mkdir -p /opt/filebrowser

echo "🖥️ Installing Immich..."
cd /opt/immich

wget -O docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env

sed -i 's|UPLOAD_LOCATION=.*|UPLOAD_LOCATION=/mnt/storage/immich|' .env

# Set timezone if not present
grep -q "TZ=" .env || echo "TZ=Asia/Kolkata" >> .env

echo "⚡ Removing ML service for lightweight setup..."
sed -i '/immich-machine-learning/,/restart:/d' docker-compose.yml || true

echo "📂 Starting Immich..."
docker compose up -d || true

echo "📂 Installing FileBrowser..."
cd /opt/filebrowser

cat <<EOC > docker-compose.yml
services:
  filebrowser:
    image: gtstef/filebrowser
    container_name: filebrowser
    ports:
      - "8080:80"
    volumes:
      - /mnt/storage:/srv
      - ./filebrowser.db:/database.db
    restart: unless-stopped
EOC

docker compose up -d

echo "🧪 Testing storage..."
touch /mnt/storage/.setup-test || true

echo "✅ DONE!"
echo ""
echo "👉 Immich: http://<YOUR-IP>:2283"
echo "👉 FileBrowser: http://<YOUR-IP>:8080"
echo ""
echo "⚠️ Next step: change FileBrowser password immediately"
EOF

chmod +x install.sh
./install.sh