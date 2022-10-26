mkdir temp
cd temp
tar -xvzf ../easy-wireguard*
mv -fv ./etc/wireguard/clients/* /etc/wireguard/clients
rm -f ./etc/wireguard/clients
mv -fv ./etc/wireguard/* /etc/wireguard
cd ..
rm -rf ./temp
echo "Backup restored."
wg-quick down wg0
wg-quick up wg0
