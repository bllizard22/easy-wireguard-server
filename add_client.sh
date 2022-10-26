#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

### Ask for a device name and check
### if config can be outputted as QR-code
echo -en "${GREEN}Enter device name: ${NC}"
read DEVICE_NAME
echo -en "${GREEN}Is QR-code suitable for output [y/n]? ${NC}"
read IS_QRCODE

### Create client keys
mkdir /etc/wireguard/clients
wg genkey | sudo tee /etc/wireguard/clients/$DEVICE_NAME.key | wg pubkey | sudo tee /etc/wireguard/clients/$DEVICE_NAME.key.pub

### Get constants for further actions 
SERVER_PUBLIC=$(</etc/wireguard/server_public.key)
IP_ADR=$(dig +short myip.opendns.com @resolver1.opendns.com)
line=$(grep -i "ListenPort" /etc//wireguard/wg0.conf)
IFS='= '; port=($line); unset IFS; IP_PORT="$IP_ADR:${port[1]}"
DEVICE_PUBLIC=$(</etc/wireguard/clients/$DEVICE_NAME.key.pub)
DEVICE_PRIVATE=$(</etc/wireguard/clients/$DEVICE_NAME.key)
line=$( grep "Address" /etc/wireguard/wg0.conf | cut -d ' ' -f3 )
IFS='.'; SERVER_PRIVATE_IP_OCTETS=($line); unset IFS;
SERVER_PRIVATE_IP_PREFIX="${SERVER_PRIVATE_IP_OCTETS[0]}.${SERVER_PRIVATE_IP_OCTETS[1]}.${SERVER_PRIVATE_IP_OCTETS[2]}"
line=$( tail -n 1 /etc/wireguard/wg0.conf )
IFS='.'; last_ips=($line); unset IFS;
last_ip=${last_ips[3]}; NEXT_IP=$((last_ip+=2))
echo "Server public - $SERVER_PUBLIC
Device public - $DEVICE_PUBLIC
Device private - $DEVICE_PRIVATE
Server - $IP_PORT; Next allowed IP - $SERVER_PRIVATE_IP_PREFIX.$NEXT_IP"

### Create client config
touch /etc/wireguard/clients/$DEVICE_NAME.conf
echo "[Interface]
PrivateKey = $DEVICE_PRIVATE
Address = $SERVER_PRIVATE_IP_PREFIX.$NEXT_IP
DNS = 1.1.1.1, 8.8.8.8, 9.9.9.9, 76.76.19.19, 94.140.14.14, 208.67.222.222

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $IP_PORT
AllowedIPs = 0.0.0.0/0
" > /etc/wireguard/clients/$DEVICE_NAME.conf
### We DON"T tunnel private addresses through this VPN connection, needed for simultaneous connections to other VPN servers.

### Add client info in server config
echo "
[Peer]
### $DEVICE_NAME
PublicKey = $DEVICE_PUBLIC
AllowedIPs = $SERVER_PRIVATE_IP_PREFIX.$NEXT_IP" >> /etc/wireguard/wg0.conf

### Restart WireGuard server
wg-quick down wg0
wg-quick up wg0
wg

### Print output data
if [[ $IS_QRCODE == "y" ]];
then
	apt --yes install qrencode
	qrencode -t utf8 < /etc/wireguard/clients/$DEVICE_NAME.conf
	echo -e "${PURPLE}^^^ Scan this QR-code with WireGuard App ^^^${NC}"
else 
	echo -e "${GREEN}Config for client:
${PURPLE}$(</etc/wireguard/clients/$DEVICE_NAME.conf)${NC}"
fi
