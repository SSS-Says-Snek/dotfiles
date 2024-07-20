# Options
hibernate='󰒲'
shutdown=''
reboot='󰜉'
lock=''
log='󰍃'
yes=''
no=''

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-theme ~/.config/rofi/power-menu.rasi
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {margin: 0px; background-color: @background-alt; children: [ "message", "listview" ];}' \
		-theme-str 'listview {spacing: 0px; columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ~/.config/rofi/power-menu.rasi
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$log\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
}

chosen="$(run_rofi)"
if ! [[ $chosen ]]; then
  exit 0
fi

case ${chosen} in
    $shutdown)
    confirm_exit
    systemctl poweroff
        ;;
    $reboot)
    confirm_exit
    systemctl reboot
        ;;
    $lock)
      echo "TODO"
        ;;
    $log)
      confirm_exit
      hyprctl dispatch exit
        ;;
esac
