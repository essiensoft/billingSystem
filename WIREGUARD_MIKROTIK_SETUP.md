# WireGuard VPN Setup Guide: VPS to MikroTik

This guide shows you how to set up a WireGuard VPN tunnel between your VPS (72.60.188.171) and MikroTik router to solve the dynamic WAN IP problem for RADIUS authentication.

## Overview

```
[MikroTik Router]                    [VPS Server]
Dynamic WAN IP    --WireGuard-->     72.60.188.171
                    Tunnel
VPN IP: 10.0.0.2                     VPN IP: 10.0.0.1
                                     
                                     FreeRADIUS: 10.0.0.1:1812
```

**Benefits:**
- ✅ MikroTik gets a static VPN IP (10.0.0.2)
- ✅ No more dynamic IP issues
- ✅ Encrypted secure tunnel
- ✅ Auto-reconnects if connection drops
- ✅ Better security for RADIUS traffic

---

## Part 1: VPS Server Setup (WireGuard Server)

### Step 1: Install WireGuard on VPS

SSH into your VPS and run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install WireGuard
sudo apt install wireguard -y

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

### Step 2: Generate Server Keys

```bash
# Create WireGuard directory
sudo mkdir -p /etc/wireguard

# Generate server private and public keys
wg genkey | sudo tee /etc/wireguard/server_private.key
sudo cat /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key

# Set proper permissions
sudo chmod 600 /etc/wireguard/server_private.key

# Display keys (save these!)
echo "Server Private Key:" aA3LFQVdW89c2b+wbENPwtjbV7H7bWykGdloJzj901U=
sudo cat /etc/wireguard/server_private.key
echo ""
echo "Server Public Key:" Xn846okGCMy6Dlq+rFGkbtKwUS6w582bIad9qOq8Inw=
sudo cat /etc/wireguard/server_public.key
```

**IMPORTANT:** Save both keys somewhere safe! You'll need them.

### Step 3: Create WireGuard Configuration

```bash
sudo nano /etc/wireguard/wg0.conf
```

Paste this configuration (replace `<SERVER_PRIVATE_KEY>` with your actual key):

```ini
[Interface]
# VPS WireGuard interface
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>

# Post-up and post-down scripts for NAT (if needed)
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# MikroTik Router
PublicKey = <MIKROTIK_PUBLIC_KEY_WILL_BE_ADDED_LATER>
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 25
```

**Note:** We'll add the MikroTik public key later.

Save and exit (Ctrl+X, Y, Enter).

### Step 4: Configure VPS Firewall

```bash
# Allow WireGuard port
sudo ufw allow 51820/udp comment 'WireGuard VPN'

# Allow traffic from WireGuard subnet to RADIUS ports
sudo ufw allow from 10.0.0.0/24 to any port 1812 proto udp comment 'RADIUS Auth from VPN'
sudo ufw allow from 10.0.0.0/24 to any port 1813 proto udp comment 'RADIUS Acct from VPN'
sudo ufw allow from 10.0.0.0/24 to any port 3799 proto udp comment 'RADIUS CoA from VPN'

# Reload firewall
sudo ufw reload

# Check status
sudo ufw status numbered
```

---

## Part 2: MikroTik Router Setup (WireGuard Client)

### Step 1: Generate MikroTik Keys

Connect to your MikroTik (Winbox or SSH) and run:

```bash
# Generate WireGuard keys
/interface/wireguard/keys/generate

# Display the keys
/interface/wireguard/keys/print
```

**Output will show:**
```
private-key: <MIKROTIK_PRIVATE_KEY>
public-key: <MIKROTIK_PUBLIC_KEY>
```

**IMPORTANT:** Copy the `public-key` - you'll need to add it to the VPS config!

### Step 2: Create WireGuard Interface on MikroTik

```bash
# Create WireGuard interface
/interface/wireguard
add name=wg-to-vps listen-port=51820 private-key="<MIKROTIK_PRIVATE_KEY>"

# Verify it was created
/interface/wireguard print
```

### Step 3: Add VPS as Peer

Replace `<VPS_PUBLIC_KEY>` with the server public key from Part 1, Step 2:

```bash
# Add VPS as peer
/interface/wireguard/peers
add interface=wg-to-vps \
    public-key="<VPS_PUBLIC_KEY>" \
    endpoint-address=72.60.188.171 \
    endpoint-port=51820 \
    allowed-address=10.0.0.0/24 \
    persistent-keepalive=25s

# Verify peer was added
/interface/wireguard/peers print
```

### Step 4: Assign IP Address to WireGuard Interface

```bash
# Add IP address to WireGuard interface
/ip/address
add address=10.0.0.2/24 interface=wg-to-vps

# Verify
/ip/address print where interface=wg-to-vps
```

### Step 5: Add Route to VPS via WireGuard (Optional)

If you want to route specific traffic through the VPN:

```bash
# Add route to VPS subnet
/ip/route
add dst-address=10.0.0.0/24 gateway=wg-to-vps

# Verify
/ip/route print where gateway=wg-to-vps
```

### Step 6: Configure MikroTik Firewall

