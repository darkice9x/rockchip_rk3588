# 설치순서

## 1. 설명

Armbian Ubuntu Noble image를 설치하고 설정하는 방법을 아래에 나열한다.


## 2. 지원환경

Armbian Orange Pi 5 Plus, Orange Pi 5 등등.


## 3. 이미지 준비

다운로드 링크: 

[Armbian_25.8.1_Orangepi5-plus_noble_vendor_6.1.115_gnome_desktop](https://dl.armbian.com/orangepi5-plus/Noble_vendor_gnome)

[Armbian_25.8.1_Orangepi5_noble_vendor_6.1.115_gnome_desktop](https://dl.armbian.com/orangepi5/Noble_vendor_gnome)

SD Card에 이미지 쓰기:

xz -dc Armbian_25.2.1_Orangepi5-plus_noble_vendor_6.1.99_gnome_desktop.img.xz | sudo dd of=/dev/mmcblk1 bs=4M status=progress conv=fsync

xz -dc Armbian_25.2.1_Orangepi5_noble_vendor_6.1.99_gnome_desktop.img.xz | sudo dd of=/dev/mmcblk1 bs=4M status=progress conv=fsync


## 4. 해상도 수정

부팅시에 모니터 해상도가 정해지지 않는 경우가 있어서 아래와 같이 수정해준다

위에 이미지를 저장한 SD Card를 마운트한후 SD Card의 Root로 이동한후 아래처럼 수정한다.

```shell
sudo nano ./boot/armbianEnv.txt
추가
extraargs=video=HDMI-A-1:1920x1080@60
```

## 5. 부팅후 과정

모니터 해상도를 수정한다( 그놈 데스크탑 설정에서 )

```shell
sudo cp ~/.config/monitors.xml /var/lib/gdm3/.config/monitors.xml
```

외장 HDD를 Disk유틸리티로 마운트해준다( ex ~/ExtUSB )

다시 리부팅한다. 

## 6. 스크립트 실행

```shell
bash init_install.sh
```
```doc
-내용설명
필요한 라이브러리 설치
필요한 앱 설치
cpufrequtils 설정
WhiteSur-icon-theme, hiteSur-cursors, WhiteSur-wallpapers Linux_Dynamic_Wallpapers 설치
tweak에서 cursor-theme , icon-theme 설정
nginx 설치
pi-app 설치
```
언어 설정한다(Language support).

다시 리부팅한다.

fcitx5를 입력기로 사용하기 위해서는 setup_fcitx5_full.sh와 setup_fcitx5_panel.sh를 실행시켜준다.

또한 https://extensions.gnome.org/extension/261/kimpanel/ 에서 extension을 인스톨하고 fcitx5-config-qt를 실행하고 전역옵션에서 alt키 등록한다.

```shell
bash locale.sh
```
```doc
-내용설명
영문 디렉토리를 한글 디렉토리로 변경
ko_KR 설정
자동 로그인 불가설정
nemo 루트 옵션 세팅
마운트 드라이버 안보이기
모니터 설정 저장
docker-compose 설치
```
리부팅한다. 다음 실행

```shell
ZSH 설치
bash zsh_install.sh

CASAOS 설치
curl -fsSL https://get.casaos.io | sudo bash
```

## 7. Conky 설치

```shell
sudo apt-get install build-essential git valac libgee-0.8-dev libgtk-3-dev libjson-glib-dev gettext libgettextpo-dev p7zip-full imagemagick
sudo apt install conky-all
git clone https://github.com/zcot/conky-manager2.git
make
sudo make install
```

Conky manager를 실행한후 종료한다.

~/.conky가 생성된다.

Conky_theme에 있는 기종에 맞는 theme를 ~/.conky로 복사한다.

Conky manager를 실행한후 설정한다.
