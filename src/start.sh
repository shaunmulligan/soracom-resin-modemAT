#!/bin/bash
#Enable i2c
modprobe i2c-dev

# Setting Network Manager bus so that our client can communicate with it
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

# Start Dropbear SSHD
if [[ -n "${SSH_PASSWD}" ]]; then
	#Set the root password
	echo "root:$SSH_PASSWD" | chpasswd
	#Spawn dropbear
	dropbear -E -F &
fi

# Check if we should disable non-cellular connectivity
if [[ -n "${CELLULAR_ONLY}" ]]; then
	echo "CELLULAR_ONLY enabled, disabling Ethernet and WiFi"
	ifconfig wlan0 down
	ifconfig eth0 down
	sleep 22
	# Make sure we still have a connection
	curl -s --connect-timeout 52 http://ifconfig.io  > /data/soracom.log
	if [[ $? -eq 0 ]]; then
		echo "Ethernet and WiFi successfully disabled"
	else
		echo "Re-enabling Ethernet and WiFi as device didn't have internet without it"
		ifconfig eth0 up
		ifconfig wlan0 up
	fi
else
	ifconfig eth0 up
	ifconfig wlan0 up
fi

# Start pm2 process to run app.js forever
sleep 5
cd /usr/src/app
pm2 -s link
pm2 -s start /usr/src/app/app.js --max-memory-restart 200M &
# Start showing logs
pm2 logs --out &

# Run connection check script every 15mins
while :
do
	# Check Cellular network connection quality
	MODEM_NUMBER=`mmcli -L | grep Modem | sed -e 's/\//\ /g' | awk '{print $5}'` 
	log `mmcli -m ${MODEM_NUMBER} | grep quality`
	# Sleep until we run our connection check script
	sleep 900;
	bash /usr/src/app/reconnect.sh;
done
