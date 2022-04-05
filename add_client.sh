#!/bin/bash


### Ask for a device name
echo -n "Enter device name: "
read DEVICE_NAME


### Check if config can be outputted as QR-code
echo -n "Is QR-code suitable for output? [y/n]"
read IS_QRCODE


### Create client keys
mkdir /etc/wireguard/clients
wg genkey | sudo tee /etc/wireguard/clients/$DEVICE_NAME.key | wg pubkey | sudo tee /etc/wireguard/clients/$DEVICE_NAME.key.pub


### Get constants for further actions 
SERVER_PUBLIC=$(</etc/wireguard/server_public.key)
echo "Server public - $SERVER_PUBLIC"

IP_ADR=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
LINE=$(grep -i "ListenPort" /etc/wireguard/wg0.conf)
PORT_LINE=(${LINE})
PORT=${PORT_LINE[2]}
echo "Server IP:Port - $IP_ADR:$PORT"

DEVICE_PUBLIC=$(</etc/wireguard/clients/$DEVICE_NAME.key.pub)
echo "Device public - $DEVICE_PUBLIC"
DEVICE_PRIVATE=$(</etc/wireguard/clients/$DEVICE_NAME.key)
echo "Device private - $DEVICE_PRIVATE"


### Create client config
touch /etc/wireguard/clients/$DEVICE_NAME.conf
echo "[Interface]
PrivateKey = $DEVICE_PRIVATE
Address = 10.18.0.2/32
DNS = 8.8.8.8, 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $IP_ADR:$PORT
AllowedIPs = 0.0.0.0/0" > /etc/wireguard/clients/$DEVICE_NAME.conf


### Add client info in server config
echo "
[Peer]
### $DEVICE_NAME
PublicKey = $DEVICE_PUBLIC
AllowedIPs = 10.18.0.2/32" >> /etc/wireguard/wg0.conf


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
	echo ""
	cat /etc/wireguard/clients/$DEVICE_NAME.conf
fi
