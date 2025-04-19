#!/bin/bash
clear
echo "Installing Awesome WM with VNC"
sleep 2

# Update and install required packages
apt update -y
apt install -y --no-install-recommends \
    keyboard-configuration \
    tzdata \
    sudo \
    wget \
    dialog \
    libexo-2-0 \
    synaptic \
    gdebi \
    awesome \
    tigervnc-standalone-server \
    nano \
    dbus-x11 \
    xorg \
    xterm \
    pcmanfm \
    shotwell \
    cairo-dock \
    apt-utils \
    lxterminal

# Clear the screen
clear

# Create .vnc directory
mkdir -p ~/.vnc

# Download wallpaper
wget https://raw.githubusercontent.com/maydoxx1/Androma/main/wallpaper.jpg -O /usr/share/wallpaper.jpg || {
    echo "Failed to download wallpaper"
    # Create blank wallpaper as fallback
    convert -size 1920x1080 xc:black /usr/share/wallpaper.jpg
}

# Create proper xstartup script for VNC
cat > ~/.vnc/xstartup <<EOM
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
[ -r \$HOME/.Xresources ] && xrdb \$HOME/.Xresources
export PULSE_SERVER=127.0.0.1
export DISPLAY=:\$1
export XAUTHORITY=\$HOME/.Xauthority
export LANG=en_US.UTF-8

# Start Awesome WM with Cairo Dock
exec dbus-launch --exit-with-session awesome &
cairo-dock &
EOM

chmod +x ~/.vnc/xstartup

# Download VNC management scripts
wget https://raw.githubusercontent.com/Techriz/AndronixOrigin/master/APT/LXDE/vncserver-start -O /usr/local/bin/vncserver-start && \
wget https://raw.githubusercontent.com/Techriz/AndronixOrigin/master/APT/LXDE/vncserver-stop -O /usr/local/bin/vncserver-stop && \
chmod +x /usr/local/bin/vncserver-start && \
chmod +x /usr/local/bin/vncserver-stop || {
    echo "Failed to download VNC scripts"
    exit 1
}

# Display final instructions
clear
cat <<EOM
Awesome WM VNC Setup Complete!

To start VNC server:
  vncserver-start

First run will ask you to set a password.

Connect to:
  127.0.0.1:5901

To stop VNC server:
  vncserver-stop

Recommended VNC viewers:
- bVNC (Android)
- RealVNC Viewer
- TigerVNC
EOM

# Start VNC server if running interactively
if [ -t 0 ]; then
    echo
    read -p "Start VNC server now? [Y/n] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Nn]$ ]] || vncserver :1 -geometry 1280x720 -depth 24
fi
