#!/bin/bash
set -e
cd ~/.config/omarchy/themes/starcraft
git fetch -q origin
git reset -q --hard origin/main
echo "theme wallpapers: $(ls backgrounds/ | wc -l)"
ls backgrounds/
omarchy theme set starcraft 2>&1 | tail -1
BG=$(readlink -f ~/.local/state/omarchy/current/background)
omarchy-theme-bg-set "$BG" 2>/dev/null && echo "desktop bg updated: $(basename "$BG")"
identify "$BG" | grep -oE "[0-9]+x[0-9]+" | head -1
