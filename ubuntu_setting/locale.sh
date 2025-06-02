#!/bin/bash
#영문에서 한글로 변환
echo "C" > ~/.config/user-dirs.locale
export LANG=ko_KR.utf8
xdg-user-dirs-gtk-update

sudo locale-gen ko_KR.UTF-8
sudo dpkg-reconfigure locales
sudo -u gdm dbus-launch gsettings set org.gnome.system.locale region 'ko_KR.UTF-8'
sudo update-locale LANG=ko_KR.UTF-8 LC_ALL=ko_KR.UTF-8

sudo cp /home/darkice/ExtUSB/Backup/Apps\ Install/open-as-root.nemo_action /usr/share/nemo/actions
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

#/etc/gdm3/custom.conf 파일에 내용 작성
cat << EOF | sudo tee /etc/gdm3/custom.conf > /dev/null
[daemon]
	AutomaticLoginEnable = false
	AutomaticLogin = darkice
EOF

sudo cp ~/.config/monitors.xml /var/lib/gdm3/.config/monitors.xml
