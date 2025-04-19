#!/data/data/com.termux/files/usr/bin/bash
pkg install wget proot -y
folder=debian-fs
dlink="https://raw.githubusercontent.com/maydoxx1/Androma/main/Debian-Light.sh"
dlink2="https://raw.githubusercontent.com/maydoxx1/Androma/main/awesome.sh"

if [ -d "$folder" ]; then
    first=1
    echo "skipping downloading"
fi

tarball="debian-rootfs.tar.xz"
if [ "$first" != 1 ]; then
    if [ ! -f $tarball ]; then
        echo "Download Rootfs, this may take a while based on your internet speed."
        case `dpkg --print-architecture` in
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
            echo "unknown architecture"; exit 1 ;;
        esac
        wget "https://github.com/termux/proot-distro/releases/download/v4.7.0/debian-rootfs-${archurl}.tar.xz" -O $tarball
    fi
    cur=`pwd`
    mkdir -p "$folder"
    cd "$folder"
    echo "Decompressing Rootfs, please be patient."
    proot --link2symlink tar -xf ${cur}/${tarball}||:
    cd "$cur"
fi

mkdir -p debian-binds
bin=start-debian.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
cd \$(dirname \$0)
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

termux-fix-shebang $bin
chmod +x $bin
rm -f $tarball

# Download awesome.sh into the Debian environment
wget --tries=20 "$dlink2" -O "$folder/root/awesome.sh"
chmod +x "$folder/root/awesome.sh"

echo "Setting up the installation of Awesome VNC"
echo "APT::Acquire::Retries \"3\";" > "$folder/etc/apt/apt.conf.d/80-retries"

cat > "$folder/root/.bash_profile" <<- EOM
#!/bin/bash
apt update -y && apt install wget sudo -y
clear
if [ ! -f /root/awesome.sh ]; then
    wget --tries=20 "$dlink2" -O /root/awesome.sh
    bash ~/awesome.sh
else
    bash ~/awesome.sh
fi
clear

if [ ! -f /usr/bin/vncserver ]; then
    apt install tigervnc-standalone-server -y
fi
clear
echo ' Welcome to AndroMa Debian! '
rm -rf ~/.bash_profile
EOM

# Start the Debian environment
echo "Everything is set up! Starting Debian environment..."
./$bin
