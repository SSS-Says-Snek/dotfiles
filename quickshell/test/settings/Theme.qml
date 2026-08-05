pragma Singleton
import QtQuick
import Quickshell.Io

FileView {
    id: root
    watchChanges: true
    onFileChanged: reload()

    property string accent: "#b4befe"
    property string mauve: "#cba6f7"
    property string sapphire: "#74c7ec"
    property string blue: "#89b4fa"
    property string yellow: "#f9e2af"
    property string peach: "#fab387"
    property string red: "#f38ba8"
    property string green: "#a6e3a1"
    property string text: "#cdd6f4"
    property string subtext: "#a6adc8"
    property string overlay2: "#9399b2"
    property string overlay1: "#7f849c"
    property string overlay0: "#6c7086"
    property string surface2: "#585b70"
    property string surface1: "#45475a"
    property string surface0: "#313244"
    property string base: "#1e1e2e"
    property string mantle: "#181825"
    property string crust: "#11111b"

    property string dashboardBg: "#a0181825"

    property int barHeight: 32
    property string font: "Firacode Nerd Font"

}
