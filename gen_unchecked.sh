#!/bin/bash
# unchecked.txt 格式是 "n res" 两列 —— URL 在第三列被截断丢失了。重新生成完整三列
export https_proxy=http://127.0.0.1:10808 http_proxy=http://127.0.0.1:10808
python3 - <<'PYEOF' > /tmp/unchecked2.txt
import json, urllib.request, os
os.environ['https_proxy'] = 'http://127.0.0.1:10808'
in_theme = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
for page in (1, 2, 3):
    url = f"https://wallhaven.cc/api/v1/search?q=starcraft&categories=100&purity=100&sorting=favorites&atleast=2560x1440&page={page}"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    d = json.load(urllib.request.urlopen(req, timeout=30))
    for w in d.get('data', []):
        res = w.get('resolution', '')
        try:
            ww, hh = map(int, res.split('x'))
        except Exception:
            continue
        if ww < 2560 or ww / hh <= 1.5:
            continue
        # 用下载序号（favorites 排序全局位置）判断
        idx = None
        print(f"{w['path']}\t{res}\t{w.get('favorites', 0)}")
PYEOF
sort -t$'\\t' -k3 -rn /tmp/unchecked2.txt | head -20 | awk -F'\\t' '{print NR, $1, $2, $3}' > /tmp/unchecked3.txt
cat /tmp/unchecked3.txt | cut -c1-90
