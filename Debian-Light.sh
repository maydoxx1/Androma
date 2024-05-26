#!/data/data/com.termux/files/usr/bin/bash
pkg install wget -y 
folder=debian-fs
dlink="https://raw.githubusercontent.com/maydoxx1/Androma/main/Debian-Light.sh"
dlink2="https://raw.githubusercontent.com/maydoxx1/Androma/main/awesome.sh"
if [ -d "$folder" ]; then
        first=1
        echo "skipping downloading"
fi
tarball="debian-rootfs.tar.xz"
if [ "$first" != 1 ];then
        if [ ! -f $tarball ]; then
                echo "Download Rootfs, this may take a while base on your internet speed."
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
                wget "https://github.com/Techriz/AndronixOrigin/blob/master/Rootfs/Debian/${archurl}/debian-rootfs-${archurl}.tar.xz?raw=true" -O $tarball
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

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball

#DE installation addition

wget --tries=20 $dlink2/awesome.sh -O $folder/awesome.sh
clear
echo "Setting up the installation of Awesome VNC"

echo "APT::Acquire::Retries \"3\";" > $folder/etc/apt/apt.conf.d/80-retries #Setting APT retry count
echo "#!/bin/bash
apt update -y && apt install wget sudo -y
clear
if [ ! -f /root/awesome.sh ]; then
    wget --tries=20 $dlink2/awesome.sh -O /root/awesome.sh
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
rm -rf ~/.bash_profile" > $folder/root/.bash_profile 
sudo apt install -y \
    build-essential \
    curl \
    git \
    htop \
    nano \
    wget \
    tmux \
    zsh \
    neofetch \
    ranger \
    mc \
    vim \
    lynx \
    feh \
    scrcpy \
    pcmanfm \
    openbox \
    obconf \
    mpv \
    deadbeef \
    cmus \
    rxvt-unicode \
    transmission-cli \
    netcat \
    nmap \
    sshfs \
    zip \
    unzip \
    unrar \
    tor \
    torsocks \
    torbrowser-launcher \
    links2 \
    w3m \
    elinks \
    mpd \
    mpc \
    ncmpcpp \
    moc \
    ffmpeg \
    mupdf \
    newsboat \
    mutt \
    neomutt \
    cmatrix \
    toilet \
    figlet \
    dialog \
    rsync \
    xdg-utils \
    xdg-user-dirs \
    scrot \
    imagemagick \
    calcurse \
    lua5.3 \
    lua5.3-dev \
    luajit \
    liblua5.3 \
    luarocks \
    libluajit-5.1 \
    python \
    python-dev \
    python3 \
    python3-dev \
    python-pip \
    python3-pip \
    python-setuptools \
    python3-setuptools \
    golang \
    clang \
    cmake \
    automake \
    autoconf \
    pkg-config \
    libtool \
    busybox \
    busybox-static \
    ncdu \
    bc \
    gnupg \
    gnupg2 \
    ca-certificates \
    lsof \
    ssh \
    openssh \
    file \
    sudo \
    grep \
    sed \
    make \
    m4 \
    flex \
    bison \
    emacs \
    inetutils \
    apt-utils \
    bind \
    bind9 \
    whois \
    inetutils-telnet \
    net-tools \
    iputils \
    iproute2 \
    iptables \
    socat \
    axel \
    aria2 \
    ncurses-term \
    tightvncserver \

bash $bin
