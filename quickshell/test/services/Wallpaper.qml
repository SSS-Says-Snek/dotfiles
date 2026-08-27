pragma Singleton

import QtQml
import Quickshell
import Quickshell.Io

// Too lazy to write quickshell so I'm just gonna offload ts to the current rofi setup
Singleton {
    id: root

    readonly property string _forceload: "yogurt"

    function cycleWallpaper() {
        wallpaperProc.running = true
    }

    function selectWallpaper() {
        selectWallpaperProc.running = true
    }

    Timer {
        id: cycleTimer
        interval: 60000 * 5
        running: true
        repeat: true
        onTriggered: {
            console.log("ey")
            root.cycleWallpaper()
        }
    }

    Process {
        id: wallpaperProc
        command: ["bash", Quickshell.shellPath("services/cycle-wallpaper.sh")]
        running: true
    }

    Process {
        id: selectWallpaperProc
        command: ["bash", Quickshell.shellPath("services/select-wallpaper.sh")]
    }
}
