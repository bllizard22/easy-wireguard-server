#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Downloading scripts...${NC}"

if ! [ -d "easy_wireguard" ]; then
    mkdir easy_wireguard
fi
cd easy_wireguard
if ! [ -f "setup_server.sh" ]; then
    curl -O https://raw.githubusercontent.com/bllizard22/easy-wireguard-server/main/setup_server.sh
	chmod +x setup_server.sh
fi
if ! [ -f "add_client.sh" ]; then
    curl -O https://raw.githubusercontent.com/bllizard22/easy-wireguard-server/main/add_client.sh
	chmod +x add_client.sh
fi
if ! [ -f "remove_server.sh" ]; then
	curl -O https://raw.githubusercontent.com/bllizard22/easy-wireguard-server/main/remove_server.sh
	chmod +x remove_server.sh
fi
cd ..

echo -en "${GREEN}Choose the action:
[1] - Setup server
[2] - Add new client (peer)
${RED}[3] - Remove server from this machine${GREEN}

[1/2/3]: ${NC}"
read OPTION

if [ $OPTION == "1" ]; then
	./easy_wireguard/setup_server.sh
elif [ $OPTION == "2" ]; then
	./easy_wireguard/add_client.sh
elif [ $OPTION == "3" ]; then
	./easy_wireguard/remove_server.sh
	rm -r ./easy_wireguard
else
	echo -e "${PURPLE}Exit without actions${NC}"
fi
