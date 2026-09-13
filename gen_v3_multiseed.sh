#!/bin/bash
# SC1 v3：多 seed 择优（每场景 2 个 seed）→ 裁水印 → 2x 锐化放大 2048x1152
export https_proxy=http://127.0.0.1:10808 http_proxy=http://127.0.0.1:10808
D=/home/hyc/starcraft-theme-build
mkdir -p "$D/seeds" "$D/final-v3"

STYLE="StarCraft 1998 remastered style sci-fi concept art, dramatic high contrast lighting, cinematic composition, gritty metallic textures, detailed matte painting, no text no watermark no logo"

declare -A SCENES
SCENES[sc1-marines-vs-swarm]="epic battle scene, space marines in bulky powered armor firing gauss rifles with orange muzzle flashes, hordes of insectoid alien creatures charging across cracked red ground, explosions and smoke"
SCENES[sc1-hydralisk-pack]="pack of predatory insectoid alien creatures with scythe claws and armor-piercing spine projectiles, organic armor plates glistening, charging through purple organic creep carpet, menacing"
SCENES[sc1-protoss-charge]="tall alien warriors with glowing blue psi blades and golden energy shields marching to war, bronze war machines with phase disruptor cannons, alien ruins backdrop"
SCENES[sc1-battlecruiser-yamato]="colossal angular battlecruiser capital ship firing a massive blue plasma cannon beam from its nose, broadside gun batteries blazing, space battle over red planet"
SCENES[sc1-scv-mining]="rugged industrial mining mech vehicle harvesting glowing blue crystals on alien asteroid field, welding sparks, ore hauler, dusty work lights, industrial sci-fi"
SCENES[sc1-psistorm]="robed alien psionic master floating above battlefield unleashing a devastating electric psychic storm, lightning arcs striking ground troops, glowing eyes and golden armor trim, apocalyptic"
SCENES[sc1-ghost-nuke]="lone stealth sniper soldier in light stealth suit crouching on cliff edge with laser designator beam, tactical goggles, distant nuclear detonation in valley below"
SCENES[sc1-carrier-launch]="massive golden alien carrier ship launching swarm of small robotic interceptors, glowing blue tractor beams, fleet formation against nebula backdrop"

for name in "${!SCENES[@]}"; do
  ENC=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "${SCENES[$name]}, $STYLE")
  for seed in 501 502; do
    curl -sL "https://image.pollinations.ai/prompt/$ENC?width=1024&height=576&nologo=true&seed=$seed" \
      -o "$D/seeds/$name-s$seed.jpg" -w "$name s$seed: %{http_code} %{size_download}B %{time_total}s\n" --max-time 300
  done
done

echo "=== pick best (larger file = more detail) + crop watermark + upscale ==="
for name in "${!SCENES[@]}"; do
  best=""
  bestsize=0
  for seed in 501 502; do
    f="$D/seeds/$name-s$seed.jpg"
    if [ -s "$f" ]; then
      sz=$(stat -c%s "$f")
      if [ "$sz" -gt "$bestsize" ]; then best=$f; bestsize=$sz; fi
    fi
  done
  if [ -n "$best" ]; then
    magick "$best" -gravity South -chop 0x35 -resize 2048x1152! -filter Lanczos -unsharp 0x1.2+0.7+0.02 -quality 92 "$D/final-v3/$name.jpg" 2>/dev/null || \
    convert "$best" -gravity South -chop 0x35 -resize 2048x1152! -filter Lanczos -unsharp 0x1.2+0.7+0.02 -quality 92 "$D/final-v3/$name.jpg"
    echo "$name -> $bestsize bytes source"
  fi
done
ls -la "$D/final-v3/"
