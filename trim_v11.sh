#!/bin/bash
set -e
THEME=/home/hyc/.config/omarchy/themes/starcraft
BUILD=/home/hyc/starcraft-theme-build

# 重拼 preview
magick montage "$THEME/backgrounds"/*.jpg -tile 3x3 -geometry 600x338+4+4 -background "#05070e" /tmp/prev_raw.png
magick /tmp/prev_raw.png -resize 1800x -strip -depth 8 -colors 128 -define png:compression-level=9 "$BUILD/preview.png"
cp "$BUILD/preview.png" "$THEME/preview.png"

# 更新 README
python3 - <<'PYEOF'
p = '/home/hyc/.config/omarchy/themes/starcraft/README.md'
s = open(p, encoding='utf-8').read()
old = s[s.index("## Wallpapers"):s.index("## Icons")]
new = """## Wallpapers (Backgrounds)

9 official StarCraft: Remastered assets from **starcraftremastered.blizzard.com** (Blizzard CDN):

- `sc1-official-finale.jpg` — Finale fleet over planet (2600×1200)
- `sc1-official-hive-door.jpg` — Hive door close-up (2560×1440)
- `sc1-official-gallery-01~08.jpg` — 8 official remastered screenshots (1600×900)

Cycle wallpapers:
```bash
omarchy theme bg next
```

## Icons

Defaulted to `Yaru-contrast-dark`.

## License

MIT — see [LICENSE](LICENSE). **Wallpapers are artwork from StarCraft: Remastered © Blizzard Entertainment — included as unofficial fan-theme distribution, all rights belong to Blizzard.**
"""
s = s.replace(old, new)
open(p, 'w', encoding='utf-8').write(s)
print("README updated")
PYEOF

# 同步 build repo
rsync -a --delete "$THEME/backgrounds/" "$BUILD/backgrounds/"
cp "$THEME/README.md" "$BUILD/README.md"
cp "$THEME/preview.png" "$BUILD/preview.png"

# commit + push
cd "$BUILD"
git add -A
git commit -q -m "v11: trim to 9 wallpapers, update preview and README

User curated: remove hive-door, protoss, terran, zerg (off-style).
Final set: finale + 8 gallery screenshots. Preview and README
updated to match."
git push -q origin main
git log --oneline -1

# 推送桌面
BG="$THEME/backgrounds/sc1-official-finale.jpg"
omarchy-theme-bg-set "$BG" 2>/dev/null
echo "desktop: $(omarchy-theme-bg-current)"
echo "final: $(ls "$THEME/backgrounds" | wc -l) wallpapers"
