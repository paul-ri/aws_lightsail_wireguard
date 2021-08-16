#!/bin/bash
# Logs available in /var/log/cloud-init-output.log
set -x

export WG_PKEY="${WG_PKEY}"
export SERVER_LINK_IPADDRESS="${SERVER_LINK_IPADDRESS}"
export LINK_NETMASK="${LINK_NETMASK}"
export NET_PORT="${NET_PORT}"
export PEER_MDULAPTOP_ALLOWED_IPS="${PEER_MDULAPTOP_ALLOWED_IPS}"
export PEER_MDULAPTOP_KEY="${PEER_MDULAPTOP_KEY}"
export PEER_FAIRPHONE_ALLOWED_IPS="${PEER_FAIRPHONE_ALLOWED_IPS}"
export PEER_FAIRPHONE_KEY="${PEER_FAIRPHONE_KEY}"
export PEER_OPTIPLEX_ALLOWED_IPS="${PEER_OPTIPLEX_ALLOWED_IPS}"
export PEER_OPTIPLEX_KEY="${PEER_OPTIPLEX_KEY}"
export PEER_RASPBERRYPI_ALLOWED_IPS="${PEER_RASPBERRYPI_ALLOWED_IPS}"
export PEER_RASPBERRYPI_KEY="${PEER_RASPBERRYPI_KEY}"
export PEER_CHROMEBOOK_ALLOWED_IPS="${PEER_CHROMEBOOK_ALLOWED_IPS}"
export PEER_CHROMEBOOK_KEY="${PEER_CHROMEBOOK_KEY}"
# Set your own local DNS if there is one
export LOCAL_DNS=10.1.2.4

# get some system info
NET_IFACE=$(ls /sys/class/net/ | grep -Ev '^(wg[0-9]+|lo)$')


# Update and install
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
DEBIAN_FRONTEND=noninteractive apt-get install -y linux-aws
apt-get install -y wireguard qrencode
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent


# Unbound setup
apt-get install unbound unbound-host -y
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
chown -R unbound:unbound /var/lib/unbound

cat > /etc/unbound/unbound.conf <<EOF
server:
  num-threads: 4

  #Enable logs
  verbosity: 1

  #list of Root DNS Server
  root-hints: "/var/lib/unbound/root.hints"

#  forward-zone:
#    name: "."
#    forward-addr: $LOCAL_DNS


  # use the root server's key for DNSSEC
  auto-trust-anchor-file: "/var/lib/unbound/root.key"

  #Respond to DNS requests on all interfaces
  interface: 0.0.0.0
  max-udp-size: 3072

  #Authorized IPs to access the DNS Server
  access-control: 0.0.0.0/0                 refuse
  access-control: 127.0.0.1                 allow
  access-control: ${WG_NETWORK}/24         allow

  #not allowed to be returned for public internet  names
  private-address: ${WG_NETWORK}/24

  # Hide DNS Server info
  hide-identity: yes
  hide-version: yes

  #Limit DNS Fraud and use DNSSEC
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-referral-path: yes

  #Add an unwanted reply threshold to clean the cache and avoid when possible a DNS Poisoning
  unwanted-reply-threshold: 10000000

  #Have the validator print validation failures to the log.
  val-log-level: 1

  #Minimum lifetime of cache entries in seconds
  cache-min-ttl: 1800

  #Maximum lifetime of cached entries
  cache-max-ttl: 14400
  prefetch: yes
  prefetch-key: yes
EOF

sed -Ei "s/(127.0.0.1 localhost)/\1 $(hostname)/" /etc/hosts

systemctl disable systemd-resolved
systemctl stop systemd-resolved
systemctl enable unbound-resolvconf
systemctl enable unbound

# Firewall
systemctl enable --now iptables

# Wireguard setup
cd /etc/wireguard

cat > wg0.conf <<EOF
[Interface]
PrivateKey = $WG_PKEY
Address = $SERVER_LINK_IPADDRESS/$LINK_NETMASK
ListenPort = $NET_PORT
SaveConfig = true

# https://wiki.archlinux.org/title/WireGuard#Server_config
# Enable routing on the server for peers to get internet access
PreUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o $NET_IFACE -j MASQUERADE

PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o $NET_IFACE -j MASQUERADE
PostDown = sysctl -w net.ipv4.ip_forward=0

[Peer]
# MDU Laptop
PublicKey = $PEER_MDULAPTOP_KEY
AllowedIPs = $PEER_MDULAPTOP_ALLOWED_IPS

[Peer]
# Fairphone
PublicKey = $PEER_FAIRPHONE_KEY
AllowedIPs = $PEER_FAIRPHONE_ALLOWED_IPS

[Peer]
# Optiplex
PublicKey = $PEER_OPTIPLEX_KEY
AllowedIPs = $PEER_OPTIPLEX_ALLOWED_IPS,192.168.0.0/24

[Peer]
# Raspberry pi
PublicKey = $PEER_RASPBERRYPI_KEY
AllowedIPs = $PEER_RASPBERRYPI_ALLOWED_IPS,192.168.0.0/24

[Peer]
# Chromebook
PublicKey = $PEER_CHROMEBOOK_KEY
AllowedIPs = $PEER_CHROMEBOOK_ALLOWED_IPS
EOF

# Personal preferences
apt install -y fish fzf
chsh -s /usr/bin/fish ubuntu
mkdir -p /home/ubuntu/.config/fish
cat > /home/ubuntu/.config/fish/config.fish <<EOF
if status --is-interactive
    function fish_user_key_bindings
        fzf_key_bindings
    end
end
EOF
chown -R ubuntu:ubuntu /home/ubuntu/.config

# Start Wireguard service
systemctl enable --now wg-quick@wg0

init 6
