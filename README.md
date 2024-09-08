# VDI-Terminal
VDI Terminal Config using Josh Patten's VDI config

# Sound
You may not to use aslamixer to unmute the sound card.


# Setup Wifi
sudo apt install net-tools network-manager
nmcli r wifi on
nmcli d wifi connect WifiName password 'password'


# Exploration to mandatory packages for sound instead of pipewire*
pipewire-audio
pipewire-jack
pipewire-pulse
pipewire-alsa
gstreamer1.0-python3-plugin-loader
pipewire-audio 
pipewire-audio-client-libraries
python3-gst-1.0
gstreamer1.0-alsa
gstreamer1.0-pipewire
gstreamer1.0-pulseaudio