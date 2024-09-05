#! /bin/bash

# Get VDI Client
cd /usr/local/share
apt install python3-pip python3-tk virt-viewer network-manager net-tools
git clone https://github.com/joshpatten/PVE-VDIClient.git

# Setup VDI Client
cd ./PVE-VDIClient/
chmod +x requirements.sh
./requirements.sh
mkdir /etc/vdiclient
cp vdiclient.ini /etc/vdiclient/vdiclient.ini
cp vdiclient.py /usr/local/bin
chmod +x /usr/local/bin/vdiclient.py
apt install -y — no-install-recommends xorg openbox
cat > /etc/systemd/system/kiosk.service <<EOL
#! /bin/bash

xset -dpms
xset s off

openbox-session &

while true; do
    startx /usr/local/bin/vdiclient.py
done
EOL

chmod a+x /opt/kiosh.sh
cat > /etc/systemd/system/kiosk.service <<EOL
[Unit]
Description=The Allens VDI
After=network-online.target
Wants=network-online.target

[Service]
USER=vdi
ExecStart=startx /etc/X11/Xsession /opt/kiosk.sh

[Install]
WantedBy=multi-user.target
EOL

systemctl enable kiosk.service

#Enable Auto Login
mkdir /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/override.conf <<EOL
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noissue --autologin vdi %I $TERM
Type=idle
EOL
echo NAutoVTs=1 >> /etc/systemd/logind.conf
echo ReserveVT=1 >> /etc/systemd/logind.conf

# Enable Wifi

reboot