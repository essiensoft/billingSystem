# PHPNuxBill - MikroTik Container Deployment Guide

## Overview

This guide shows how to deploy PHPNuxBill directly on MikroTik routers using the built-in container feature. This is ideal for running the billing system on the same device as your hotspot/PPPoE server.

---

## Prerequisites

- MikroTik RouterOS v7.4+ with container support
- Sufficient storage (at least 500MB free)
- Internet connection to pull Docker image

---

## Quick Deployment

### 1. Configure Network Interface

```routeros
/interface veth
add address=172.16.1.2/24 gateway=172.16.1.1 gateway6="" name=pnb_network

/interface bridge
add name=container

/interface bridge port
add bridge=container interface=pnb_network

/ip address
add address=172.16.1.1/24 interface=container network=172.16.1.0
```

### 2. Configure NAT Rules

```routeros
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN src-address=172.16.1.2
add action=dst-nat chain=dstnat dst-port=88 protocol=tcp to-addresses=172.16.1.2 to-ports=80
```

**Note**: Port 88 is used to avoid conflicts with MikroTik's web interface on port 80.

### 3. Enable Container Logging

```routeros
/system logging
add topics=container
```

### 4. Configure Container Registry

```routeros
/container/config/set registry-url=https://registry-1.docker.io tmpdir=/dockerpull
```

### 5. Set Environment Variables

```routeros
/container envs
add key=DB_DATABASE name=PHPNuxBill value=pnbrad
add key=DB_PASSWORD name=PHPNuxBill value=YOUR_SECURE_PASSWORD_HERE
add key=DB_USERNAME name=PHPNuxBill value=pnb
add key=ROOT_PASSWORD name=PHPNuxBill value=YOUR_ROOT_PASSWORD_HERE
add key=TIME_ZONE name=PHPNuxBill value=Asia/Jakarta
add key=RADIUS_CLIENT name=PHPNuxBill value=0.0.0.0
add key=RADIUS_SECRET name=PHPNuxBill value=YOUR_RADIUS_SECRET_HERE
add key=RADIUS_LOG_AUTH name=PHPNuxBill value=no
```

**⚠️ IMPORTANT**: Change the default passwords!

### 6. Deploy Container

```routeros
/container
add cmd="/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" \
    envlist=PHPNuxBill \
    hostname=phpnuxbill \
    interface=pnb_network \
    logging=yes \
    start-on-boot=yes \
    remote-image=yourusername/phpnuxbill:latest
```

---

## Environment Variables Explained

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `DB_DATABASE` | Database name | `pnbrad` | Yes |
| `DB_USERNAME` | Database user | `pnb` | Yes |
| `DB_PASSWORD` | Database password | - | Yes |
| `ROOT_PASSWORD` | MySQL root password | - | Yes |
| `TIME_ZONE` | Server timezone | `UTC` | No |
| `RADIUS_CLIENT` | Radius client IP | `0.0.0.0` | No |
| `RADIUS_SECRET` | Radius shared secret | - | Yes (if using Radius) |
| `RADIUS_LOG_AUTH` | Enable Radius auth logging | `no` | No |

---

## Accessing PHPNuxBill

After deployment, access the application:

- **From LAN**: `http://ROUTER_IP:88`
- **From WAN** (if NAT configured): `http://PUBLIC_IP:88`

Default admin credentials (change immediately!):
- Username: `admin`
- Password: Check your installation

---

## MikroTik-Specific Configuration

### Storage Optimization

```routeros
# Use external USB drive for container storage
/container/config/set tmpdir=usb1/dockerpull
```

### Resource Limits

```routeros
/container
set [find where hostname=phpnuxbill] \
    cpu=2 \
    memory-limit=512M
```

### Auto-Start on Boot

```routeros
/container
set [find where hostname=phpnuxbill] start-on-boot=yes
```

---

## Monitoring

### Check Container Status

```routeros
/container print
```

### View Container Logs

```routeros
/log print where topics~"container"
```

### Monitor Resource Usage

```routeros
/container/shell phpnuxbill
top
```

---

## Integration with MikroTik Hotspot

### 1. Configure Radius in PHPNuxBill

1. Access PHPNuxBill web interface
2. Go to **Settings** → **Radius**
3. Set Radius secret (must match `RADIUS_SECRET`)

### 2. Configure MikroTik Hotspot

```routeros
/ip hotspot profile
set [find] use-radius=yes

/radius
add address=172.16.1.2 secret=YOUR_RADIUS_SECRET_HERE service=hotspot
```

### 3. Test Radius Connection

```routeros
/radius monitor [find]
```

---

## Troubleshooting

### Container Won't Start