```bash
# Allow WireGuard traffic
/ip/firewall/filter
add chain=input action=accept protocol=udp dst-port=51820 comment="Allow WireGuard"

# Allow established/related connections from WireGuard
add chain=input action=accept connection-state=established,related in-interface=wg-to-vps comment="Allow WireGuard established"

# Allow traffic to VPS through WireGuard
add chain=forward action=accept out-interface=wg-to-vps comment="Allow traffic to VPS via WireGuard"
add chain=forward action=accept in-interface=wg-to-vps comment="Allow traffic from VPS via WireGuard"

# Verify firewall rules
/ip/firewall/filter print where comment~"WireGuard"
```

---

## Part 3: Complete the VPS Configuration

### Step 1: Add MikroTik Public Key to VPS

Now that you have the MikroTik public key, add it to the VPS config:

```bash
# Edit WireGuard config
sudo nano /etc/wireguard/wg0.conf
```

Replace `<MIKROTIK_PUBLIC_KEY_WILL_BE_ADDED_LATER>` with your actual MikroTik public key.

**Final config should look like:**
```ini
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
# MikroTik Router
PublicKey = <ACTUAL_MIKROTIK_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
PersistentKeepalive = 25
```

Save and exit.

### Step 2: Start WireGuard on VPS

```bash
# Start WireGuard
sudo wg-quick up wg0

# Enable on boot
sudo systemctl enable wg-quick@wg0

# Check status
sudo wg show
```

**Expected output:**
```
interface: wg0
  public key: <VPS_PUBLIC_KEY>
  private key: (hidden)
  listening port: 51820

peer: <MIKROTIK_PUBLIC_KEY>
  endpoint: <MIKROTIK_WAN_IP>:51820
  allowed ips: 10.0.0.2/32
  latest handshake: X seconds ago
  transfer: X KiB received, X KiB sent
  persistent keepalive: every 25 seconds
```

---

## Part 4: Test the VPN Connection

### Test 1: Ping from MikroTik to VPS

On MikroTik:
```bash
/ping 10.0.0.1 count=5
```

**Expected:** Should get replies from 10.0.0.1

### Test 2: Ping from VPS to MikroTik

On VPS:
```bash
ping 10.0.0.2 -c 5
```

**Expected:** Should get replies from 10.0.0.2

### Test 3: Check WireGuard Status

**On VPS:**
```bash
sudo wg show
```

**On MikroTik:**
```bash
/interface/wireguard/peers print
```

Look for:
- `latest-handshake` should be recent (< 2 minutes ago)
- `current-endpoint-address` should show your VPS IP
- `tx` and `rx` should show data transfer

---

## Part 5: Configure RADIUS to Use WireGuard

### Step 1: Update MikroTik RADIUS Configuration

Change RADIUS server address to use the VPN IP:

```bash
# Update existing RADIUS server
/radius set 0 address=10.0.0.1

# Or add new RADIUS server via VPN
/radius add \
  address=10.0.0.1 \
  secret=e1687f67080faac7483847a38b9a048d \
  service=hotspot,login \
  authentication-port=1812 \
  accounting-port=1813

# Verify
/radius print detail
```

### Step 2: Update FreeRADIUS Configuration (Optional)

For better security, restrict RADIUS to only accept from VPN IP.

In **Portainer**, update your stack environment variables:

```bash
RADIUS_CLIENT=10.0.0.2/32
```

Then restart the FreeRADIUS container.

Or keep it as `0.0.0.0/0` to allow both VPN and direct connections.

### Step 3: Test RADIUS Authentication

```bash
# On MikroTik, monitor RADIUS
/radius incoming monitor

# Try to authenticate a user through hotspot
# You should see requests going through
```

**In Portainer**, check FreeRADIUS logs:
```
Received Access-Request from 10.0.0.2:XXXXX
```

---

## Troubleshooting

### Issue 1: No Handshake Between Peers

**Symptoms:**
- `latest-handshake` shows "never" or very old
- Can't ping across tunnel

**Solutions:**

1. **Check firewall on VPS:**
   ```bash
   sudo ufw status | grep 51820
   ```

2. **Check MikroTik can reach VPS:**
   ```bash
   /ping 72.60.188.171
   ```

3. **Verify keys match:**
   - VPS config has MikroTik's public key
   - MikroTik peer has VPS's public key

4. **Check WireGuard is running on VPS:**
   ```bash
   sudo systemctl status wg-quick@wg0
   ```

### Issue 2: Tunnel Connects but Can't Ping

**Symptoms:**
- Handshake successful
- Can't ping 10.0.0.1 or 10.0.0.2

**Solutions:**

1. **Check IP forwarding on VPS:**
   ```bash
   sudo sysctl net.ipv4.ip_forward
   # Should return: net.ipv4.ip_forward = 1
   ```

2. **Check allowed IPs:**
   - VPS config: `AllowedIPs = 10.0.0.2/32`
   - MikroTik peer: `allowed-address=10.0.0.0/24`

3. **Check routes on MikroTik:**
   ```bash
   /ip/route print where gateway=wg-to-vps
   ```

