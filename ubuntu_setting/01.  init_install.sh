#!/bin/bash
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
qtbase5-dev udev libsdl2-dev libbpf-dev llvm clang python3-pybind11	openjdk-17-jdk net-tools zlib1g-dev libfuse2t64 \
portaudio19-dev libhdf5-dev gnupg2 cargo libtool glade libcairo2-dev libxt-dev libgirepository1.0-dev ninja-build \
gettext libmpv-dev libmpv2 libnetfilter-queue-dev ipset build-essential bison qemu-user-static \
qemu-system-arm qemu-efi-aarch64 u-boot-tools debootstrap flex libssl-dev bc rsync kmod cpio xz-utils \
fakeroot parted udev dosfstools uuid-runtime git-lfs device-tree-compiler python3 python-is-python3 fdisk \
bc debhelper python3-pyelftools python3-setuptools python3-distutils-extra python3-pkg-resources swig libfdt-dev \
libpython3-dev dctrl-tools libelf-dev dwarves clinfo ocl-icd-opencl-dev mesa-opencl-icd  binfmt-support \
byacc flex libwayland-egl-backend-dev libx11-xcb-dev libxshmfence-dev libportaudio-ocaml-dev
sudo apt install -y g++ libxml2-dev libavdevice-dev libsdl2-dev '^libxcb.*-dev' libxkbcommon-x11-dev
sudo apt install -y valac libgee-0.8-dev libjson-glib-dev libgettextpo-dev p7zip-full pulseaudio-utils
sudo apt install -y nodejs npm
sudo ln -sf /usr/lib/aarch64-linux-gnu/dri /usr/lib/dri

sudo apt install -y geany nemo mc cpufrequtils thunar net-tools dconf-editor smplayer
sudo apt install -y gdm3 gnome-tweaks gnome-shell-extension-manager chrome-gnome-shell

#영문에서 한글로 변환
echo "C" > ~/.config/user-dirs.locale
export LANG=ko_KR.utf8
xdg-user-dirs-gtk-update

#/etc/default/cpufrequtils 파일에 내용 작성
cat << EOF | sudo tee /etc/default/cpufrequtils > /dev/null
ENABLE=true
MIN_SPEED=408000
MAX_SPEED=2400000
GOVERNOR=performance
EOF

sudo systemctl restart cpufrequtils
echo "/etc/default/cpufrequtils 파일이 성공적으로 업데이트되었습니다."

#gnome tweak and background
cd ~/ExtUSB/Downloads/WhiteSur-icon-theme
sudo ./install.sh
cd ~/ExtUSB/Downloads/WhiteSur-cursors
sudo ./install.sh
cd ~/ExtUSB/Downloads/WhiteSur-wallpapers
sudo ./install-gnome-backgrounds.sh

if [[ -d /usr/share/backgrounds/Dynamic_Wallpapers ]]
then 
	sudo rm -r /usr/share/backgrounds/Dynamic_Wallpapers
	echo "Cleaning up"
fi

echo "Installing wallpapers..."
sudo mkdir -p /usr/share/backgrounds/
sudo mkdir -p /usr/share/gnome-background-properties/ 
sudo cp -r /home/darkice/ExtUSB/Backup/Wallpaper/Linux_Dynamic_Wallpapers/Dynamic_Wallpapers /usr/share/backgrounds/Dynamic_Wallpapers
sudo cp /home/darkice/ExtUSB/Backup/Wallpaper/Linux_Dynamic_Wallpapers/xml/* /usr/share/gnome-background-properties/
echo "Wallpapers has been installed. Enjoy setting them as your desktop background!"

#pi-app install
wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash
