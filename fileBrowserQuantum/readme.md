## 📂 Install FileBrowser Quantum

### Step 1: Create App Directory
```bash
mkdir -p /opt/filebrowser
cd /opt/filebrowser
```

### Step 2: Create Compose Configuration
```bash
nano docker-compose.yml
```
Paste the following service configuration:
```yaml
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
```

### Step 3: Start FileBrowser
```bash
docker compose up -d
```
Access the FileBrowser Web UI at: `http://<YOUR-LXC-IP>:8080`

---

## 🔐 8. Permissions & Troubleshooting

Because this is an unprivileged LXC container, you may encounter `Permission Denied` or read-only errors when containers try to write to `/mnt/storage`. 

If write issues occur, adjust the ownership permissions of the mount directory to match the container's internal users:

```bash
# Option A: Standard Docker Root mapping
chown -R 1000:1000 /mnt/storage

# Option B: Alternative mapping if using specific application IDs
chown -R 33:33 /mnt/storage
```

### Test Directory Permissions
```bash
touch /mnt/storage/testfile
ls -l /mnt/storage
```