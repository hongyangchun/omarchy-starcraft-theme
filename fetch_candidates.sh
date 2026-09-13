#!/bin/bash
# 下载 38 张池中未核验的候选（排除已用的 1,4,7,8,11,13,16,17,22,23,24 等）
export https_proxy=http://127.0.0.1:10808 http_proxy=http://127.0.0.1:10808
mkdir -p /tmp/sc1_check
SKIP="1 4 5 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24"
i=0
tail -n +2 /tmp/unchecked3.txt | while read -r idx url res fav; do
  case " $SKIP " in
    *" $idx "*) continue ;;
  esac
  i=$((i+1))
  ext="${url##*.}"
  curl -sL "$url" -o "/tmp/sc1_check/cand-$idx.$ext" -w "$idx: %{http_code} %{size_download}B\n" --max-time 120
done
ls /tmp/sc1_check | wc -l
