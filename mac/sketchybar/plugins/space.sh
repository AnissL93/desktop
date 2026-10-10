#!/bin/bash
# Workspace $1, like a dwm tag: highlighted when focused, plain when it has windows, hidden when empty.
source "$CONFIG_DIR/plugins/colors.sh"
focused=${AEROSPACE_FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}   # set by aerospace.toml exec-on-workspace-change
if [ "$1" = "$focused" ]; then
    sketchybar --set "$NAME" drawing=on background.drawing=on label.color="$SEL_FG"
elif [ -n "$(aerospace list-windows --workspace "$1")" ]; then
    sketchybar --set "$NAME" drawing=on background.drawing=off label.color="$BAR_FG"
else
    sketchybar --set "$NAME" drawing=off
fi
