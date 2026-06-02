# 📦 Self-Hosted Home Server Setup Guide

## 🛠️ Tech Stack & Architecture

* **Host OS:** Proxmox VE (PVE)
* **Containerization:** Debian 12 LXC (Unprivileged with Nesting)
* **App Orchestration:** Docker & Docker Compose
* **Services:** 
   * **Immich:** High-performance self-hosted photo/video backup solution.
   * **Media-Stack: (Jellyfin, Seerr)**
   * **FileBrowser:** Lightweight web-based file manager.
   * **Samba**
   * **Aria2 and AriaNg**
   * **Paperless Ngx**

* **Storage:** Shared LVM disk mount.

---

## 🧱 1. Create the LXC Container

Deploy a new LXC container via the Proxmox VE web UI using the following recommended specifications:

### Recommended Hardware Resources
| Setting | Value | Notes |
| :--- | :--- | :--- |
| **OS Template** | Debian 12 | Standard minimal template |
| **Unprivileged** | Yes | Enhanced security boundary |
| **CPU** | 2–4 Cores | Scale based on your hardware |
| **RAM** | 6–8 GB | High RAM is recommended if utilizing ML features |
| **Root Disk** | 60–64 GB | For OS and container runtime data |

### ⚠️ Critical Features Configuration
Before starting the container, you **must** enable Nesting and Keyctl to allow Docker to run smoothly inside the unprivileged LXC.

1. Navigate to **Proxmox UI** → `[Your LXC ID]` → **Options** → **Features**.
2. Edit and check the boxes for:
   * [x] **Nesting**
   * [x] **Keyctl**

OR 

```bash
pct set <ctid> -features nesting=1,keyctl=1
```

---

## 🌐 2. Network Configuration

Assign a static IP to ensure your services remain accessible at a consistent address. Configure this in the LXC **Network** tab or during initial setup:

* **IPv4:** `192.168.1.50/24` *(Example)*
* **Gateway:** `192.168.1.1`
* **DNS Server:** `1.1.1.1`

## Upstream DNS Providers

| Provider         | IPv4 Addresses                     |
|------------------|------------------------------------|
| Google           | `8.8.8.8`, `8.8.4.4`              |
| Quad9            | `9.9.9.9`, `149.112.112.112`      |
| Cloudflare DNS   | `1.1.1.1`, `1.0.0.1`              |

---

## 🔄 3. Update the System

Start the container, log in via the console as `root`, and update the base OS packages:

```bash
apt update && apt upgrade -y
apt install -y curl nano sudo
```

---

## 🐳 4. Install Docker & Docker Compose

Run the official Docker convenience script and install the modern compose plugin:

```bash
# Install Docker Engine
curl -fsSL https://get.docker.com | sh

# Install Docker Compose Plugin
apt install -y docker-compose-plugin
```

### Verify Installation
Ensure both components are installed successfully:
```bash
docker --version
docker compose version
```

---

## NOTE: Follow sharedStorage readme.md first
## 💾 5. Storage Setup (Proxmox Host Mount)

To map physical storage or an LVM volume from your Proxmox host into the LXC container:

1. **On the Proxmox Host**, identify your target disk storage:
   ```bash
   lsblk
   ```
2. Open your container's configuration file on the host:
   ```bash
   nano /etc/pve/lxc/<CTID>.conf
   ```
3. Append the mount point definition (adjust paths as necessary):
   ```text
   mp0: /mnt/shared,mp=/mnt/shared
   ```
4. Restart the container from the host terminal to apply changes:
   ```bash
   pct restart <CTID>
   ```
5. **Inside the LXC container**, verify the storage is mounted correctly:
   ```bash
   df -h
   ```
   You should see your large storage partition mapped to `/mnt/storage`.

### Create Folder Directory Structure
```bash
mkdir -p /mnt/shared/{immich,files,jellyfin,backups}
```


## 📊 Final Directory Layout

Your shared storage directory tree will look like this once fully operational:

```text
/mnt/shared/
├── immich/       # Managed by Immich app for media backups
├── files/        # General file storage managed via FileBrowser
├── jellyfin/     # (Reserved for future media server deployment)
└── backups/      # Application and system database backups
```