# AeroSpace Config

My [AeroSpace](https://nikitabobko.github.io/AeroSpace/) tiling window manager setup for macOS.

`~/.config/aerospace` is a symlink to this directory, so editing `aerospace.toml` here is live.

## Modifiers

| Modifier | Used for |
|----------|----------|
| `cmd`    | Window/focus navigation + workspace selection (the main WM modifier) |
| `cmd-shift` | Move windows / workspaces, modes, resize |
| `cmd-ctrl`  | Move window **and** follow it |
| `alt`    | Only where `cmd` is impossible: `alt-tab` (cmd-tab is the macOS app switcher), `alt-shift-r` (cmd-shift-r is resize mode) |

## Multi-monitor (dwm-style)

Workspaces are **not pinned** to monitors. Instead, a workspace is *summoned* onto
whichever monitor is currently focused — like dwm tags.

**Workflow:**
1. Focus the monitor you want with `cmd-up` / `cmd-down`.
2. Press `cmd-<n>` — that workspace appears on the focused monitor and is focused.

A workspace can only live on one monitor at a time; summoning it to another monitor
moves it there (it leaves the previous one).

| Keys | Action |
|------|--------|
| `cmd-up` / `cmd-down` | Focus previous / next monitor *(via skhd)* |
| `cmd-1` … `cmd-0` | **Summon** workspace 1–10 onto the focused monitor |
| `cmd-shift-[` / `cmd-shift-]` | Move the **whole current workspace** to prev / next monitor |
| `cmd-shift-tab` | Move current workspace to the next monitor |
| `cmd-shift-s` | **Swap** the visible workspaces between the two monitors |

## Workspaces

| Keys | Action |
|------|--------|
| `cmd-1` … `cmd-0` | Summon workspace 1–10 |
| `cmd-shift-1` … `cmd-shift-0` | Send focused **window** to workspace N (window moves, focus stays) |
| `cmd-ctrl-1` … `cmd-ctrl-0` | Send focused window to workspace N **and** summon it to the current monitor |
| `cmd-left` / `cmd-right` | Switch to previous / next workspace (wraps around) *(via skhd)* |
| `alt-tab` | Toggle between the last two workspaces (cmd-tab is reserved by macOS) |

## Window focus & movement

| Keys | Action |
|------|--------|
| `cmd-h` / `cmd-j` / `cmd-k` / `cmd-l` | Focus window left / down / up / right |
| `cmd-shift-h/j/k/l` | Move window left / down / up / right |
| `cmd-m` | Toggle fullscreen |
| `cmd-q` | Close focused window (intercepts the macOS "quit app" shortcut — quit via the app menu) |

## Layout

| Keys | Action |
|------|--------|
| `cmd-shift-\` | Tiles layout (horizontal/vertical) |
| `cmd-shift-/` | Accordion layout (horizontal/vertical) |
| `cmd-shift-f` | Toggle floating / tiling for the focused window |

## Resize

Quick resize:

| Keys | Action |
|------|--------|
| `cmd-shift-minus` | Shrink focused window (−50) |
| `cmd-shift-equal` | Grow focused window (+50) |

Resize mode (`cmd-shift-r`, exit with `enter` / `esc`):

| Key | Action |
|-----|--------|
| `h` / `l` | Width −50 / +50 |
| `j` / `k` | Height +50 / −50 |

## Manage mode

Enter with `cmd-shift-m` (exit with `enter` / `esc`):

| Key | Action |
|-----|--------|
| `c` | Reload config |
| `r` | Reset layout (flatten workspace tree) |
| `f` | Toggle floating / tiling |
| `backspace` | Close all windows but the focused one |
| `h` / `j` / `k` / `l` | Join focused window with neighbor (left/down/up/right) |

## Apps & launchers

| Keys | Action |
|------|--------|
| `cmd-enter` | New Alacritty window |
| `cmd-e` | Open Emacs (`emacsclient`) |

## Config maintenance

| Keys | Action |
|------|--------|
| `cmd-shift-c` | Reload AeroSpace config |
| `alt-shift-r` | Reload SketchyBar (kept on alt — cmd-shift-r is resize mode) |

Or from the terminal:

```sh
aerospace reload-config
```

## Auto window rules

Defined via `on-window-detected` in `aerospace.toml`. Only the **first** matching
rule runs, so order matters — the Picture-in-Picture rules are listed before the
generic Firefox rule on purpose.

- **Firefox / Floorp Picture-in-Picture** → floating
- **Firefox** (other windows) → opens on workspace 10
- **mpv** → floating

### Picture-in-Picture video

PiP video windows are forced to **float** (never tiled). To use it: start
Picture-in-Picture from the browser and the small video window won't get tiled
into the layout.

> **Sticky is not possible.** AeroSpace can't pin a window so it stays visible on
> every workspace ([upstream issue #2](https://github.com/nikitabobko/AeroSpace/issues/2)).
> A floating window still hides when you switch away from its workspace.
>
> **Workaround (multi-monitor):** PiP floats on the workspace where you started it.
> Keep that workspace visible on one monitor and work on the other — the video
> stays on screen the whole time. For truly always-on-top behavior, macOS's *native*
> system PiP (e.g. Safari) floats above all spaces on its own and isn't managed by
> AeroSpace.

To cover another browser, add a rule above the generic ones with its `app-id`
(find it via `aerospace list-apps`) and `if.window-title-regex-substring = "Picture-in-Picture"`.

## Integrations

- **[SketchyBar](https://github.com/FelixKratz/SketchyBar)** — status bar, triggered on workspace change and started on launch.
- **[JankyBorders](https://github.com/FelixKratz/JankyBorders)** — active/inactive window borders, started on launch.
- **[skhd](https://github.com/koekeishiya/skhd)** — owns ONLY the four `cmd-arrow` bindings
  (config: `Dotfiles/skhd/skhdrc`, runs as a launchd service). Real arrow-key events carry
  an implicit `fn` modifier flag that AeroSpace's hotkey matching rejects, so AeroSpace
  never sees `cmd-arrows` from a physical keyboard; skhd's event tap does, and shells out
  to the `aerospace` CLI. Restart after config changes: `skhd --restart-service`.
