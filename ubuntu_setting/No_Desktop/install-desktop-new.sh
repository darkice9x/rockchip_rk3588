#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive
OS_RELEASE_FILE="/etc/os-release"
. "$OS_RELEASE_FILE"

clear
echo "=========================================="
echo " Armbian Server - Desktop Selector Script "
echo "=========================================="
echo
echo "1) Cinnamon (LightDM)"
echo "2) XFCE4 (LightDM)"
echo "3) LXQt (LightDM)"
echo "4) GNOME (GDM3)"
echo "5) KDE Plasma (SDDM)"
echo "6) MATE (LightDM)"
echo "7) Minimal X11 only (no DE)"
echo "0) Exit"
echo

read -rp "Select desktop to install: " CHOICE

# ===============================
# Base packages
# ===============================
BASE_PACKAGES=(
  xserver-xorg
  x11-xserver-utils
  xterm
  xwayland
  dbus-x11
  mesa-utils
  mesa-common-dev
  mesa-vulkan-drivers
  libegl-mesa0
  libegl1-mesa-dev
  libgl1-mesa-dev
  libgl1-mesa-dri
  libgles2-mesa-dev
  libglx-mesa0
  libgbm1
  vulkan-tools
  network-manager
  policykit-1
  gvfs
  gvfs-backends
  udisks2
  xdg-user-dirs
  xdg-utils
  xdg-user-dirs-gtk
)

install_base() {
    echo "[*] Installing base graphics stack (PipeWire)..."

    sudo apt update

    # 기본 그래픽 / 시스템
    sudo apt install -y --no-install-recommends "${BASE_PACKAGES[@]}"

    # ===== PipeWire 오디오 스택 =====
    sudo apt install -y --no-install-recommends \
        pipewire \
        pipewire-audio-client-libraries \
        pipewire-alsa \
        pipewire-pulse \
        wireplumber \
        libspa-0.2-jack \
        pavucontrol \
        pulseaudio-utils

    # ===== 멀티미디어 =====
    sudo apt install -y --no-install-recommends \
        qtwayland5 \
        gstreamer1.0-tools \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        mpv \
        ffmpeg

    # ===== V4L / DVB =====
    sudo apt install -y --no-install-recommends \
        dvb-tools \
        ir-keytable \
        libdvbv5-0 libdvbv5-dev libdvbv5-doc \
        libv4l-0 libv4l2rds0 libv4lconvert0 libv4l-dev \
        qv4l2 v4l-utils

    # ===== 시스템 / 설치 도구 =====
    sudo apt install -y --no-install-recommends \
        gnome-disk-utility \
        network-manager-gnome \
        oem-config-gtk \
        ubiquity-frontend-gtk \
        im-config \
        dconf-cli

    # ===== 알림 사운드 (PulseAudio 의존 제거) =====
    sudo apt install -y --no-install-recommends \
        libcanberra0 \
        libcanberra-gtk3-module

    # ===== 폰트 / 한글 =====
    sudo apt install -y --no-install-recommends \
        fonts-nanum fonts-nanum-coding fonts-noto-cjk \
        fonts-unfonts-core fonts-unfonts-extra \
        language-pack-ko language-pack-ko-base

    if [ "$ID" = "ubuntu" ]; then
		sudo apt install -y  software-properties-common
    fi
}

# ===============================
# Display Managers
# ===============================
install_lightdm() {
    sudo apt install -y \
        lightdm \
        lightdm-gtk-greeter \
        lightdm-settings \
        lightdm-gtk-greeter-settings

    sudo systemctl enable lightdm
}

install_gdm() {
    sudo apt install -y gdm3
    sudo systemctl enable gdm
}

install_sddm() {
    sudo apt install -y sddm
    sudo systemctl enable sddm
}

# ===============================
# Cinnamon dconf preset
# ===============================
setup_cinnamon_dconf() {
    echo "[*] Installing Cinnamon dconf preset..."

    sudo tee /etc/dconf/profile/user >/dev/null <<'EOF'
user-db:user
system-db:local
EOF

    sudo mkdir -p /etc/dconf/db/local.d

    sudo tee /etc/dconf/db/local.d/00-cinnamon-defaults >/dev/null <<'EOF'
[org/cinnamon]
enabled-extensions=['desktop-icons@cinnamon.org']

[org/cinnamon/desktop/interface]
gtk-theme='Arc-Dark'
icon-theme='Arc-Dark'
font-name='Noto Sans CJK KR 10'
monospace-font-name='Noto Sans Mono CJK KR 10'
clock-use-24h=true

[org/cinnamon/desktop/wm/preferences]
theme='Arc-Dark'

[org/cinnamon/theme]
name='Arc-Dark'

[org/nemo/desktop]
show-desktop-icons=true
EOF

    sudo dconf update
}

# ===============================
# Cinnamon
# ===============================
install_cinnamon() {
    echo "[*] Installing Cinnamon desktop (with recommends)..."

    # ❗ no-install-recommends 사용 금지
    sudo apt install -y \
		cinnamon \
		nemo \
		cinnamon-session \
		cinnamon-control-center \
		adwaita-icon-theme \
		hicolor-icon-theme \
		gnome-themes-extra \
		gtk2-engines-pixbuf

    sudo apt install -y \
		ubuntucinnamon-lightdm-theme-base \
		ubuntu-mate-lightdm-theme \
		arc-theme

    # Desktop 아이콘 강제 활성화
    gsettings set org.nemo.desktop show-desktop-icons true || true

    # Basic Apps
	sudo apt install -y gnome-terminal nautilus shotwell \
		fonts-ubuntu geany

    setup_cinnamon_dconf
}

# ===============================
# Auto GUI start (local only)
# ===============================
start_gui_if_local() {
    if [ -n "$SSH_CONNECTION" ]; then
        echo "[!] SSH detected – GUI auto-start skipped."
        return
    fi

    if sudo systemctl is-active --quiet lightdm; then
        return
    fi

    echo "[*] Starting GUI (LightDM)..."
    sudo systemctl start lightdm
}

# ===============================
# Main selector
# ===============================
case "$CHOICE" in
  1)
    install_base
    install_lightdm
    install_cinnamon
    start_gui_if_local
    ;;
  2)
    install_base
    install_lightdm
    apt install -y xfce4 xfce4-goodies
    ;;
  3)
    install_base
    install_lightdm
    apt install -y lxqt openbox
    ;;
  4)
    install_base
    install_gdm
    apt install -y ubuntu-desktop
    ;;
  5)
    install_base
    install_sddm
    apt install -y kde-plasma-desktop plasma-nm dolphin konsole
    ;;
  6)
    install_base
    install_lightdm
    apt install -y mate-desktop-environment mate-terminal caja
    ;;
  7)
    install_base
    echo "[*] Minimal X11 only installed."
    ;;
  0)
    exit 0
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

echo
echo "=========================================="
echo " Desktop installation completed."
echo "=========================================="
