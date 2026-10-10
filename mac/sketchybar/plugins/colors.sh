# Sourced by sketchybarrc and every plugin: bar colours and PATH (brew services starts sketchybar with a bare PATH).
export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
BAR_BG=0xff140c00 BAR_FG=0xffffb000 SEL_BG=0xffffb000 SEL_FG=0xff140c00 DIM=0xff664200   # amber, until `theme` runs
[ -f "$HOME/.config/theme/sketchybar.sh" ] && source "$HOME/.config/theme/sketchybar.sh"
