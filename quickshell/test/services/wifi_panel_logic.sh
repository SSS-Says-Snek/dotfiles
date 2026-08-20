#!/usr/bin/env bash

# Script taken/modified from ilamiro: https://github.com/ilyamiro/serpantinum/blob/master/config/sessions/hyprland/scripts/quickshell/network/wifi_panel_logic.sh
# (too lazy to write)

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "$SCRIPT_DIR/caching.sh"
qs_ensure_cache "network"

# Zero-latency hardware presence check via sysfs (Instant, no nmcli hang)
if ! ls -1d /sys/class/net/*/wireless &>/dev/null; then
    echo '{ "present": false, "power": "off", "connected": null, "networks": [] }'
    exit 0
fi

POWER=$(LC_ALL=C nmcli radio wifi)

if [[ "$POWER" == "disabled" ]]; then
    echo '{ "present": true, "power": "off", "connected": null, "networks": [] }'
    exit 0
fi

get_icon() {
    local signal=$1
    if [[ $signal -ge 80 ]]; then echo "4";
    elif [[ $signal -ge 60 ]]; then echo "3";
    elif [[ $signal -ge 40 ]]; then echo "2";
    elif [[ $signal -ge 20 ]]; then echo "1";
    else echo "0"; fi
}

CACHE_DIR="$QS_CACHE_NETWORK"
mkdir -p "$CACHE_DIR"

# Saved Wi-Fi profiles. NM names a connection after its SSID by default;
# that NAME is what we match against scanned SSIDs.
SAVED_SSIDS=$(LC_ALL=C nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '
    $2 == "802-11-wireless" || $2 == "wifi" { print $1 }
')
export SAVED_SSIDS

ssid_is_saved() {
    [[ -n "$1" ]] && grep -Fxq -- "$1" <<<"$SAVED_SSIDS"
}

CURRENT_RAW=$(LC_ALL=C nmcli -t -f active,ssid,signal,security device wifi | awk -F: '$1=="yes"{print; exit}')

if [[ -n "$CURRENT_RAW" ]]; then
    IFS=':' read -r active ssid signal security <<< "$CURRENT_RAW"
    icon=$(get_icon "$signal")
    
    SAFE_SSID="${ssid//[^a-zA-Z0-9]/_}"
    CACHE_FILE="$CACHE_DIR/wifi_$SAFE_SSID"
    
    if [ -f "$CACHE_FILE" ]; then
        source "$CACHE_FILE"
    fi
    
    if [ -z "$IP" ] || [ "$IP" == "No IP" ] || [ -z "$FREQ" ]; then
        IFACE=$(LC_ALL=C nmcli -t -f DEVICE,TYPE d | awk -F: '$2=="wifi"{print $1;exit}')
        IP=$(ip -4 addr show dev "$IFACE" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
        [ -z "$IP" ] && IP="No IP"
        
        FREQ=$(iw dev "$IFACE" link 2>/dev/null | awk '/freq:/ {print $2}')
        [ -n "$FREQ" ] && FREQ="${FREQ} MHz" || FREQ="Unknown"
        
        echo "IP=\"$IP\"" > "$CACHE_FILE"
        echo "FREQ=\"$FREQ\"" >> "$CACHE_FILE"
    fi

    # Native Bash JSON generation
    ssid_esc="${ssid//\"/\\\"}"
    sec_esc="${security//\"/\\\"}"
    icon_esc="${icon//\"/\\\"}"
    saved_json=$(ssid_is_saved "$ssid" && echo true || echo false)
    CONNECTED_JSON="{\"id\":\"$ssid_esc\",\"ssid\":\"$ssid_esc\",\"icon\":\"$icon_esc\",\"signal\":\"$signal\",\"security\":\"$sec_esc\",\"ip\":\"$IP\",\"freq\":\"$FREQ\",\"saved\":$saved_json}"
else
    ssid=""
    CONNECTED_JSON="null"
fi

# AWK processes the entire network list natively, zero sub-shells
# Reverted back to SSID-only deduplication, but passing conn="$ssid" to cleanly exclude the connected network
NETWORKS_JSON=$(LC_ALL=C nmcli -t -f active,ssid,signal,security device wifi list --rescan no | awk -F: -v conn="$ssid" '
    BEGIN {
        n = split(ENVIRON["SAVED_SSIDS"], arr, "\n")
        for (i = 1; i <= n; i++)
            if (arr[i] != "")
                saved[arr[i]] = 1
    }
    $2 != "" && $2 != conn && !seen[$2]++ {
        ssid=$2; signal=$3; security=$4;
        is_saved = (ssid in saved) ? "true" : "false"

        gsub(/"/, "\\\"", ssid);
        gsub(/"/, "\\\"", security);

        if (signal >= 80) icon="4";
        else if (signal >= 60) icon="3";
        else if (signal >= 40) icon="2";
        else if (signal >= 20) icon="1";
        else icon="0";

        printf "{\"id\":\"%s\",\"ssid\":\"%s\",\"icon\":\"%s\",\"signal\":\"%s\",\"security\":\"%s\",\"saved\":%s}\n", ssid, ssid, icon, signal, security, is_saved
    }
' | head -n 24 | paste -sd, -)

if [ -z "$NETWORKS_JSON" ]; then
    NETWORKS_JSON="[]"
else
    NETWORKS_JSON="[$NETWORKS_JSON]"
fi

# Final JSON output
echo "{\"present\":true,\"power\":\"on\",\"connected\":$CONNECTED_JSON,\"networks\":$NETWORKS_JSON}"
