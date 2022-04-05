#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

### Ask for a device name and check
### if config can be outputted as QR-code
echo -en "${GREEN}Choose port for VPN: [1-65535 or 0 for random value]${NC}"
read input
if [ $input == "0" ];
then
	PORT=$[ $RANDOM * 2 ]
else
	PORT=$input
fi
echo -en "${GREEN}Enter your SSH port: ${NC}"
read SSH_PORT

### Install WireGuard and Firewall
apt update
apt --yes install wireguard
apt --yes install ufw
mkdir /etc/wireguard

### Generate server keys
wg genkey | sudo tee /etc/wireguard/server_private.key
chmod go= /etc/wireguard/server_private.key
cat /etc/wireguard/server_private.key | wg pubkey | sudo tee /etc/wireguard/server_public.key
SERVER_PRIVATE=$(</etc/wireguard/server_private.key)
NETWORK_DEVICE=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1{split($2,a," ");print a[1]}')

touch /etc/wireguard/wg0.conf
echo "[Interface]
PrivateKey = $SERVER_PRIVATE
Address = 10.18.0.1
ListenPort = $PORT
SaveConfig = false

PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE" > /etc/wireguard/wg0.conf

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

sysctl -p
ufw allow $PORT/udp
ufw allow $SSH_PORT/tcp
ufw disable
ufw --force enable
ufw status

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
systemctl status --no-pager -l wg-quick@wg0.service

echo -e "${PURPLE}Done! Now you can run${GREEN}
./add_client.sh
${PURPLE}This will generate configuration for a new client${NC}"
