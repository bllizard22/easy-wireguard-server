# Easy WireGuard Server
Scripts for quickly setting up your WireGuard server.

## Setup curl
You can setup *curl* with

`apt --yes install curl`

## Setup server
Download and run script with:
```
curl -O https://raw.githubusercontent.com/bllizard22/easy-wireguard-server/main/easy_wireguard.sh
chmod +x easy_wireguard.sh
./easy_wireguard.sh
```

When prompted enter any number from 1 to 65535 for VPN connetion or 0 to assign random value.

`Choose port for VPN: [1-65535 or 0 for random value]`

And enter port number for SSH connection (if you use one).

`Enter your SSH port: `

After setup you can run `.add_client.sh` to generate new peer.

## Add new client
Download and run script with:
```
curl -O https://raw.githubusercontent.com/bllizard22/easy-wireguard-server/main/add_client.sh
chmod +x add_client.sh
./add_client.sh
```
You will be prompted to choose whether to output the result as QR-code or configuration file:

`Is QR-code suitable for output? [y/n]`

QR-code is suitable for smartphones and tablets, for desktop devices it is better to choose config.