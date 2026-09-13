#!/bin/bash
# SC1 Remastered 风格重制：8 张兵种/战斗特写壁纸
export https_proxy=http://127.0.0.1:10808 http_proxy=http://127.0.0.1:10808
D=/home/hyc/starcraft-theme-build
mkdir -p "$D/backgrounds-remaster" "$D/raw-remaster"

gen() {
  local seed=$1 name=$2; shift 2
  local P="$*"
  local ENC
  ENC=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "$P")
  curl -sL "https://image.pollinations.ai/prompt/$ENC?width=1024&height=576&nologo=true&seed=$seed" \
    -o "$D/raw-remaster/$name.jpg" -w "$name: %{http_code} %{size_download}B %{time_total}s\n" --max-time 300
}

# 通用风格锚（SC1 Remastered 视觉语言：高对比+单位特写+战场硝烟+1998 matte painting 质感）
STYLE="StarCraft 1998 remastered style sci-fi concept art, dramatic high contrast lighting, cinematic composition, gritty metallic textures, detailed matte painting, no text no watermark no logo"

# 1. Terran: 陆战队 vs 虫群（已验证的构图，seed 固定）
gen 301 sc1-marines-vs-swarm "epic battle scene, space marines in bulky powered armor firing gauss rifles with orange muzzle flashes, hordes of insectoid alien creatures charging across cracked red ground, explosions and smoke, $STYLE"

# 2. Zerg: 刺蛇海
gen 302 sc1-hydralisk-pack "pack of predatory insectoid alien creatures with scythe claws and armor-piercing spine projectiles, organic armor plates glistening, charging through purple organic creep carpet, menacing, $STYLE"

# 3. Protoss: 狂徒+龙骑士
gen 303 sc1-protoss-charge "tall alien warriors with glowing blue psi blades and golden energy shields marching to war, bronze war machines with phase disruptor cannons, alien ruins backdrop, $STYLE"

# 4. Battlecruiser 大和炮
gen 304 sc1-battlecruiser-yamato "colossal angular battlecruiser capital ship firing a massive blue plasma cannon beam from its nose, broadside gun batteries blazing, smaller fighter escort, space battle over red planet, $STYLE"

# 5. SCV 采矿
gen 305 sc1-scv-mining "rugged industrial mining mech vehicle harvesting glowing blue crystals on alien asteroid field, welding sparks, ore hauler, dusty work lights, industrial sci-fi, $STYLE"

# 6. High Templar 灵能风暴
gen 306 sc1-psistorm "robed alien psionic master floating above battlefield unleashing a devastating electric psychic storm, lightning arcs striking ground troops, glowing eyes and golden armor trim, apocalyptic, $STYLE"

# 7. Ghost 核弹
gen 307 sc1-ghost-nuke "lone stealth sniper soldier in light stealth suit crouching on cliff edge designating target with laser designator beam, tactical goggles, distant nuclear detonation mushroom cloud in valley below, $STYLE"

# 8. Carrier 舰载机群
gen 308 sc1-carrier-launch "massive golden alien carrier ship launching swarm of small robotic interceptors, glowing blue tractor beams, fleet formation against nebula backdrop, $STYLE"

echo "=== upscale to 4K (2x then sharpen) ==="
for f in "$D"/raw-remaster/*.jpg; do
  n=$(basename "$f" .jpg)
  # 裁掉底部6%（水印/乱码带）→ 2x lanczos 放大 → 锐化 → 轻噪点补质感 → 4K
  magick "$f" -gravity South -chop 0x35 -resize 200% -filter Lanczos -unsharp 0x1.2+0.7+0.02 -attenuate 0.4 +noise Gaussian -resize 187% -quality 92 "$D/backgrounds-remaster/$n.jpg" 2>/dev/null || \
  convert "$f" -gravity South -chop 0x35 -resize 200% -filter Lanczos -unsharp 0x1.2+0.7+0.02 -attenuate 0.4 +noise Gaussian -resize 187% -quality 92 "$D/backgrounds-remaster/$n.jpg"
done
ls -la "$D/backgrounds-remaster/"
identify "$D/backgrounds-remaster/sc1-marines-vs-swarm.jpg"
