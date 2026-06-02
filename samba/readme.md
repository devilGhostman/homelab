## Samba 

### Step 1: Update and Install Samba
```bash
apt update
apt install -y samba
```

### Step 2: Edit Config
```bash
nano /etc/samba/smb.conf
```

### Step 3: Add this at bottom
```bash
[Storage]
   path = /mnt/storage
   browseable = yes
   read only = no
   guest ok = yes
   create mask = 0775
   directory mask = 0775
```

### Step 4: Restart Samaba
```bash
systemctl restart smbd
```

```bash
systemctl start smbd
systemctl start nmbd
```

Access the Samba at: `smb://<YOUR-LXC-IP>/Storage`

---