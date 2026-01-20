#!/usr/bin/env bash

sudo apt install -y pipewire pipewire-pulse wireplumber pulseaudio-utils
systemctl --user enable --now pipewire pipewire-pulse wireplumber


systemctl --user stop pipewire pipewire-pulse wireplumber
rm -rf ~/.config/pipewire ~/.local/state/pipewire ~/.config/wireplumber
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber

