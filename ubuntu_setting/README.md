# 설치순서

## 1. 설명

Armbian Ubuntu Noble image를 설치하고 설정하는 방법을 아래에 나열한다.


## 2. 지원환경

Armbian Orange Pi 5 Plus, Orange Pi 5 등등.


## 3. 이미지 준비

다운로드 링크: 

[Armbian_25.2.1_Orangepi5-plus_noble_vendor_6.1.99_gnome_desktop](https://dl.armbian.com/orangepi5-plus/Noble_vendor_gnome)

[Armbian_25.2.1_Orangepi5_noble_vendor_6.1.99_gnome_desktop](https://dl.armbian.com/orangepi5/Noble_vendor_gnome)

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

외장 HDD를 Disk유틸리티로 마운트해준다( ex /home/darkice/ExtUSB )

다시 리부팅한다. 다음 실행

```shell
bash 01.init_install.sh
```

언어 설정한다. 다시 리부팅한다. 다음 실행

```shell
bash locale.sh
```

리부팅한다. 다음 실행

```shell
ZSH 설치
bash zsh_install.sh

CASAOS 설치
curl -fsSL https://get.casaos.io | sudo bash
```
