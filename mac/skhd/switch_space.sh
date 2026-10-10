#!/bin/bash
CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index')
PREV_SPACE_FILE="$HOME/.config/yabai/.yabai_prev_space"

if [ -f "$PREV_SPACE_FILE" ]; then
    PREV_SPACE=$(cat "$PREV_SPACE_FILE")
    echo "$CURRENT_SPACE" > "$PREV_SPACE_FILE"
    yabai -m space --focus "$PREV_SPACE"
else
    echo "$CURRENT_SPACE" > "$PREV_SPACE_FILE"
fi

