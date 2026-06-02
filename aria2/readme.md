# 🚀 Aria2 + AriaNg Download Server (LXC Setup)

This setup turns your Proxmox LXC into a fast download server using:

- aria2 (download engine)
- AriaNg (web UI)
- nginx (web hosting)
- systemd (auto-start service)
- shared storage on `/mnt/storage`

---


# 🧱 Folder Structure

```text
/mnt/storage/
└── downloads/        # All downloaded files
/opt/aria2/
└── aria2.conf        # configuration file
/var/www/ariang/      # web UI
```

### Step 1: Update and Install Aria2
```bash
apt update
apt install -y aria2
```

### Step 2: Create Directories
```bash
mkdir -p /opt/aria2
mkdir -p /mnt/storage/downloads
```

### Step 3: Create Aria2 Config
```bash
nano /opt/aria2/aria2.conf
```

### Step 4: Add this to Config File
```bash
dir=/mnt/storage/downloads
continue=true

enable-rpc=true
rpc-listen-all=true
rpc-allow-origin-all=true
rpc-listen-port=6800

auto-save-interval=60
log-level=notice
```

### Step 5: Create Systemd Service
```bash
nano /etc/systemd/system/aria2.service
```

### Step 6: Add this to Service File
```bash
[Unit]
Description=Aria2 Download Manager
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/aria2c \
  --conf-path=/opt/aria2/aria2.conf \
  -d /mnt/storage/downloads
Restart=on-failure
RestartSec=3
User=root
WorkingDirectory=/mnt/storage

[Install]
WantedBy=multi-user.target
```

### Step 7: Enable and Start Service
```bash 
systemctl daemon-reload
systemctl enable aria2
systemctl start aria2
```

### Step 8: Verify RPC Port
```bash
ss -tulnp | grep 6800
```

---
# AriaNg Web UI

### Step 1: Install Nginx
```Bash
apt install -y nginx unzip wget
```
### Step 2: Download and Extract AriaNg
```Bash
mkdir -p /var/www/ariang
cd /var/www/ariang

wget https://github.com/mayswind/AriaNg/releases/latest/download/AriaNg.zip -O ariang.zip
unzip ariang.zip
rm ariang.zip
```

### Step 3: Fix Permissions
```Bash
chown -R www-data:www-data /var/www/ariang
chmod -R 755 /var/www/ariang
```
### Step 4: Configure Nginx
```Bash
nano /etc/nginx/sites-available/ariang
```
### Step 5: Add this to Config File
```bash
server {
    listen 8088;
    server_name _;

    root /var/www/ariang;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Step 6: Enable Site and Restart Nginx
```Bash
ln -s /etc/nginx/sites-available/ariang /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

## Open Web UI
`http://<LXC-IP>:8088`
<!-- 
https://getsamplefiles.com/download/mp4/sample-2.mp4 -->