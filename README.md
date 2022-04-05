# Easy WireGuard Server
Scripts for quickly setting up your WireGuard server.

## First step
Maybe you wil need install *curl*. You can do it with

`apt --yes install curl`

Download and run script with:
```
curl -O https://raw.githubusercontent.com/bllizard22/easy-wireguard-server/main/easy_wireguard.sh
chmod +x easy_wireguard.sh
./easy_wireguard.sh
```

## Setup server

When prompted enter any number from 1 to 65535 for VPN connetion or 0 to assign random value.

`Choose port for VPN: [1-65535 or 0 for random value]`

If you use SSH connection enter port number for the rule in Firewall.

`Enter your SSH port: `

After setup you can run `.add_client.sh` to generate new peer.

## Add new client

You will be prompted to choose whether to output the result as QR-code or configuration file:

`Is QR-code suitable for output? [y/n]`

QR-code is suitable for smartphones and tablets, for desktop devices it is better to choose config.