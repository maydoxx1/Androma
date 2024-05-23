#!/bin/bash
clear
echo "Installing Awesome"
sleep 2

# Update and install required packages
sudo apt update -y
sudo apt install -y keyboard-configuration tzdata sudo wget dialog libexo-2-0
sudo apt install -y awesome tigervnc-standalone-server nano dbus-x11 xorg xterm xfce4-terminal pcmanfm shotwell cairo-dock --no-install-recommends

# Clear the screen
clear

# Prompt for Chromium installation
read -p "Would you like to install Chromium browser? (y/n) [Chromium might not work on arm/arm32/armhf devices]: " choice
case "$choice" in 
  y|Y ) 
    wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/Uninstall/ubchromiumfix.sh 
    chmod +x ubchromiumfix.sh 
    ./ubchromiumfix.sh 
    rm -rf ubchromiumfix.sh 
    ;;
  n|N ) 
    echo "Ok... Not installing Chromium"
    ;;
  * ) 
    echo "Invalid choice, not installing Chromium"
    ;;
esac

# Create .vnc directory
mkdir -p ~/.vnc

# Download wallpaper
wget https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/WM/wallpaper.jpg -O /usr/share/wallpaper.jpg

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
vncpasswd
vncserver
