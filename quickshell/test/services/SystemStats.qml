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

    readonly property string username: Quickshell.env("USER")
    readonly property string wm: Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("XDG_SESSION_DESKTOP")

    property string hostname
    property string uptime
    property int osAge

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

                if (mount === "/") {
                    root.rootDisk = obj
                }
            }
        }
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"

        onLoaded: {
            const data = text()

            root.memTotal = Number(data.match(/MemTotal: *(\d+)/)?.[1] ?? 1)
            root.memAvailable = Number(data.match(/MemAvailable: *(\d+)/)?.[1] ?? 0)
            root.memPercent = (1.0 - root.memAvailable / root.memTotal) * 100.0
        }
    }

    FileView {
        id: cpuFile
        path: "/proc/stat"

        onLoaded: {
            const cpuLine = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/)
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number)
                const total = stats.reduce((a, b) => a + b, 0)
                const idle = stats[3]

                if (root.previousCpuStats) {
                    const totalDiff = total - root.previousCpuStats.total
                    const idleDiff = idle - root.previousCpuStats.idle
                    const cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0
                    root.cpuPercent = cpuUsage * 100.0
                }

                root.previousCpuStats = { total: total, idle: idle }
            }
        }
    }

    FileView {
        id: tempFile
        path: root.tempMonitor

        onLoaded: root.cpuTemp = parseInt(text()) / 1000
    }

    Timer {
        running: true
        interval: 2000
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            memFile.reload()
            cpuFile.reload()
            tempFile.reload()
        }
    }

    // df is the one reading that still needs a process, and disk usage moves slowly
    // enough that once a minute is plenty.
    Timer {
        running: true
        interval: 60000
        repeat: true
        triggeredOnStart: true

        onTriggered: diskProc.running = true
    }

    FileView {
        path: "/proc/sys/kernel/hostname"
        onLoaded: root.hostname = text().trim()
    }

    FileView {
        id: fileUptime

        path: "/proc/uptime"
        onLoaded: {
            const up = parseInt(text().split(" ")[0] ?? 0);

            const days = Math.floor(up / 86400);
            const hours = Math.floor((up % 86400) / 3600);
            const minutes = Math.floor((up % 3600) / 60);

            let str = "";
            if (days > 0)
                str += `${days} day${days === 1 ? "" : "s"}`;
            if (hours > 0)
                str += `${str ? ", " : ""}${hours} hr${hours === 1 ? "" : "s"}`;
            if ((minutes > 0 || !str) && !(days > 0 && hours > 0))
                str += `${str ? ", " : ""}${minutes} min${minutes === 1 ? "" : "s"}`;
            root.uptime = str;
        }
    }
}
