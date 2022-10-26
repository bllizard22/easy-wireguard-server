#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

### Ask for a device name and check
### if config can be outputted as QR-code
echo -en "${GREEN}Choose port for VPN, 1-65535, leave blank for random: ${NC}"
read input_VPN_PORT
if [[ $input == "" ]];
then
	PORT=$[ $RANDOM * 2 ]
else
	PORT=$input_VPN_PORT
fi

echo -en "${GREEN}Enter your SSH port, leave blank for default [22]: ${NC}"
read input_SSH_PORT
if [[ $input_SSH_PORT == "" ]];
then
	SSH_PORT="22"
else
	SSH_PORT=$input_SSH_PORT
fi

SERVER_PRIVATE_IP="10.18.0.1"

### Install WireGuard and Firewall
apt update
apt --yes install wireguard
apt --yes install ufw
apt --yes install dnsutils
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
Address = $SERVER_PRIVATE_IP
ListenPort = $PORT
SaveConfig = false

PostUp = ufw route allow in on wg0 out on $NETWORK_DEVICE
PostUp = iptables -t nat -I POSTROUTING -o $NETWORK_DEVICE -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on $NETWORK_DEVICE
PreDown = iptables -t nat -D POSTROUTING -o $NETWORK_DEVICE -j MASQUERADE" > /etc/wireguard/wg0.conf

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

echo -en "${PURPLE}Done! Now you need to add a few peers.
Would you like to do it now [y/n]? "
read NEED_CLIENT
if [[ $NEED_CLIENT == "y" || $NEED_CLIENT == "" ]];
then
	./easy_wireguard/add_client.sh
else 
	echo "You can add peers later by running${GREEN} ./easy_wireguard/add_client.sh ${NC}manually."
fi
