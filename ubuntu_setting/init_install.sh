#!/bin/bash
echo "Init Desktop"

OS_RELEASE_FILE="/etc/os-release"

if [ ! -f "$OS_RELEASE_FILE" ]; then
    echo "ERROR: /etc/os-release 파일이 존재하지 않습니다."
    exit 1
fi

# source로 변수 로드
. "$OS_RELEASE_FILE"

# 배포판 판별 (if문)
if [ "$ID" = "ubuntu" ]; then
    echo "판별 결과: Ubuntu 계열입니다."
elif [ "$ID" = "debian" ]; then
    echo "판별 결과: Debian 계열입니다."
else
    echo "판별 결과: 기타 배포판 ($ID) 입니다."
fi

sudo apt update
sudo apt -y purge chromium-browser
sudo apt upgrade -y

# 배포판 판별 (if문)
if [ "$ID" = "ubuntu" ]; then
    sudo apt -y install ubuntu-desktop dbus-x11 xterm pulseaudio pavucontrol qtwayland5 \
	gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good mpv \
	gstreamer1.0-tools dvb-tools ir-keytable libdvbv5-0 libdvbv5-dev libdvbv5-doc libv4l-0 \
	libv4l2rds0 libv4lconvert0 libv4l-dev qv4l2 v4l-utils libegl-mesa0 libegl1-mesa-dev \
	libgbm-dev libgl1-mesa-dev libgles2-mesa-dev libglx-mesa0 mesa-common-dev mesa-vulkan-drivers \
	mesa-utils libcanberra-pulse oem-config-gtk ubiquity-frontend-gtk ubiquity-slideshow-ubuntu \
	gnome-startup-applications gnome-remote-desktop language-selector-gnome \
	im-config cinnamon-l10n

	#sudo apt-get install -y "fonts-nanum*"

	echo "Sound System"
	sudo apt -y install pipewire-alsa
	systemctl --user enable pipewire
	systemctl --user start pipewire
elif [ "$ID" = "debian" ]; then
	if [ "$DESKTOP_SESSION" = "cinnamon" ]; then
		echo $DESKTOP_SESSION
		sudo apt -y install gnome-terminal nautilus pulseaudio pavucontrol shotwell \
		fonts-ubuntu adwaita-icon-theme curl wget unzip cinnamon-l10n \
		xdg-utils
		#sudo apt purge netplan.io -y
		#sudo apt purge nemo -y
cat << EOF | sudo tee /etc/apt/preferences.d/99backports > /dev/null
Package: *
Pin: release a=bookworm-backports
Pin-Priority: 500
EOF
		sudo apt update
		sudo apt -t bookworm-backports install libdrm-dev libgbm-dev -y
	else
		sudo apt install -y gnome-shell gnome-terminal nautilus gdm3 network-manager pulseaudio pavucontrol shotwell \
		gnome-tweaks gnome-software gnome-backgrounds fonts-ubuntu adwaita-icon-theme curl wget unzip cinnamon-l10n \
		xdg-utils gnome-tweaks gnome-shell-extension-manager chrome-gnome-shell
	fi
else
    echo "판별 결과: 기타 배포판 ($ID) 입니다."
fi

