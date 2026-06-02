## Install Immich

### Step 1: Create App Directory
```bash
mkdir -p /opt/immich
cd /opt/immich
```

### Step 2: Download Compose Files
```bash
wget -O docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
```

### Step 3: Configure Environment Variables
Open the `.env` file and modify the following key values:
```bash
nano .env
```
```env
UPLOAD_LOCATION=/mnt/storage/immich
DB_PASSWORD=your_secure_immich_password
TZ=Asia/Kolkata
```

### Step 4: (Optional) Disable Machine Learning
If you are running on a low-resource system and want to save CPU/RAM, open `docker-compose.yml`:
```bash
nano docker-compose.yml
```
Locate and **remove or comment out** the entire `immich-machine-learning` service block.

### Step 5: Start Immich
```bash
docker compose up -d
```
Access the Immich Web UI at: `http://<YOUR-LXC-IP>:2283`

---