echo -en "${GREEN}Enter device name: ${NC}"
read DEVICE_NAME
apt --yes install qrencode
qrencode -t utf8 < /etc/wireguard/clients/$DEVICE_NAME.conf
echo -e "${PURPLE}^^^ Scan this QR-code with WireGuard App ^^^${NC}"