echo "Processing 'lib install'"
sudo apt install -y build-essential cmake git pkg-config libgtk-3-dev libavcodec-dev libavformat-dev  \
libv4l-dev libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev gfortran openexr libatlas-base-dev \
libtbb-dev libopenexr-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev python3-numpy \
python3 python3-dev python3-pip gcc python3-opencv libopencv-dev libswscale-dev \
libavdevice-dev libavutil-dev libswresample-dev libavfilter-dev pkg-config ffmpeg \
python3-tk libavutil-dev libdc1394-dev libeigen3-dev libgtk-3-dev libvtk9-qt-dev \
libjpeg-dev libtiff5-dev libpng-dev ffmpeg libxine2-dev libv4l-dev v4l-utils libatlas-base-dev gfortran python3-dev \
zlib1g-dev freeglut3-dev libwxgtk3.2-dev libwxgtk-media3.2-dev libboost-dev make libharfbuzz-dev unzip \
python3-pyqt5 qttools5-dev-tools python3-pyqt5.qtquick qml-module-qtquick-controls qtcreator qtwayland5 \
python3-pyqt6.sip qt6-base-dev qt6-tools-dev-tools qt6-wayland qt6-wayland-dev libxcb-xinerama0-dev libqt6core5compat6 \
debhelper doxygen gcc git graphviz libasound2-dev libjpeg-dev libqt5opengl5-dev libudev-dev libx11-dev meson pkg-config \
qtbase5-dev udev libsdl2-dev libbpf-dev llvm clang python3-pybind11 openjdk-17-jdk zlib1g-dev \
portaudio19-dev libhdf5-dev gnupg2 cargo libtool glade libcairo2-dev libxt-dev libgirepository1.0-dev ninja-build \
gettext libmpv-dev libmpv2 libnetfilter-queue-dev ipset build-essential bison qemu-user-static \
qemu-system-arm qemu-efi-aarch64 u-boot-tools debootstrap flex libssl-dev bc rsync kmod cpio xz-utils \
fakeroot parted udev dosfstools uuid-runtime git-lfs device-tree-compiler python3 python-is-python3 fdisk \
bc debhelper python3-pyelftools python3-setuptools python3-distutils-extra python3-pkg-resources swig libfdt-dev \
libpython3-dev dctrl-tools libelf-dev dwarves clinfo ocl-icd-opencl-dev mesa-opencl-icd  binfmt-support \
byacc flex libwayland-egl-backend-dev libx11-xcb-dev libxshmfence-dev libportaudio-ocaml-dev
sudo apt install -y g++ libxml2-dev libavdevice-dev libsdl2-dev '^libxcb.*-dev' libxkbcommon-x11-dev
sudo apt install -y valac libgee-0.8-dev libjson-glib-dev libgettextpo-dev p7zip-full pulseaudio-utils
sudo apt install -y nodejs npm dnsutils
sudo apt-get -y install autoconf automake pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev ethtool \
shtool rfkill zlib1g-dev libpcap-dev libsqlite3-dev libpcre2-dev libhwloc-dev libcmocka-dev hostapd \
wpasupplicant tcpdump screen iw usbutils expect
sudo apt install -y ccache
sudo apt-get install -y build-essential git valac libgee-0.8-dev libgtk-3-dev libjson-glib-dev gettext libgettextpo-dev p7zip-full imagemagick

#vulkan
sudo apt install -y vulkan-tools
sudo ln -sf /usr/lib/aarch64-linux-gnu/dri /usr/lib/dri

sudo apt install -y libsndfile1-dev

sudo apt install -y geany nemo mc cpufrequtils thunar net-tools dconf-editor smplayer inxi plocate evince gnome-font-viewer baobab
sudo apt -y install sqlitebrowser

if [ "$ID" = "ubuntu" ]; then
	sudo apt install -y libfuse2t64 libstdc++-14-dev kdiskmark
fi

sudo curl -L "https://github.com/docker/compose/releases/download/v2.40.0/docker-compose-linux-aarch64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#/etc/default/cpufrequtils 파일에 내용 작성
cat << EOF | sudo tee /etc/default/cpufrequtils > /dev/null
ENABLE=true
MIN_SPEED=408000
MAX_SPEED=2400000
GOVERNOR=performance
EOF

sudo systemctl restart cpufrequtils
echo "/etc/default/cpufrequtils 파일이 성공적으로 업데이트되었습니다."

