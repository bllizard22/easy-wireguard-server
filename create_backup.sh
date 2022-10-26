hostname=$(hostname)
date=$(date +"%Y-%m-%d")
tar -czf easy-wireguard-server-$date-$hostname-backup.tar.gz /etc/wireguard 1>/dev/null 2>/dev/null
if [[ -f "easy-wireguard-server-$date-$hostname-backup.tar.gz" ]]; then
    echo "easy-wireguard-server-$date-$hostname-backup.tar.gz: Backup created."
else
    echo "Backup creation failed."
fi
