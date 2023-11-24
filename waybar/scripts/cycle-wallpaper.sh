#/bin/bash

dir="$HOME/wallpapers"

# wallpaper="$(find $dir -name '*.jpg' -o -name '*.png' -o -name '*.gif' | shuf -n1)"
wallpaper="$(find $dir -name '*.jpg' -o -name '*.png'| shuf -n1)"
swww img "$wallpaper" -t "any"
