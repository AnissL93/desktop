#!/bin/bash
# Used / total memory, like `free -h` in desktop/linux/scripts/show_resource. Click: btop.
source "$CONFIG_DIR/plugins/colors.sh"
[ "$SENDER" = mouse.clicked ] && { open -na Alacritty --args -e btop; exit; }
used=$(vm_stat | awk -v ps="$(sysctl -n hw.pagesize)" '
    /Pages active/ {a=$3} /Pages wired down/ {w=$4} /occupied by compressor/ {c=$5}
    END {print (a + w + c) * ps}')
label=$(awk -v u="$used" -v t="$(sysctl -n hw.memsize)" 'BEGIN {printf "%.1fG/%.0fG", u/2^30, t/2^30}')
sketchybar --set "$NAME" icon=$'' label="$label"                # typicons chart-bar
