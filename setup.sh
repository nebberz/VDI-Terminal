#! /bin/bash

# Get VDI Client
cd /usr/local/share
apt install -y python3-pip python3-tk python3-proxmoxer python3-requests network-manager net-tools gstreamer1.0* pipewire* virt-viewer 
pip3 install "PySimpleGUI<5.0.0" --break-system-packages
git clone https://github.com/joshpatten/PVE-VDIClient.git

# Setup VDI Client
mkdir /etc/vdiclient
cp vdiclient.ini /etc/vdiclient/vdiclient.ini
cd ./PVE-VDIClient/
# chmod +x requirements.sh # pip3 broken package install, moved packages to apt
cp vdiclient.py /usr/local/bin
chmod +x /usr/local/bin/vdiclient.py
apt install -y xorg openbox # —-no-install-recommends
echo > /opt/kiosk.sh <<EOL
#! /bin/bash

xset -dpms
xset s off

openbox-session &

while true; do
    startx /usr/local/bin/vdiclient.py
done
EOL

chmod a+x /opt/kiosk.sh
echo > /etc/systemd/system/kiosk.service <<EOL
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
# ExecStart=-startx /etc/X11/Xsession /opt/kiosk.sh
echo > /etc/systemd/system/getty@tty1.service.d/override.conf <<EOL
[Service]
User=vdi
ExecStart=/bin/bash
Type=idle
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5
EOL
echo NAutoVTs=1 >> /etc/systemd/logind.conf
echo ReserveVT=1 >> /etc/systemd/logind.conf

# Enable sound
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=""/c\GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"' /etc/default/grub
usermod -aG audio vdi
usermod -aG audio root

# Enable wifi
wget http://int-web.theallens.house/wifi-config.sh
chmod +x wifi-config.sh
./wifi-config.sh

reboot