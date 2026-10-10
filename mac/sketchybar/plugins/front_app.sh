#!/bin/bash
# Name of the focused app (dwm shows the window title here).
[ "$SENDER" = front_app_switched ] && sketchybar --set "$NAME" label="$INFO"
