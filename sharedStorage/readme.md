# Proxmox Shared Storage Setup (LVM-Thin + LXC ACL Bind Mounts)

This document outlines the step-by-step process used to create a securely shared local directory across multiple unprivileged LXC containers on a Proxmox VE host using LVM-Thin, Ext4, and POSIX ACLs.

---

## Architecture Overview



* **Host Storage:** LVM-Thin pool (`pve/data`)
* **Host Mount Point:** `/mnt/shared` (Formatted as `ext4`)
* **Container Mount Point:** `/mnt/shared`
* **Permissions:** Managed via POSIX ACLs to seamlessly map unprivileged LXC UIDs (`100000` and `101010`) without opening the folder to `777` global permissions.

---

## Step-by-Step Implementation

### Step 1: Create a Safely-Sized Thin Volume
To avoid overcommitting disk space and risking a volume group crash, a stable **500 GB** volume was provisioned from the thin pool.

```bash
# Remove the overcommitted volume (if previously created)
lvremove pve/shared

# Create the properly sized thin volume
lvcreate -V300G -T pve/data -n shared
```

### Step 2: Format and Mount on the Proxmox Host
```bash
# Format the volume
mkfs.ext4 /dev/pve/shared

# Create the host mount directory
mkdir -p /mnt/shared

# Mount the volume immediately
mount /dev/pve/shared /mnt/shared
```

### Step 3: Configure Permanent Automounting (Host /etc/fstab)
```bash
echo '/dev/pve/shared /mnt/shared ext4 defaults 0 2' >> /etc/fstab
```

### Step 4: Configure Secure Permissions using POSIX ACLs
Instead of using unsafe chmod 777 permissions, POSIX Access Control Lists (ACLs) were deployed. This precisely maps full read/write/execute access to the unprivileged container's internal root (UID 100000) and system/application users (UIDs up to 101010).

```bash
# 1. Install ACL tools on the host
apt-get update && apt-get install acl -y

# 2. Reset host baseline permissions safely
chown root:root /mnt/shared
chmod 755 /mnt/shared

# 3. Apply active ACL permissions for LXC users
setfacl -R -m u:100000:rwx,g:100000:rwx /mnt/shared
setfacl -R -m u:101010:rwx,g:101010:rwx /mnt/shared

# 4. Set default ACLs so newly created files inherit the correct permissions
setfacl -R -d -m u:100000:rwx,g:100000:rwx /mnt/shared
setfacl -R -d -m u:101010:rwx,g:101010:rwx /mnt/shared
```

### Check Host Permissions
```bash
getfacl /mnt/shared
```
Expected output includes user:100000:rwx, user:101010:rwx, and corresponding default: blocks.

### Check Inside the Container
```bash
df -h /mnt/shared
```

### Step 5: Map Storage to LXC Containers (Bind Mount)
```bash
pct set xxx -mp0 /mnt/shared,mp=/mnt/shared
```


## If want to move data from another mount point

### Step 1: Stop the Container
```bash
pct stop ctid
```

### Step 2: Sync the Data Across
```bash
rsync -avzP /mnt/shareddata/ /mnt/shared/
```

### Step 3: Fix ACL Permissions on the New Copy
```bash
setfacl -R -m u:100000:rwx,g:100000:rwx /mnt/shared
setfacl -R -m u:101010:rwx,g:101010:rwx /mnt/shared
setfacl -R -d -m u:100000:rwx,g:100000:rwx /mnt/shared
setfacl -R -d -m u:101010:rwx,g:101010:rwx /mnt/shared
```

### Step 4: Swap out Mount Points in Proxmox
### NOTE: Remove the last mount point 
```bash
nano /etc/pve/lxc/<ctid>.conf
```
and remove 
```bash

```

and then set new mount point

```bash
pct set 102 -mp0 /mnt/shared,mp=/mnt/shareddata
```