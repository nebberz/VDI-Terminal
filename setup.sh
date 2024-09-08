#! /bin/bash

# Get VDI Client
cd /usr/local/share
apt install -y python3-pip python3-tk python3-proxmoxer python3-requests virt-viewer network-manager net-tools alsa-base
pip3 install "PySimpleGUI<5.0.0" --break-system-packages
git clone https://github.com/joshpatten/PVE-VDIClient.git

# Setup VDI Client
mkdir /etc/vdiclient
cp vdiclient.ini /etc/vdiclient/vdiclient.ini
cd ./PVE-VDIClient/
# chmod +x requirements.sh
cp vdiclient.py /usr/local/bin
chmod +x /usr/local/bin/vdiclient.py
apt install -y — no-install-recommends xorg openbox
cat > /opt/kiosk.sh <<EOL
#! /bin/bash

xset -dpms
xset s off

openbox-session &

while true; do
    startx /usr/local/bin/vdiclient.py
done
EOL

chmod a+x /opt/kiosh.sh
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
echo > /etc/systemd/system/getty@tty1.service.d/override.conf <<EOL
[Service]
User=vdi
ExecStart=-startx /etc/X11/Xsession /opt/kiosk.sh
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

reboot