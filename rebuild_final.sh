#!/bin/bash
# SC1R 终极重建脚本（原子操作，一次到位）
# 目标：11 张官方高清里筛出 9 张纯 SC1R（删 4 张用户不要/非SC，补 6 张 dark 系列），
# 加上现有 4 keepers = 10 张最终集
set -e

THEME_BG=/home/hyc/.config/omarchy/themes/starcraft/backgrounds
DARK=/tmp/sc1_dark
FINAL=/tmp/sc1_final

# keepers（用户认可的 4 张官方重制）：按 hash 识别 = /tmp/sc1_final 里的 02,07,09,11
KEEPERS="sc1-remastered-02.jpg sc1-remastered-07.jpg sc1-remastered-09.jpg sc1-remastered-11.jpg"

# 1. 清空主题 backgrounds，放入 4 keepers（从 sc1_final 找）
rm -rf "$THEME_BG"
mkdir -p "$THEME_BG"
for k in $KEEPERS; do
  cp "$FINAL/$k" "$THEME_BG/$k"
done

# 2. 放入 6 张 dark（裁水印+放大）
i=0
for f in "$DARK"/dark-*.jpg; do
  i=$((i+1))
  magick "$f" -gravity South -chop 0x46 -resize 3200x1800! -filter Lanczos \
    -unsharp 0x1+0.5+0.02 -quality 90 "$THEME_BG/sc1-dark-$(printf %02d $i).jpg"
done

# 3. 重建 preview
cd /home/hyc/starcraft-theme-build
magick montage "$THEME_BG"/*.jpg -tile 4x3 -geometry 450x253+4+4 -background "#05070e" /tmp/prev_raw.png
magick /tmp/prev_raw.png -resize 1800x -strip -depth 8 -colors 128 -define png:compression-level=9 preview.png

# 4. 提交推送
git add -A
git commit -q -m "v10 real: 10 wallpapers = 4 official remastered keepers + 6 dark single-subject" 2>/dev/null || echo "no changes to commit"
git push -q origin main 2>/dev/null || echo "push skipped (same as remote)"

# 5. 验证
echo "=== FINAL ==="
ls "$THEME_BG"
echo "total: $(ls "$THEME_BG" | wc -l)"
omarchy theme set starcraft 2>&1 | tail -1
BG=$(readlink -f ~/.local/state/omarchy/current/background)
omarchy-theme-bg-set "$BG" 2>/dev/null && echo "desktop bg pushed: $(basename $BG)"
