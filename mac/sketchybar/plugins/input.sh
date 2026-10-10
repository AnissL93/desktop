#!/bin/bash
# Input method, like desktop/linux/scripts/input_method: 中 when Squirrel (Rime) is on, else EN.
if defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null | grep -qi rime; then
    label=中
else
    label=EN
fi
sketchybar --set "$NAME" icon=$'' label="$label"                # typicons keyboard
