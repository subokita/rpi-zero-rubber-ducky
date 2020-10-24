#!/bin/bash
if [ $EUID -ne 0 ]; then
	echo "You must use sudo to run this script:"
	echo "sudo $0 $@"
	exit
fi
apt-get update
apt-get upgrade -y
apt-get install git rpi-update
BRANCH=next rpi-update c053625

## dwc2 drivers
sed -i -e "\$adtoverlay=dwc2" /boot/config.txt

##Install git and download rspiducky
git clone https://github.com/subokita/rpi-zero-rubber-ducky.git

##Make all nessisary files executeable
cd /home/pi/rpi-zero-rubber-ducky
chmod 755 hid-gadget-test.c duckpi.sh usleep.c g_hid.ko usleep hid-gadget-test

\cp g_hid.ko /lib/modules/4.4.0+/kernel/drivers/usb/gadget/legacy

cat <<'EOF'>>/etc/modules
dwc2
g_hid
EOF

##Make it so that you can put the payload.dd in the /boot directory
sed -i '/exit/d' /etc/rc.local

cat <<'EOF'>>/etc/rc.local
sleep 3
cat /boot/payload.dd > /home/pi/payload.dd
sleep 1
tr -d '\r' < /home/pi/payload.dd > /home/pi/payload2.dd
sleep 1
/home/pi/duckpi.sh /home/pi/payload2.dd
exit 0
EOF

##Making the first payload
cat <<'EOF'>>/boot/payload.dd
DELAY 1000
GUI SPACE
DELAY 100
STRING Safari
DELAY 100
ENTER
DELAY 3000
STRING https://www.youtube.com/watch?v=cE0wfjsybIQ
ENTER
GUI SPACE
DELAY 100
STRING Terminal
DELAY 100
ENTER
DELAY 3000
STRING osascript -e 'tell app "System Events" to display dialog "Rubber Ducky initial payload successful'
DELAY 500
ENTER
DELAY 100
ENTER
GUI m
EOF
