#!/usr/bin/env bash

OUT_FILE="./gnome_font_profile.conf"

{
  echo "#!/usr/bin/env bash"
  echo "# GNOME Font Profile Export"
  echo "FONT_UI=$(gsettings get org.gnome.desktop.interface font-name)"
  echo "FONT_DOC=$(gsettings get org.gnome.desktop.interface document-font-name)"
  echo "FONT_MONO=$(gsettings get org.gnome.desktop.interface monospace-font-name)"
  echo "FONT_TITLE=$(gsettings get org.gnome.desktop.wm.preferences titlebar-font)"

  echo "HINTING=$(gsettings get org.gnome.desktop.interface font-hinting)"
  echo "ANTIALIAS=$(gsettings get org.gnome.desktop.interface font-antialiasing)"
  echo "RGBA=$(gsettings get org.gnome.desktop.interface font-rgba-order)"

  echo "SCALING=$(gsettings get org.gnome.desktop.interface scaling-factor)"
  echo "TEXT_SCALING=$(gsettings get org.gnome.desktop.interface text-scaling-factor)"
} > "$OUT_FILE"

echo "저장 완료: $OUT_FILE"
