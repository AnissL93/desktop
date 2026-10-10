#!/bin/bash
# Weather from wttr.in, refreshed once a day, like desktop/linux/scripts/show_weather; the
# condition as a typicon, then "place: temperature humidity". Click: the full report.
source "$CONFIG_DIR/plugins/colors.sh"
report="${XDG_DATA_HOME:-$HOME/.local/share}/weatherreport"
brief="${report}_brief"
[ "$SENDER" = mouse.clicked ] && { open -na Alacritty --args -e less -Srf "$report"; exit; }

if [ "$(stat -f %Sm -t %F "$report" 2>/dev/null)" != "$(date +%F)" ]; then
    mkdir -p "$(dirname "$report")"
    curl -sf "wttr.in/" > "$report"
    curl -sf "wttr.in/Markethill?format=%c|%l:+%t+%h" > "$brief"
fi
IFS='|' read -r cond text < "$brief"                             # no trailing newline: read fails
[ -n "$text" ] || exit
case $cond in                                                          # wttr emoji -> typicons weather-*
    *☀*) icon=$'' ;; *⛅*) icon=$'' ;; *☁*|*🌫*) icon=$'' ;;
    *🌦*) icon=$'' ;; *🌧*) icon=$'' ;; *⛈*|*🌩*) icon=$'' ;;
    *❄*|*🌨*) icon=$'' ;; *) icon=$'' ;;
esac
sketchybar --set "$NAME" icon="$icon" label="$text"
