#!/data/data/com.termux/files/usr/bin/bash

# Install required packages
pkg install wget proot tar -y 

# Variables
folder=debian-fs
cur=$(pwd)
tarball="debian-rootfs.tar.xz"

# Check device architecture
arch=$(dpkg --print-architecture)
case $arch in
    aarch64)
        archurl="arm64" ;;
    *)
        echo "Unsupported architecture: $arch"; exit 1 ;;
esac

# Setup storage
termux-setup-storage

# Download and extract Rootfs if not already downloaded
if [ ! -d "$folder" ]; then
    echo "Downloading Rootfs, this may take a while based on your internet speed."
    wget "https://github.com/Techriz/AndronixOrigin/blob/master/Rootfs/Debian/${archurl}/debian-rootfs-${archurl}.tar.xz?raw=true" -O "$tarball"
    
    # Check download status
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download Rootfs. Exiting."
        exit 1
    fi
    
    mkdir -p "$folder"
    cd "$folder"
    echo "Decompressing Rootfs, please be patient."
    proot --link2symlink tar -xf "${cur}/${tarball}" ||:
    cd "$cur"
fi

# Create necessary directories
mkdir -p debian-binds
mkdir -p "${folder}/proc/fakethings"

# Create fake proc files if not exist
for file in "${cur}/${folder}/proc/fakethings/stat" "${cur}/${folder}/proc/fakethings/version" "${cur}/${folder}/proc/fakethings/vmstat"; do
    if [ ! -f "$file" ]; then
        echo "# Contents of /proc/stat file" > "$file"
    fi
done

# Create launch script
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

# Set permissions and configurations
chmod +x debian-fs/root/.bash_profile
touch "$folder"/root/.hushlogin
echo "127.0.0.1 localhost localhost" > "$folder"/etc/hosts
echo "nameserver 1.1.1.1" > "$folder"/etc/resolv.conf
chmod +x "$folder"/etc/resolv.conf
echo "Fixing shebang of $bin"
termux-fix-shebang "$bin"
echo "Making $bin executable"
chmod +x "$bin"
echo "Removing image for some space"
rm "$tarball"

# Enter the environment
./start-debian.sh

# Install lightweight packages
apt-get update
apt-get install --no-install-recommends -y \
    xterm \
    nano \
    htop \
    feh \
    scrcpy \
    pcmanfm \
    lxappearance \
    openbox \
    obconf \
    mpv \
    deadbeef \
    cmus \
    rxvt-unicode \
    tmux \
    git \
    wget \
    curl \
    lynx \
    vim \
    zsh \
    neofetch \
    ranger \
    mc \
    mplayer \
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
    lynx \
    w3m \
    w3m-img \
    cmatrix \
    toilet \
    figlet \
    dialog \
    rsync \
    xdg-utils \
    xdg-utils-devel \
    xdg-user-dirs \
    scrot \
    imagemagick \
    lynx \
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
    build-essential \
    gcc \
    clang \
    cmake \
    automake \
    autoconf \
    pkg-config \
    libtool \
    fakeroot \
    busybox \
    busybox-static \
    less \
    ncdu \
    bc \
    gnupg \
    gnupg2 \
    ca-certificates \
    lsof \
    ssh \
    openssh \
    ssh-client \
    ssh-server \
    file \
    sudo \
    grep \
    sed \
    make \
    m4 \
    flex \
    bison \
    nano \
    vim \
    emacs \
    sudo \
    inetutils \
    apt-utils \
    zip \
    unzip \
    unrar \
    rsync \
    cron \
    cronie \
    cron-utils \
    cronolog \
    ssmtp \
    bsd-mailx \
    heirloom-mailx \
    neomutt \
    msmtp \
    mutt \
    postfix \
    emacs-nox \
    ed \
    joe \
    vim-nox \
    nvi \
    nano \
    dnsutils \
    dnsmasq \
    bind \
    bind9 \
    whois \
    inetutils-telnet \
    net-tools \
    iputils \
    iproute2 \
    iptables \
    netcat \
    nmap \
    socat \
    curl \
    wget \
    axel \
    transmission-cli \
    aria2 \
    axel \
    ncurses-term \
    tightvncserver \
    
    # Display final message
    echo "AndroMa has been installed successfully. You can Use ./start-ubuntu22.sh!"

    # Clear the terminal
    clear

    # Clean up
    rm -rf ~/.bash_profile
