#!/bin/bash
# Workspace $1 like a dwm tag (desktop/linux/dwm): its number icon, then one icon per app on it (dwm's
# taglabel() and tagicons[]), highlighted when focused. Every workspace is always shown, as dwm's tags.
source "$CONFIG_DIR/plugins/colors.sh"

tags=(󰲠 󰲢 󰲤 󰲦 󰲨 󰲪 󰲬 󰲮 󰲰 󰿬)                                    # nf-md-numeric_N_circle, 1-10

icon() {                                         # app name -> icon, as tagicons[] in dwm's config.def.h
    case $1 in
        Firefox|Floorp)                          echo 󰈹 ;;   # nf-md-firefox
        "Google Chrome"|Brave*|qutebrowser|Safari) echo  ;;   # nf-fa-globe
        Alacritty|Terminal|iTerm2|kitty)          echo  ;;   # nf-dev-terminal
        Emacs)                                   echo  ;;   # nf-custom-emacs
        Code)                                    echo 󰨞 ;;   # nf-md-vscode
        Obsidian)                                echo 󰠮 ;;   # nf-md-notebook
        Skim|Preview)                            echo  ;;   # nf-fa-file_pdf
        mpv|VLC|IINA)                            echo  ;;   # nf-fa-video
        *)                                       echo  ;;   # nf-fa-window_maximize (defaulticon)
    esac
}

label=${tags[$(($1 - 1))]}
while IFS= read -r app; do
    [ -n "$app" ] || continue
    i=$(icon "$app")
    case " $label " in *" $i "*) ;; *) label="$label $i" ;; esac   # one icon per distinct app
done < <(aerospace list-windows --workspace "$1" --format '%{app-name}' 2>/dev/null)

focused=${AEROSPACE_FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}   # set by aerospace.toml
if [ "$1" = "$focused" ]; then
    sketchybar --set "$NAME" label="$label" label.color="$SEL_FG" background.drawing=on
else
    sketchybar --set "$NAME" label="$label" label.color="$BAR_FG" background.drawing=off
fi
