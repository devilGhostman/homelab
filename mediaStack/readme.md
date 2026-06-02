# Media Stack

### NOTE IPTV source : https://iptv-org.github.io/

### Step 1: Create folder  
```bash
mkdir -p /opt/media-stack
cd /opt/media-stack

mkdir jellyfin
mkdir seerr
```

### Create docker-compose.yml
```bash
nano docker-compose.yml
```

```yaml
services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    ports:
      - "8096:8096"
    volumes:
      - ./jellyfin/config:/config
      - ./jellyfin/cache:/cache
      - /mnt/storage/jellyfin:/media
    restart: unless-stopped

  seerr:
    image: ghcr.io/seerr-team/seerr:latest
    container_name: seerr
    ports:
      - "5055:5055"
    environment:
      - TZ=Asia/Kolkata
    volumes:
      - ./seerr:/app/config
    restart: unless-stopped
```

## Open Web UI
Jellyfin `http://<LXC-IP>:8086`
Overseerr `http://<LXC-IP>:5055`