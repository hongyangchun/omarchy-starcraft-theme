#!/bin/bash
# 终极同步：preview.png + README + git push + 本机主题全量对齐
set -e
THEME=/home/hyc/.config/omarchy/themes/starcraft
BUILD=/home/hyc/starcraft-theme-build

# 1. preview 已拷贝（上一步完成）
echo "preview: $(identify "$THEME/preview.png" | grep -oE '[0-9]+x[0-9]+' | head -1)"

# 2. README 壁纸章节重写为官方12张
python3 - <<'PYEOF'
p = '/home/hyc/.config/omarchy/themes/starcraft/README.md'
s = open(p, encoding='utf-8').read()
old = s[s.index("## Wallpapers"):s.index("## Icons")]
new = """## Wallpapers (Backgrounds)

13 official StarCraft: Remastered assets, sourced directly from **starcraftremastered.blizzard.com** (Blizzard CDN):

- `sc1-official-terran.jpg` — Terran outpost on red desert (2600×1300)
- `sc1-official-zerg.jpg` — Zerg hive, green mist (2600×1300)
- `sc1-official-protoss.jpg` — Protoss temple, psi blue (2600×1300)
- `sc1-official-finale.jpg` — Finale fleet over planet (2600×1200)
- `sc1-official-hive-door.jpg` — Hive door close-up (2560×1440)
- `sc1-official-gallery-01~08.jpg` — 8 official remastered screenshots (1600×900)

Cycle wallpapers:
```bash
omarchy theme bg next
```

## Icons

Defaulted to `Yaru-contrast-dark` — high-contrast glyphs that hold their own against psi gold.

## License

MIT — see [LICENSE](LICENSE). **Wallpapers are artwork from StarCraft: Remastered © Blizzard Entertainment — included as unofficial fan-theme distribution, all rights belong to Blizzard.** Not affiliated with or endorsed by Blizzard Entertainment.
"""
s = s.replace(old, new)
open(p, 'w', encoding='utf-8').write(s)
print("README updated")
PYEOF

# 3. 同步 build 目录（保持一致）
rsync -a --delete "$THEME/backgrounds/" "$BUILD/backgrounds/" 2>/dev/null
cp "$THEME/preview.png" "$BUILD/preview.png"
cp "$THEME/README.md" "$BUILD/README.md"

# 4. 推送
cd "$BUILD"
git add -A
git commit -q -m "sync: update preview + README for official wallpaper set" 2>/dev/null || echo "already synced"
git push -q origin main 2>/dev/null || true
git log --oneline -1

# 5. 推送新壁纸到桌面
BG="$THEME/backgrounds/sc1-official-terran.jpg"
omarchy-theme-bg-set "$BG" 2>/dev/null && echo "desktop: $(omarchy-theme-bg-current)"
