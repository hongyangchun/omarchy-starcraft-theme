#!/bin/bash
# 下载全部未核验候选（13张）到 /tmp/sc1_check 供逐一目检
export https_proxy=http://127.0.0.1:10808 http_proxy=http://127.0.0.1:10808
mkdir -p /tmp/sc1_check
while read -r n res url; do
  ext="${url##*.}"
  curl -sL "$url" -o "/tmp/sc1_check/cand-$n.$ext" -w "$n: %{http_code} %{size_download}B\n" --max-time 120
done < /tmp/unchecked.txt
cd /tmp/sc1_check
ls | wc -l
