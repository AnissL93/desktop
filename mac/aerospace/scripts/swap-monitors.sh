#!/usr/bin/env bash
# Swap the visible workspaces between the two monitors.
#
# Monitor 1 is showing workspace A, monitor 2 is showing workspace B.
# After running: monitor 1 shows B, monitor 2 shows A.
# Focus is restored to whichever workspace was focused before the swap.
set -euo pipefail

AEROSPACE=/opt/homebrew/bin/aerospace

focused=$("$AEROSPACE" list-workspaces --focused)
ws1=$("$AEROSPACE" list-workspaces --monitor 1 --visible)
ws2=$("$AEROSPACE" list-workspaces --monitor 2 --visible)

# Nothing to do if both monitors somehow show the same workspace.
[ "$ws1" = "$ws2" ] && exit 0

# Park ws1 on monitor 2 first, then ws2 on monitor 1. Order matters so the
# two workspaces don't both end up assigned to the same monitor.
"$AEROSPACE" move-workspace-to-monitor --workspace "$ws1" 2
"$AEROSPACE" move-workspace-to-monitor --workspace "$ws2" 1

# Keep the user looking at the workspace they started on.
"$AEROSPACE" workspace "$focused"
