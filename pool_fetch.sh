#!/bin/bash
export https_proxy=http://127.0.0.1:10808 http_proxy=http://127.0.0.1:10808
mkdir -p /tmp/pool_check
while read -r n u; do
  curl -sL "$u" -o "/tmp/pool_check/p$n.jpg" -w "p$n: %{http_code} %{size_download}B\n" --max-time 120
done < /tmp/pool_urls.txt
cd /tmp/pool_check
magick montage p*.jpg -tile 3x2 -geometry 400x225+3+3 -background "#05070e" /tmp/pool_sheet.png
identify /tmp/pool_sheet.png | grep -oE "[0-9]+x[0-9]+" | head -1
