#!/bin/bash
# 拼新 6 张目检 + 4K 放大管线
D=/tmp/sc1_dark
magick montage $D/dark-*.jpg -tile 3x2 -geometry 480x270+3+3 -background "#05070e" /tmp/sc1_dark_sheet.png
identify /tmp/sc1_dark_sheet.png | grep -oE "[0-9]+x[0-9]+" | head -1
