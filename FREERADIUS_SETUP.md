# FreeRADIUS Setup for PHPNuxBill

This guide covers the FreeRADIUS integration with PHPNuxBill in the Docker production environment.

## Overview

FreeRADIUS provides AAA (Authentication, Authorization, Accounting) services for network access servers (NAS) like MikroTik routers.

## Docker Setup (Automatic)

The `docker-compose.production.yml` includes a pre-configured FreeRADIUS container.

### Start the Stack

```bash
docker-compose -f docker-compose.production.yml up -d
```

### Verify FreeRADIUS is Running

```bash
# Check container status
docker ps | grep phpnuxbill-freeradius

# View logs (debug mode enabled by default)
docker logs phpnuxbill-freeradius 2>&1 | tail -50
```

## Configuration Files

All configuration files are in the `freeradius/` directory:

| File | Purpose |
|------|---------|
| `mods-available/sql` | MySQL connection settings |
| `mods-available/sqlcounter` | Session/data limit counters |
| `sites-available/default` | Authorization and accounting rules |
| `clients.conf` | NAS client definitions |
| `mods-config/sql/counter/mysql/` | Counter query configurations |

## Updating Database Credentials

Edit `freeradius/mods-available/sql`:

```text
server = "mysql"
port = 3306
login = "your_db_user"
password = "your_db_password"
radius_db = "phpnuxbill"
```

## Adding NAS Clients

### Option 1: PHPNuxBill Admin Panel (Recommended)
1. Go to **Network → Routers**
2. Add a router with type **Radius**
3. Enter the NAS IP, port, and secret

### Option 2: Edit clients.conf
```text
client my-mikrotik {
    ipaddr = 192.168.1.1
    secret = YourRadiusSecret
    shortname = mikrotik-main
    nas_type = mikrotik
}
```

Then restart FreeRADIUS:
```bash
docker-compose -f docker-compose.production.yml restart freeradius
```

## Testing Authentication

```bash
# From host machine (if radtest is installed)
radtest testuser testpass localhost 0 testing123

# From within FreeRADIUS container
docker exec -it phpnuxbill-freeradius radtest testuser testpass 127.0.0.1 0 testing123
```

Expected output:
```
Sent Access-Request Id 0 ...
Received Access-Accept Id 0 ...
```

## MikroTik Router Configuration

On your MikroTik router:

```routeros
# Add RADIUS server
/radius
add address=YOUR_SERVER_IP secret=YourRadiusSecret service=hotspot,ppp

# Enable RADIUS authentication for hotspot
/ip hotspot profile
set [find] use-radius=yes

# Enable RADIUS for PPPoE
/ppp aaa
set use-radius=yes

# Enable RADIUS logging (optional)
/system logging
add topics=radius,debug action=memory
```

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 1812 | UDP | Authentication |
| 1813 | UDP | Accounting |
| 3799 | UDP | CoA/Disconnect |

## Firewall Rules

Ensure these UDP ports are open on your server firewall:

```bash
# UFW (Ubuntu)
ufw allow 1812/udp
ufw allow 1813/udp
ufw allow 3799/udp

# firewalld (CentOS/RHEL)
firewall-cmd --permanent --add-port=1812/udp
firewall-cmd --permanent --add-port=1813/udp
firewall-cmd --permanent --add-port=3799/udp
firewall-cmd --reload
```

## Troubleshooting

### Check FreeRADIUS Logs
```bash
docker logs phpnuxbill-freeradius 2>&1 | grep -i error
```

### Test Database Connection
```bash
docker exec -it phpnuxbill-freeradius \
  mysql -h mysql -u phpnuxbill_user -pChangeThisPassword phpnuxbill -e "SELECT * FROM nas LIMIT 1;"
```

### Verify RADIUS Tables Exist
```bash
docker exec -it phpnuxbill-mysql mysql -u root -p -e "USE phpnuxbill; SHOW TABLES LIKE 'rad%';"
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "Connection refused" | Check MySQL is running and credentials are correct |
| "Unknown user" | Verify user exists in `radcheck` table |
| "Access-Reject" | Check password and user plan status |
| Container keeps restarting | Check logs for configuration syntax errors |

## Production Mode

To reduce logging in production, edit `docker-compose.production.yml`:

```yaml
command: ["freeradius"]  # Remove the -X flag
```