```routeros
# Check container status
/container print detail

# View error logs
/log print where topics~"container"

# Restart container
/container stop [find where hostname=phpnuxbill]
/container start [find where hostname=phpnuxbill]
```

### Can't Access Web Interface

```routeros
# Check NAT rules
/ip firewall nat print

# Test connectivity from router
/tool fetch url=http://172.16.1.2:80

# Check if port 88 is open
/ip firewall filter print
```

### Database Connection Issues

```routeros
# Access container shell
/container/shell phpnuxbill

# Check MySQL status
mysql -u root -p -e "SHOW DATABASES;"
```

### Out of Storage

```routeros
# Check available space
/system resource print

# Use external storage
/container/config/set tmpdir=usb1/dockerpull
```

---

## Updating PHPNuxBill

### Method 1: Pull Latest Image

```routeros
# Stop container
/container stop [find where hostname=phpnuxbill]

# Remove old container
/container remove [find where hostname=phpnuxbill]

# Pull new image and recreate
/container
add cmd="/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" \
    envlist=PHPNuxBill \
    hostname=phpnuxbill \
    interface=pnb_network \
    logging=yes \
    start-on-boot=yes \
    remote-image=yourusername/phpnuxbill:latest
```

### Method 2: Specific Version

```routeros
remote-image=yourusername/phpnuxbill:1.0-secure
```

---

## Backup and Restore

### Backup Database

```routeros
/container/shell phpnuxbill
mysqldump -u root -p pnbrad > /backup/pnbrad_$(date +%Y%m%d).sql
```

### Restore Database

```routeros
/container/shell phpnuxbill
mysql -u root -p pnbrad < /backup/pnbrad_20231212.sql
```

---

## Security Best Practices

### 1. Change Default Passwords

```routeros
/container envs
set [find where key=DB_PASSWORD] value=NEW_SECURE_PASSWORD
set [find where key=ROOT_PASSWORD] value=NEW_ROOT_PASSWORD
set [find where key=RADIUS_SECRET] value=NEW_RADIUS_SECRET
```

### 2. Restrict Access

```routeros
# Allow only LAN access
/ip firewall filter
add action=drop chain=input dst-port=88 in-interface-list=WAN protocol=tcp
```

### 3. Enable HTTPS (Recommended)

Use a reverse proxy or configure SSL in the container.

---

## Performance Tuning

### For Low-End Routers

```routeros
/container
set [find where hostname=phpnuxbill] \
    cpu=1 \
    memory-limit=256M
```

### For High-Traffic Sites

```routeros
/container
set [find where hostname=phpnuxbill] \
    cpu=4 \
    memory-limit=1024M
```

---

## Complete Example Configuration

```routeros
# Network setup
/interface veth add address=172.16.1.2/24 gateway=172.16.1.1 name=pnb_network
/interface bridge add name=container
/interface bridge port add bridge=container interface=pnb_network
/ip address add address=172.16.1.1/24 interface=container network=172.16.1.0

# NAT rules
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN src-address=172.16.1.2
add action=dst-nat chain=dstnat dst-port=88 protocol=tcp to-addresses=172.16.1.2 to-ports=80

# Container config
/container/config/set registry-url=https://registry-1.docker.io tmpdir=/dockerpull
/system logging add topics=container

# Environment variables (CHANGE PASSWORDS!)
/container envs
add key=DB_DATABASE name=PHPNuxBill value=pnbrad
add key=DB_PASSWORD name=PHPNuxBill value=SecurePass123!
add key=DB_USERNAME name=PHPNuxBill value=pnb
add key=ROOT_PASSWORD name=PHPNuxBill value=RootPass456!
add key=TIME_ZONE name=PHPNuxBill value=Asia/Jakarta
add key=RADIUS_CLIENT name=PHPNuxBill value=0.0.0.0
add key=RADIUS_SECRET name=PHPNuxBill value=RadiusSecret789!
add key=RADIUS_LOG_AUTH name=PHPNuxBill value=no

# Deploy container
/container
add cmd="/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" \
    envlist=PHPNuxBill \
    hostname=phpnuxbill \
    interface=pnb_network \
    logging=yes \
    start-on-boot=yes \
    cpu=2 \
    memory-limit=512M \
    remote-image=yourusername/phpnuxbill:latest
```

---

## Support

For MikroTik-specific issues:
- Check MikroTik forums
- Review container logs
- Ensure RouterOS version supports containers

For PHPNuxBill issues:
- Check application logs in container
- Review security fixes documentation
- Test database connectivity

---

**Last Updated**: 2025-12-12  
**Compatible with**: MikroTik RouterOS 7.4+  
**Image**: yourusername/phpnuxbill:latest
