# Soracom's sample resin.io Raspberry Pi Application with Cellular modem AT commands support
  
BETA VERSION, only works on RPi 3 and likely ResinOS 2.3.x for now and doesn't yet rely on Modem Manager package due to systemd conflict with base Resin OS  

In order to use a 3G Dongle with ResinOS 2.3.x, Raspberry Pi 3 and Soracom, you will have to place the sora-mobile GSM configuration file on your device's SD card in /system-connections/
Once this is done, connect the Dongle, boot the device and it should come online on your resin.io dashboard

Our sample Raspberry Pi application uses environment variables to enable a couple of useful features which optimise bandwidth usage and leverage Soracom Harvest and Gate services:
* SSH_PASSWD: when set, this will start sshd and set root password to SSH_PASSWD
* CELLULAR_ONLY: This option disables WiFi
* CONSOLE_LOGGING: Set to 1 in order to get application logs in Resin.io device console, otherwise logs are written to /data/soracom.log
* DEBUG: Set to 1 to have debug logging, use in combination with CONSOLE_LOGGING to see logs in resin.io device console
* SORACOM_HARVEST_INTERVAL: Set the time interval in mili-seconds to publish device data to Soracom Harvest Analytics service, be sure to use together with CELLULAR_ONLY as Harvest identifies devices using their connected Soracom SIM card.

# Running AT commands
This version of resin.io image also adds support to run AT commands on your Cellular modem.

To do so, we install modemmanager apt package during image creation and set the following variable in start.sh:

`export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket`

With this in place, you can connect to resin remote Terminal and run AT commands as follow:

`mmcli -m 0 --command=ATCOMMAND`

For example, you could get your SIM card IMSI:

`mmcli -m 0 --command=AT+CIMI`

Likewise, if you would like to get a list of connected modem, you can run:

`mmcli -L`


PS: if you'd like to use this over an ssh connection, you should export the DBUS variable after you login:

`export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket`

and then run your mmcli commands



As an usage example, we also added a network connection strength check in start.sh which runs every 900secs

`mmcli -m 0 --command=AT+CSQ`

The network RSSI (strength) can be read as follow:
-100 dBm or less: Unacceptable signal, check antenna connection
-99 dbm to -90 dBm: Weak signal 
-89 dbm to -70 dBm: Medium to high signal
-69 dBm or greater: Strong signal




This has been tested on Huawei MS2131 Dongle but should also work with any modem that exposes a Serial interface to Modem Manager and Network Manager


# Credits

Feel free to visit our [Soracom](https://www.soracom.io) website if you'd like to get our Sim card and/or learn more about IoT topics

Special thanks to the [OpenDoor](https://www.opendoor.com) team for bringing up the idea!