#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

### Ask for a device name and check
### if config can be outputted as QR-code
echo -en "${GREEN}Enter device name: ${NC}"
read DEVICE_NAME
echo -n "${GREEN}Is QR-code suitable for output? [y/n]${NC}"
read IS_QRCODE

### Create client keys
mkdir /etc/wireguard/clients
wg genkey | sudo tee /etc/wireguard/clients/$DEVICE_NAME.key | wg pubkey | sudo tee /etc/wireguard/clients/$DEVICE_NAME.key.pub

### Get constants for further actions 
SERVER_PUBLIC=$(</etc/wireguard/server_public.key)
IP_ADR=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
line=$(grep -i "ListenPort" ~/desktop/wireguard/wg0.conf)
IFS='= '; port=($line); unset IFS; IP_PORT="$IP_ADR:${port[1]}"
DEVICE_PUBLIC=$(</etc/wireguard/clients/$DEVICE_NAME.key.pub)
DEVICE_PRIVATE=$(</etc/wireguard/clients/$DEVICE_NAME.key)
line=$( tail -n 1 /etc/wireguard/wg0.conf )
IFS='.'; last_ips=($line); unset IFS;
last_ip=${last_ips[3]}; NEXT_IP=$((last_ip+=1))
echo "Server public - $SERVER_PUBLIC"
echo "Server IP:Port - $IP_PORT"
echo "Device public - $DEVICE_PUBLIC"
echo "Device private - $DEVICE_PRIVATE"
echo "Next allowed IP - $NEXT_IP"

### Create client config
touch /etc/wireguard/clients/$DEVICE_NAME.conf
echo "[Interface]
PrivateKey = $DEVICE_PRIVATE
Address = 10.18.0.2/32
DNS = 8.8.8.8, 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $IP_PORT
AllowedIPs = 0.0.0.0/0" > /etc/wireguard/clients/$DEVICE_NAME.conf

### Add client info in server config
echo "
[Peer]
### $DEVICE_NAME
PublicKey = $DEVICE_PUBLIC
AllowedIPs = 10.18.0.$NEXT_IP" >> /etc/wireguard/wg0.conf

### Restart WireGuard server
wg-quick down wg0
wg-quick up wg0
wg

### Print output data
if [ $IS_QRCODE == "y" ];
then
	apt --yes install qrencode
	qrencode -t utf8 < /etc/wireguard/clients/$DEVICE_NAME.conf
else 
	echo -e "${GREEN}Config for client:
${PURPLE}$(</etc/wireguard/clients/$DEVICE_NAME.conf)${NC}"
fi
