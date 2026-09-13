#!/bin/bash
# 最终精选：下载全部 A 类候选 → 16:9 规整 → 拼 contact sheet 供终审
export https_proxy=http://127.0.0.1:10808 http_proxy=http://127.0.0.1:10808
mkdir -p /tmp/sc1_pool2
tail -n +2 /tmp/unchecked3.txt | while read -r idx url res fav; do
  case " 2 4 6 8 10 11 12 14 16 17 27 29 31 33 34 36 38 " in
    *" $idx "*) ;;
    *) continue ;;
  esac
  ext="${url##*.}"
  curl -sL "$url" -o "/tmp/sc1_pool2/idx$idx.$ext" -w "idx$idx: %{http_code} %{size_download}B\n" --max-time 120
done
cd /tmp/sc1_pool2
for f in *.png; do
  [ -e "$f" ] || continue
  magick "$f" "${f%.png}.jpg" 2>/dev/null && rm "$f"
done
for f in *.jpg; do
  magick "$f" -resize 3840x3840 -gravity center -crop 16:9 +repage -quality 92 "norm-$f" 2>/dev/null
done
rm -f norm-*.jpg.tmp 2>/dev/null
mkdir -p norm && for f in norm-*.jpg; do mv "$f" "norm/${f#norm-}"; done
magick montage norm/*.jpg -tile 5x4 -geometry 360x203+3+3 -background "#05070e" /tmp/sc1_pool2_sheet.png
identify /tmp/sc1_pool2_sheet.png | grep -oE "[0-9]+x[0-9]+" | head -1
ls norm | wc -l
