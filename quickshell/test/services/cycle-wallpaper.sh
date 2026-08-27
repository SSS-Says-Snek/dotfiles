#/bin/bash

dir="$HOME/wallpapers"

echo "hey"

# wallpaper="$(find $dir -name '*.jpg' -o -name '*.png' -o -name '*.gif' | shuf -n1)"
wallpaper="$(find $dir -maxdepth 1 -name '*.jpg' -o -name '*.png' -o -name '*.gif' | shuf -n1)"
awww img "$wallpaper" -t "random"
