#!/bin/bash
# 修复脚本：清理本机主题目录，与 v7 (build repo) 精确同步
set -e
# 1. 恢复 build 工作区到 HEAD (v7)
cd /home/hyc/starcraft-theme-build
git checkout -- backgrounds/
echo "build backgrounds: $(ls backgrounds/ | wc -l)"

# 2. 同步到本机主题（镜像）
rsync -a --delete /home/hyc/starcraft-theme-build/backgrounds/ ~/.config/omarchy/themes/starcraft/backgrounds/
echo "theme backgrounds: $(ls ~/.config/omarchy/themes/starcraft/backgrounds/ | wc -l)"
ls ~/.config/omarchy/themes/starcraft/backgrounds/

# 3. 重新应用主题 + 推送壁纸到桌面
omarchy theme set starcraft 2>&1 | tail -1
BG=$(readlink -f ~/.local/state/omarchy/current/background)
omarchy-theme-bg-set "$BG" 2>/dev/null && echo "bg pushed to desktop"
identify "$BG" | grep -oE "[0-9]+x[0-9]+" | head -1