sudo cp ./Chromium/* /usr/share/applications/

#gnome tweak and background
mkdir -p ~/ExtUSB/Downloads

if [ ! -d "~/ExtUSB/Downloads/WhiteSur-icon-theme" ]; then
	cd ~/ExtUSB/Downloads
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
else
    echo "디렉토리가 이미 존재합니다. git clone을 건너뜁니다."
fi
if [ ! -d "~/ExtUSB/Downloads/WhiteSur-cursors" ]; then
	cd ~/ExtUSB/Downloads
    git clone https://github.com/vinceliuice/WhiteSur-cursors.git
else
    echo "디렉토리가 이미 존재합니다. git clone을 건너뜁니다."
fi
if [ ! -d "~/ExtUSB/Downloads/WhiteSur-wallpapers" ]; then
	cd ~/ExtUSB/Downloads
    git clone https://github.com/vinceliuice/WhiteSur-wallpapers.git
else
    echo "디렉토리가 이미 존재합니다. git clone을 건너뜁니다."
fi
if [ ! -d "~/ExtUSB/Downloads/WhiteSur-gtk-theme" ]; then
	cd ~/ExtUSB/Downloads
    git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
else
    echo "디렉토리가 이미 존재합니다. git clone을 건너뜁니다."
fi

cd ~/ExtUSB/Downloads/WhiteSur-icon-theme
sudo ./install.sh
cd ~/ExtUSB/Downloads/WhiteSur-cursors
sudo ./install.sh
cd ~/ExtUSB/Downloads/WhiteSur-wallpapers
sudo ./install-gnome-backgrounds.sh
cd ~/ExtUSB/Downloads/WhiteSur-gtk-theme
sudo ./install.sh

if [[ -d /usr/share/backgrounds/Dynamic_Wallpapers ]]; then 
	sudo rm -r /usr/share/backgrounds/Dynamic_Wallpapers
	echo "Cleaning up"
fi

echo "Installing wallpapers..."
if [ ! -d "~/ExtUSB/Backup/Wallpaper/Linux_Dynamic_Wallpapers" ]; then
	mkdir -p ~/ExtUSB/Backup/Wallpaper
	cd ~/ExtUSB/Backup/Wallpaper
    git clone https://github.com/saint-13/Linux_Dynamic_Wallpapers.git
else
    echo "디렉토리가 이미 존재합니다. git clone을 건너뜁니다."
fi

sudo mkdir -p /usr/share/backgrounds/
sudo mkdir -p /usr/share/gnome-background-properties/ 
sudo cp -r ~/ExtUSB/Backup/Wallpaper/Linux_Dynamic_Wallpapers/Dynamic_Wallpapers /usr/share/backgrounds/Dynamic_Wallpapers
sudo cp ~/ExtUSB/Backup/Wallpaper/Linux_Dynamic_Wallpapers/xml/* /usr/share/gnome-background-properties/
echo "Wallpapers has been installed. Enjoy setting them as your desktop background!"

#테마 설정
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'

#ZRAM 확장 16G로
# 백업 생성
sudo cp "/etc/default/armbian-zram-config" "/etc/default/armbian-zram-config.bak"

# ZRAM_PERCENTAGE 변경
sudo sed -i 's/^#\s*ZRAM_PERCENTAGE=50/ZRAM_PERCENTAGE=100/' "/etc/default/armbian-zram-config"

# TMP_SIZE 변경
sudo sed -i 's/^#\s*TMP_SIZE=500M/# TMP_SIZE=16000M/' "/etc/default/armbian-zram-config"

echo "수정 완료 ✅"
echo "백업 파일: /etc/default/armbian-zram-config.bak"

#sudo apt update && sudo apt -y upgrade
sudo apt -y install curl gnupg2 ca-certificates lsb-release
if [ "$ID" = "ubuntu" ]; then
	echo "deb http://nginx.org/packages/mainline/ubuntu `lsb_release -cs` nginx" \
			| sudo tee /etc/apt/sources.list.d/nginx.list
	curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor > packages.nginx.gpg
	sudo install -o root -g root -m 644 packages.nginx.gpg /etc/apt/trusted.gpg.d/
	rm -f packages.nginx.gpg
elif [ "$ID" = "debian" ]; then
	curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian bookworm nginx" \
		| sudo tee /etc/apt/sources.list.d/nginx.list
else
    echo "판별 결과: 기타 배포판 ($ID) 입니다."
fi
sudo apt update
sudo apt -y install nginx
systemctl enable nginx 
/sbin/service nginx start 

#pi-app install
wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash

#프로그램 등록
cp ~/ExtUSB/Apps/Apps_Desktop/* ~/.local/share/applications/
if [ "$ID" = "ubuntu" ]; then
	sudo cp ~/ExtUSB/Apps/Utils/Ubuntu/* /usr/local/bin/
elif [ "$ID" = "debian" ]; then
	sudo cp ~/ExtUSB/Apps/Utils/Debian/* /usr/local/bin/
fi

RES=$(xrandr | grep '*' | awk '{print $1}')
WALLPAPER_FILE="/usr/share/wallpapers/SpaceFun/contents/images/$RES.svg"

if [ "$ID" = "debian" ]; then
	if [ "$DESKTOP_SESSION" = "cinnamon" ]; then
		gsettings set org.cinnamon.desktop.default-applications.terminal exec gnome-terminal
		echo "[INFO] Setting wallpaper."
		gsettings set org.cinnamon.desktop.background picture-uri "file://$WALLPAPER_FILE"
		gsettings set org.cinnamon.desktop.background picture-options 'zoom'
		echo "[OK] Wallpaper applied."
cat << EOF | sudo tee /etc/X11/xorg.conf.d/10-monitor.conf > /dev/null
Section "Monitor"
	Identifier "HDMI-1"
	Option "PreferredMode" "1920x1080"
EndSection

Section "Screen"
	Identifier "Screen0"
	Monitor "HDMI-1"
	DefaultDepth 24
	SubSection "Display"
		Depth 24
		Modes "1920x1080"
	EndSubSection
EndSection
EOF
	fi
fi
