# swallow (desktop/mac/bin/swallow): note the AeroSpace window this shell lives in, once, at its first
# command (the terminal is focused then). Sourced from ~/.zshrc.
(( $+commands[aerospace] )) || return
_swallow_dir=/tmp/swallow-$USER
_swallow_note() {
    [[ -e $_swallow_dir/$$ ]] && return
    local w; w=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null) && [[ -n $w ]] || return
    mkdir -p $_swallow_dir && print -r -- $w >$_swallow_dir/$$
}
_swallow_forget() { rm -f $_swallow_dir/$$ }
autoload -Uz add-zsh-hook
add-zsh-hook preexec _swallow_note
add-zsh-hook zshexit _swallow_forget
