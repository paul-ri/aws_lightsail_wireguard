#!/bin/bash

export WG_PKEY="${WG_PKEY}"
export SERVER_LINK_IPADDRESS="${SERVER_LINK_IPADDRESS}"
export LINK_NETMASK="${LINK_NETMASK}"
export NET_PORT="${NET_PORT}"
export PEER_ALLOWED_IPS="${PEER_ALLOWED_IPS}"
export PEER_KEY="${PEER_KEY}"


# get some system info
NET_IFACE=$(ls /sys/class/net/ | grep -Ev '^(wg[0-9]+|lo)$')


# Update and install
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq
DEBIAN_FRONTEND=noninteractive apt-get install -y linux-aws
DEBIAN_FRONTEND=noninteractive apt-get install -y linux-headers-aws
apt-get update -y
apt-get install -y wireguard


# Unbound setup
apt-get install unbound unbound-host -y
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
chown unbound:unbound /var/lib/unbound/root.hints


cat > /etc/unbound/unbound.conf <<EOF
server:
  num-threads: 4

  #Enable logs
  verbosity: 1

  #list of Root DNS Server
  root-hints: "/var/lib/unbound/root.hints"

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

sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl enable unbound
mkdir -p /etc/wireguard/helper
cat > /etc/wireguard/helper/add-nat-routing.sh << EOF
#!/bin/bash
# Track VPN connection
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Allow incoming VPN traffic on the listening port
iptables -A INPUT -p udp -m udp --dport $NET_PORT -m conntrack --ctstate NEW -j ACCEPT
# Allow both TCP and UDP recursive DNS traffic
iptables -A INPUT -s $SERVER_LINK_IPADDRESS/$LINK_NETMASK -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s $SERVER_LINK_IPADDRESS/$LINK_NETMASK -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
# Allow forwarding of packets that stay in the VPN tunnel
iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT

iptables -A FORWARD -i wg0 -j ACCEPT;
iptables -t nat -A POSTROUTING -o $NET_IFACE -j MASQUERADE
EOF

cat > /etc/wireguard/helper/remove-nat-routing.sh <<EOF
#!/bin/bash
iptables -D INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Allow incoming VPN traffic on the listening port
iptables -D INPUT -p udp -m udp --dport $NET_PORT -m conntrack --ctstate NEW -j ACCEPT
# Allow both TCP and UDP recursive DNS traffic
iptables -D INPUT -s $SERVER_LINK_IPADDRESS/$LINK_NETMASK -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -D INPUT -s $SERVER_LINK_IPADDRESS/$LINK_NETMASK -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
# Allow forwarding of packets that stay in the VPN tunnel
iptables -D FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT

iptables -D FORWARD -i wg0 -j ACCEPT;
iptables -t nat -D POSTROUTING -o $NET_IFACE -j MASQUERADE
EOF

chmod +x /etc/wireguard/helper/*




# Set up nat
# Conflicts with what is setup in Wireguard
#iptables -t nat -A POSTROUTING -s $SERVER_LINK_IPADDRESS/$LINK_NETMASK -o $NET_IFACE -j MASQUERADE

#iptables-save > /etc/iptables/rules.v4

# wireguard setup
cd /etc/wireguard

cat > wg0.conf <<EOF
[Interface]
PrivateKey = $WG_PKEY
Address = $SERVER_LINK_IPADDRESS/$LINK_NETMASK
ListenPort = $NET_PORT
SaveConfig = false

PostUp = /etc/wireguard/helper/add-nat-routing.sh
PostDown = /etc/wireguard/helper/remove-nat-routing.sh

[Peer]
PublicKey = $PEER_KEY
AllowedIPs = $PEER_ALLOWED_IPS
EOF

touch /etc/rc.local
chmod +x /etc/rc.local
echo 'modprobe wireguard' >> /etc/rc.local

# start wireguard service
sysctl -w net.ipv4.ip_forward=1
echo net.ipv4.ip_forward=1 > /etc/sysctl.conf
wg-quick up wg0
systemctl enable wg-quick@wg0

# Personal preferences
apt install fish fzf
chsh -s /usr/bin/fish ubuntu

init 6
