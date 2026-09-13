#!/bin/bash
# 把 15 张官方 SC:R webp 转 JPEG 4K + 拼 preview + 目检
D=/tmp/scr_official
cd "$D"
i=0
for f in *.webp; do
  name="${f%.webp}"
  # 跳过 mobile/小图，只取 ≥2600 宽的大图
  w=$(identify -format "%w" "$f" 2>/dev/null)
  [ "$w" -lt 2500 ] 2>/dev/null && continue
  i=$((i+1))
  magick "$f" -resize 3840x3840 -gravity center -crop 16:9 +repage -quality 92 "scr-${name}.jpg"
done
ls scr-*.jpg | wc -l
identify scr-*.jpg | grep -oE "[0-9]+x[0-9]+" | head -10
du -sh .
# 拼目检 sheet
magick montage scr-*.jpg -tile 4x3 -geometry 450x253+4+4 -background "#05070e" /tmp/scr_sheet.png
identify /tmp/scr_sheet.png | grep -oE "[0-9]+x[0-9]+" | head -1
