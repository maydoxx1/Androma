#!/data/data/com.termux/files/usr/bin/bash

# Install required packages
pkg install wget proot tar -y 

# Variables
folder=debian-fs
cur=$(pwd)
tarball="debian-rootfs.tar.xz"
dlink="https://raw.githubusercontent.com/AndronixApp/AndronixOrigin/master/APT"

# Check if folder exists
if [ -d "$folder" ]; then
    first=1
    echo "Skipping downloading"
fi

# Download Rootfs if not already downloaded
if [ "$first" != 1 ]; then
    if [ ! -f "$tarball" ]; then
        echo "Downloading Rootfs, this may take a while based on your internet speed."
        case $(dpkg --print-architecture) in
            aarch64)
                archurl="arm64" ;;
            arm)
                archurl="armhf" ;;
            amd64)
                archurl="amd64" ;;
            x86_64)
                archurl="amd64" ;;
            i*86)
                archurl="i386" ;;
            x86)
                archurl="i386" ;;
            *)
                echo "Unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;;
        esac
        wget "https://github.com/Techriz/AndronixOrigin/blob/master/Rootfs/Debian/${archurl}/debian-rootfs-${archurl}.tar.xz?raw=true" -O "$tarball"
    fi
    
    mkdir -p "$folder"
    cd "$folder"
    echo "Decompressing Rootfs, please be patient."
    proot --link2symlink tar -xJf "${cur}/${tarball}" ||:
    cd "$cur"
fi

# Create necessary directories
mkdir -p debian-binds
bin=start-debian.sh
echo "Writing launch script"
cat > "$bin" <<- EOM
#!/bin/bash
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A debian-binds)" ]; then
    for f in debian-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b debian-fs/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
#command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "Fixing shebang of $bin"
termux-fix-shebang "$bin"
echo "Making $bin executable"
chmod +x "$bin"
echo "Removing image for some space"
rm "$tarball"

# Download XFCE4 installation script
wget --tries=20 "$dlink/XFCE4/xfce4_de.sh" -O "$folder/root/xfce4_de.sh"
clear
echo "Setting up the installation of XFCE VNC"

echo "APT::Acquire::Retries \"3\";" > "$folder/etc/apt/apt.conf.d/80-retries" # Setting APT retry count
echo "#!/bin/bash
apt update -y && apt install wget sudo -y
clear
if [ ! -f /root/xfce4_de.sh ]; then
    wget --tries=20 $dlink/XFCE4/xfce4_de.sh -O /root/xfce4_de.sh
    bash ~/xfce4_de.sh
else
    bash ~/xfce4_de.sh
fi
clear
if [ ! -f /usr/local/bin/vncserver-start ]; then
    wget --tries=20  $dlink/XFCE4/vncserver-start -O /usr/local/bin/vncserver-start
    wget --tries=20 $dlink/XFCE4/vncserver-stop -O /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-stop
    chmod +x /usr/local/bin/vncserver-start
fi
if [ ! -f /usr/bin/vncserver ]; then
    apt install tigervnc-standalone-server -y
fi
clear
echo 'Installing lightweight web browser...'
apt install midori -y
clear
echo 'Welcome to Androma | Debian'
rm -rf ~/.bash_profile" > "$folder/root/.bash_profile" 

bash "$bin"