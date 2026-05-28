pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string tempMonitor: "/sys/class/thermal/thermal_zone4/temp"

    property real cpuPercent: 0

    property int cpuTemp: 0
    property var previousCpuStats

    property real memAvailable: 0
    property real memTotal: 0
    property real memPercent: 0

    property var rootDisk: ({
        bg: "",
        name: "",
        mount: "",
        total: "",
        used: "",
        free: "",
        percent: 0,
        percentText: "0%"
    })

    Process {
        id: diskProc
        command: ["df", "-k"] // KB blocks

        property var accumulatedLines: []

        stdout: SplitParser {
            onRead: (data) => {
                diskProc.accumulatedLines.push(data)
            }
        }

        onExited: (code, status) => {
            let lines = diskProc.accumulatedLines
            diskProc.accumulatedLines = [] // Reset

            let sys = []
            let usr = []
            let spc = []

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim()
                if (line === "" || line.startsWith("Filesystem")) continue // Omit first header 

                const parts = line.split(/\s+/)
                if (parts.length < 6) continue

                const fs = parts[0]
                const total = parseInt(parts[1]) * 1024
                const used = parseInt(parts[2]) * 1024
                const avail = parseInt(parts[3]) * 1024
                const percent = parts[4] 
                const mount = parts[5]

                const obj = {
                    bg: fs, 
                    name: fs,
                    mount: mount,
                    total: total,
                    used: used,
                    free: avail,
                    percent: parseInt(percent.replace("%","")) / 100.0,
                    percentText: percent
                }

                // if (fs === "tmpfs" || fs === "devtmpfs" || fs === "efivarfs" || fs === "none" || fs === "overlay" || fs === "squashfs") {
                //     spc.push(obj)
                // } else if (mount === "/" || mount.startsWith("/boot") || mount.startsWith("/home") || mount.startsWith("/usr") || mount.startsWith("/var")) {
                //     sys.push(obj)
                // } else if (mount.startsWith("/run") || mount.startsWith("/sys") || mount.startsWith("/dev")) {
                //     spc.push(obj)
                // } else {
                //     usr.push(obj)
                // }

                if (mount === "/") {
                    rootDisk = obj
                }
            }
        }
    }
    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                memTotal = Number(text.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
                memAvailable = Number(text.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
                memPercent = (1.0 - memAvailable / memTotal) * 100.0
            }
        }
    }

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const cpuLine = text.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
                if (cpuLine) {
                    const stats = cpuLine.slice(1).map(Number)
                    const total = stats.reduce((a, b) => a + b, 0)
                    const idle = stats[3]

                    if (previousCpuStats) {
                        const totalDiff = total - previousCpuStats.total
                        const idleDiff = idle - previousCpuStats.idle
                        const cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                        cpuPercent = cpuUsage * 100.0
                    }

                    previousCpuStats = { total: total, idle: idle }
                }
            }
        }
    }

    Process {
        id: tempProc
        command: ["cat", tempMonitor]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                cpuTemp = parseInt(text) / 1000
            }
        }
    }

    Timer {
        running: true
        interval: 1
        repeat: true
        onTriggered: {
            memProc.running = true
            cpuProc.running = true
            diskProc.running = true
            tempProc.running = true

            interval = 2000
        }
    }
}
