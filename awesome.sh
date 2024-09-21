#!/bin/bash
clear
echo "Installing Awesome"
sleep 2

# Update and install required packages
sudo apt update -y
sudo apt install -y keyboard-configuration tzdata sudo wget dialog libexo-2-0 synaptic gdebi
sudo apt install -y awesome tigervnc-standalone-server nano dbus-x11 xorg xterm pcmanfm shotwell cairo-dock apt-utils --no-install-recommends

# Clear the screen
clear

# Create .vnc directory
mkdir -p ~/.vnc

# Download wallpaper
wget https://raw.githubusercontent.com/maydoxx1/Androma/refs/heads/main/wallpaper.jpeg -O /usr/share/wallpaper.jpg

# Create xstartup script for VNC
cat <<EOM > ~/.vnc/xstartup
#!/bin/bash
[ -r ~/.Xresources ] && xrdb ~/.Xresources
export PULSE_SERVER=127.0.0.1
export DISPLAY=:1
export ~/.Xauthority
dbus-launch awesome
dbus-launch cairo-dock
EOM

chmod +x ~/.vnc/xstartup

# Download and install VNC server start/stop scripts
wget https://raw.githubusercontent.com/Techriz/AndronixOrigin/master/APT/LXDE/vncserver-start -O /usr/local/bin/vncserver-start
wget https://raw.githubusercontent.com/Techriz/AndronixOrigin/master/APT/LXDE/vncserver-stop -O /usr/local/bin/vncserver-stop
chmod +x /usr/local/bin/vncserver-start
chmod +x /usr/local/bin/vncserver-stop

# Display final instructions
clear
echo "You can now start the VNC server by running vncserver-start"
echo " "
echo "It will ask you to enter a password when starting it for the first time."
echo " "
echo "The VNC server will be started at 127.0.0.1:5901"
echo " "
echo "You can connect to this address with a VNC Viewer you prefer."
echo " "
echo "To kill the VNC server, just run vncserver-stop."
echo " "

# Set VNC password and start the VNC server
vncserver
