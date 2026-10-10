#!/bin/bash
# Upload / download since the last update, link type, and P while the xray proxy runs;
# like desktop/linux/scripts/show_network, for the default-route interface only.
iface=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
if [ -z "$iface" ]; then
    sketchybar --set "$NAME" icon=$'' label=""                  # typicons cancel: offline
    exit
fi
icon=$''                                                        # typicons device-desktop (ethernet)
networksetup -listallhardwareports | grep -B1 "Device: $iface$" | grep -q Wi-Fi && icon=$''   # wi-fi

read -r up down < <(netstat -ibn -I "$iface" | awk 'NR == 2 {print $10, $7}')
log="${XDG_CACHE_HOME:-$HOME/.cache}/netlog"; mkdir -p "${log%/*}"
[ -f "$log" ] && read -r pup pdown < "$log"
echo "$up $down" > "$log"
rate() { awk -v b="$1" 'BEGIN {
    if (b < 2^20) printf "%6.2f Kib", b/2^10; else if (b < 2^30) printf "%6.2f Mib", b/2^20; else printf "%6.2f Gib", b/2^30 }'; }
label="↑$(rate $((up - ${pup:-$up}))) ↓$(rate $((down - ${pdown:-$down})))"
pgrep -q xray && label="$label P"
sketchybar --set "$NAME" icon="$icon" label="$label"
