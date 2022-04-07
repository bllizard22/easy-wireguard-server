#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -en "${RED}This script will remove WireGuard server from this machine.
Are you sure? [Y/n]${NC}"
read FLAG

if [ $FLAG == "Y" ];
then
	wg-quick down wg0
	apt --yes remove wireguard
	rm -r /etc/wireguard
	echo -e "${GREEN}Done!${NC}"
else
	echo -e "${GREEN}Aborted${NC}"
fi
