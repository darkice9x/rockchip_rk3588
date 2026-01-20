#!/usr/bin/env bash

mkdir -p $HOME/.local/share/wallpaper
cp $HOME/ExtUSB/Backup/Wallpaper/SpaceFun.png $HOME/.local/share/wallpaper/
WALLPAPER_FILE="$HOME/.local/share/wallpaper/SpaceFun.png"
gsettings set org.cinnamon.desktop.background picture-uri "file://$WALLPAPER_FILE"
gsettings set org.cinnamon.desktop.background picture-options 'zoom'
