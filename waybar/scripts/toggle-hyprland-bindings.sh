#!/bin/bash

STATE_FILE="/tmp/waybar_keybind_toggle_state"

if [ "$1" == "toggle" ]; then
    output=$(hyprctl submap)
    if [[ "$output" == "default" ]]; then
        hyprctl dispatch 'hl.dsp.submap("clean")' && notify-send "Hyprland bindings disabled" "Press SUPER+x to enable again" --icon="/home/bdon/Icons/alt.svg"
    else
        hyprctl dispatch 'hl.dsp.submap("reset")' && notify-send "Hyprland bindings enabled" "Press SUPER+x to disable again" --icon="/home/bdon/Icons/alt.svg"
    fi

    if [ "$(cat $STATE_FILE)" == '{"text": "on", "class": "on"}' ]; then
        echo '{"text": "off", "class": "off"}' > "$STATE_FILE"
    else
        echo '{"text": "on", "class": "on"}' > "$STATE_FILE"
    fi

    pkill -RTMIN+8 waybar
elif [ "$1" == "status" ]; then
    if [ ! -f "$STATE_FILE" ]; then
        echo '{"text": "on", "class": "on"}' > "$STATE_FILE"
    fi
    echo "$(cat $STATE_FILE)"
fi