### Issue 3: RADIUS Not Working Through VPN

**Symptoms:**
- VPN tunnel works
- RADIUS authentication fails

**Solutions:**

1. **Verify RADIUS address on MikroTik:**
   ```bash
   /radius print detail
   # Should show: address=10.0.0.1
   ```

2. **Check FreeRADIUS is listening on VPN interface:**
   ```bash
   # On VPS
   docker exec phpnuxbill-freeradius netstat -ulnp | grep 1812
   ```

3. **Check firewall allows RADIUS from VPN:**
   ```bash
   sudo ufw status | grep 1812
   ```

4. **Test RADIUS manually:**
   ```bash
   # On VPS
   docker exec phpnuxbill-freeradius radtest testuser testpass 10.0.0.1 0 e1687f67080faac7483847a38b9a048d
   ```

### Issue 4: VPN Disconnects Frequently

**Symptoms:**
- Tunnel drops connection
- Handshake times out

**Solutions:**

1. **Increase keepalive interval:**
   ```bash
   # On MikroTik
   /interface/wireguard/peers set 0 persistent-keepalive=15s
   ```

2. **Check for NAT timeout issues:**
   - Some ISPs timeout UDP connections
   - Lower keepalive helps maintain connection

3. **Check VPS load:**
   ```bash
   top
   # High CPU/memory might cause issues
   ```

---

## Security Best Practices

### 1. Restrict RADIUS to VPN Only

Update Portainer environment:
```bash
RADIUS_CLIENT=10.0.0.2/32
```

### 2. Use Strong Keys

- Never share your private keys
- Regenerate keys if compromised
- Store keys securely

### 3. Firewall Rules

**On VPS:**
```bash
# Only allow WireGuard from known IPs (optional)
sudo ufw allow from <MIKROTIK_WAN_IP> to any port 51820 proto udp
```

**On MikroTik:**
```bash
# Drop all other WireGuard traffic
/ip/firewall/filter
add chain=input action=drop protocol=udp dst-port=51820 comment="Drop unknown WireGuard"
```

### 4. Monitor Connection

**On VPS:**
```bash
# Check active connections
sudo wg show

# Monitor logs
sudo journalctl -u wg-quick@wg0 -f
```

**On MikroTik:**
```bash
# Monitor WireGuard
/interface/wireguard/peers monitor 0

# Check logs
/log print where topics~"wireguard"
```

---

## Maintenance Commands

### Restart WireGuard

**On VPS:**
```bash
sudo wg-quick down wg0
sudo wg-quick up wg0
```

**On MikroTik:**
```bash
/interface/wireguard disable wg-to-vps
/interface/wireguard enable wg-to-vps
```

### View Connection Stats

**On VPS:**
```bash
sudo wg show wg0
```

**On MikroTik:**
```bash
/interface/wireguard/peers print stats
```

### Update Configuration

**On VPS:**
```bash
# Edit config
sudo nano /etc/wireguard/wg0.conf

# Restart
sudo wg-quick down wg0
sudo wg-quick up wg0
```

---

## Quick Reference

### Network Topology
```
VPS WireGuard IP:      10.0.0.1/24
MikroTik WireGuard IP: 10.0.0.2/24
WireGuard Port:        51820/udp
RADIUS via VPN:        10.0.0.1:1812
```

### Important Files

**VPS:**
- Config: `/etc/wireguard/wg0.conf`
- Private Key: `/etc/wireguard/server_private.key`
- Public Key: `/etc/wireguard/server_public.key`

**MikroTik:**
- Interface: `wg-to-vps`
- Keys stored in: `/interface/wireguard/keys`

### Useful Commands

**VPS:**
```bash
sudo wg show                    # Show status
sudo wg-quick up wg0           # Start
sudo wg-quick down wg0         # Stop
sudo systemctl status wg-quick@wg0  # Check service
```

**MikroTik:**
```bash
/interface/wireguard print                  # Show interfaces
/interface/wireguard/peers print           # Show peers
/interface/wireguard/peers monitor 0       # Monitor connection
/ping 10.0.0.1                            # Test connectivity
```

---

## Next Steps

After WireGuard is working:

1. ✅ Test RADIUS authentication through VPN
2. ✅ Update PHPNuxBill router management to use 10.0.0.2
3. ✅ Monitor VPN stability for 24 hours
4. ✅ Set up monitoring/alerts for VPN status
5. ✅ Document your specific configuration

---

## Benefits Achieved

✅ **Static IP**: MikroTik always connects from 10.0.0.2  
✅ **No Dynamic IP Issues**: WAN IP can change freely  
✅ **Secure**: All RADIUS traffic encrypted  
✅ **Reliable**: Auto-reconnects on connection loss  
✅ **Better Management**: PHPNuxBill can manage MikroTik via VPN  
✅ **Future-Proof**: Easy to add more MikroTik routers  

---

## Support

For issues:
1. Check WireGuard logs on both sides
2. Verify firewall rules
3. Test basic connectivity (ping)
4. Check RADIUS logs in Portainer
5. Refer to troubleshooting section above
