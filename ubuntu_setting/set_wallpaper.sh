#!/usr/bin/env bash

RES=$(xrandr | grep '*' | awk '{print $1}')
WALLPAPER_FILE="/usr/share/wallpapers/SpaceFun/contents/images/$RES.svg"
gsettings set org.cinnamon.desktop.background picture-uri "file://$WALLPAPER_FILE"
gsettings set org.cinnamon.desktop.background picture-options 'zoom'
