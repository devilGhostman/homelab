## Paperless NGX
``` 
Create unpriviliged LXC with nesting=1,keyctl=1
Mount storage From local-lvm for storage
Install docker and docker compose
```

### Step 1: Create folder for storage 
```bash
mkdir -p /mnt/shared/paperless/{consume,export,data,media,postgres,redis}
```

### Step 2: Create folder for paperless docker compose
```bash
mkdir -p /opt/paperless
cd /opt/paperless
```

### Create docker-compose.yml
```bash
nano docker-compose.yml
```

```yaml
services:
  broker:
    image: docker.io/library/redis:8
    restart: unless-stopped
    volumes:
      - /mnt/shared/paperless/redis:/data

  db:
    image: docker.io/library/postgres:17
    restart: unless-stopped
    volumes:
      - /mnt/shared/paperless/postgres:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: paperless
      POSTGRES_USER: paperless
      POSTGRES_PASSWORD: paperless

  webserver:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    restart: unless-stopped
    depends_on:
      - db
      - broker
      - gotenberg
      - tika
    ports:
      - "8000:8000"
    volumes:
      - /mnt/shared/paperless/data:/usr/src/paperless/data
      - /mnt/shared/paperless/media:/usr/src/paperless/media
      - /mnt/shared/paperless/export:/usr/src/paperless/export
      - /mnt/shared/paperless/consume:/usr/src/paperless/consume
    env_file: docker-compose.env
    environment:
      PAPERLESS_REDIS: redis://broker:6379
      PAPERLESS_DBHOST: db
      PAPERLESS_TIKA_ENABLED: 1
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT: http://gotenberg:3000
      PAPERLESS_TIKA_ENDPOINT: http://tika:9998

  gotenberg:
    image: docker.io/gotenberg/gotenberg:8.25
    restart: unless-stopped
    command:
      - "gotenberg"
      - "--chromium-disable-javascript=true"
      - "--chromium-allow-list=file:///tmp/.*"

  tika:
    image: docker.io/apache/tika:latest
    restart: unless-stopped
```

docker-compose.env
```
###############################################################################
# Paperless-ngx settings
###############################################################################

#USERMAP_UID=1000
#USERMAP_GID=1000

#PAPERLESS_URL=https://paperless.example.com

# REQUIRED: secret key (generate a long random string)
PAPERLESS_SECRET_KEY=change-me-to-a-long-random-string

# TIMEZONE (India)
PAPERLESS_TIME_ZONE=Asia/Kolkata

# OCR primary language
PAPERLESS_OCR_LANGUAGE=eng

# Additional OCR languages (English + Hindi)
PAPERLESS_OCR_LANGUAGES=hin

# Custom variables
PAPERLESS_FILENAME_FORMAT={{ correspondent }}/{{ created_year }}/{{ created_month_name_short }}/{{ title }}
PAPERLESS_CONSUMER_RECURSIVE=true
PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS=true
```

### NOTE : to generate random string
```bash
openssl rand -base64 64
```

### Step 3: Start Paperless
```bash
cd /opt/paperless
docker compose up -d
```

## Open Web UI
Paperless Ngx `http://<LXC-IP>:8000`