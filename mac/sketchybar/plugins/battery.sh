#!/bin/bash
# Battery, with the typicons of desktop/linux/scripts/battery: plug when on power, else a level icon.
batt=$(pmset -g batt)
pct=$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d %)
[ -n "$pct" ] || { sketchybar --set "$NAME" drawing=off; exit; }      # no battery (desktop Mac)
case $batt in
    *"; charging"*) icon=$'' ;;                                 # battery-charge
    *"AC Power"*)   icon=$'' ;;                                 # plug: charged / not charging
    *) icon=$''                                                 # battery-low
       [ "$pct" -ge 20 ] && icon=$''
       [ "$pct" -ge 50 ] && icon=$''
       [ "$pct" -ge 80 ] && icon=$'' ;;
esac
sketchybar --set "$NAME" drawing=on icon="$icon" label="$pct%"
