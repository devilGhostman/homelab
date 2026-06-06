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

## Migrate Google Photos to Immich 

### Step 1: Export Your Photos from Google Photos
- Open Google Takeout.
- Deselect all services.
- Select Google Photos only.
- Choose:
    - Export once
    - ZIP format
    - Largest archive size available (recommended)
- Create the export.
- Wait for Google to prepare the archive.
- Download all generated ZIP files.


### Step 2: Create an Immich API Key
- Log in to Immich.
- Go to Account Settings → API Keys.
- Create a new API key.
- Copy and save the key securely.

### Step 3 : Download immich go and Upload Photos

Download the pre-built binary for your system
```bash
https://github.com/simulot/immich-go/releases
```
Usage :
```bash
  immich-go upload from-google-photos \
  --server=http://<YOUR-LXC-IP>:2283 \
  --api-key=YOUR-IMMICH-API-KEY\
  --sync-albums \
  --concurrent-tasks=4-6 \
  --client-timeout=60m \
  --pause-immich-jobs=false \
  --on-errors=continue \
  --manage-raw-jpeg=StackCoverRaw \
  --manage-burst=Stack \
  --manage-heic-jpeg=StackCoverJPG \
  /path/to/google/takeout-*.zip
```
