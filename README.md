# Easy WireGuard Server
Script to easily configure the WireGuard server. You can select desired action in `./easy_wireguard.sh` script and it will guide you through the process.
Guaranteed to work on Ubuntu 20.04.

## Step 1
Enter sudo mode in terminal

`sudo -i`

Maybe you wil need install *curl*. You can do it with

`apt --yes install curl`

Download and run script with:
```
curl -O https://raw.githubusercontent.com/bllizard22/easy-wireguard-server/main/easy_wireguard.sh
chmod +x easy_wireguard.sh
./easy_wireguard.sh
```

You will be prompted to pick the action
```
Choose the action:
[1] Setup WireGuard server
[2] Restore configuration backup
[3] Add new client (peer)
[4] Show client (peer) QR
[5] Create configuration backup
[6] Remove WireGuard server from this system
```

## Step 2: setting up WireGuard server (option 1)
When prompted, enter the following:
1. WireGuard server port;
2. SSH server port;
```
Choose port for VPN, 1-65535, leave blank for random:
Enter your SSH port:
```
Internal IP for WireGuard server will be `10.18.0.1`
After setup you will be prompted to add a new peer. 

## Step 2.1: restore configuration backup (option 2)
Place your backup into the folder script is in.

It should have a name that matches the pattern: easy-wireguard-server*

Notice: there should only be ONE backup at a time.

The script will unpack and move all files as necessary, after restart your WireGuard server should be setup.

## Step 3: adding a new client (option 3)
```
Done! Now you need to add a few peers.
Would you like to do it now [y/N]?
```
In case of a negative answer, the reminder will appear:
```
You can add peers later by running ./easy_wireguard/add_client.sh manually.
```

After the successful generation of peer config, you'll be asked to choose fitting output: QR (for mobile) or configuration file (for desktop):
```
Enter device name: 
Is QR-code suitable for output [y/N]?
```

## Step 4: creating a backup (option 5)
No input required, the backup will be created in the current working folder under the name that follows the scheme:
easy-wireguard-server-YEAR-MONTH-DAY-HOSTNAME-backup.tar.gz
Cherish it.

## Step 5: showing QR of already created peer configuration (option 4)
You will be prompted to enter configuration/device name exactly as you did before.

After that in case of success QR will be shown.

## Step 6: removing Wireguard server from the system (option 6)

```
This script will remove WireGuard server from this machine.
Are you sure [y/N]?
```

If you need to reinstall WireGuard server run ./easy_wireguard.sh again.
