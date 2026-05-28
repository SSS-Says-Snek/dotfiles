pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import qs.settings

Singleton {
    id: root

    readonly property int refreshInterval: 120 * 1000

    property string outputBuffer: ""

    property var data: ({
        temp: "∞",
        weatherCode: "113"
    })

    function processData(text) {
        console.log(text)
        var dummy = {}
        var json = JSON.parse(text)
        dummy.temp = json.current.temp_f

        root.data = dummy
        console.log(data.temp)
    }

    Process {
        id: weatherProc

        command: ["curl", "-s", "-f", "https://api.weatherapi.com/v1/current.json?key=" + Env.weather_api_key + "&q=" + Env.weather_location + "&aqi=no"]
        running: Env.hasLoaded

        stdout: StdioCollector {
            onStreamFinished: root.processData(this.text)
        }
    }

    Timer {
        interval: root.refreshInterval
        running: true
        repeat: true
        onTriggered: weatherProc.running = true
    }
}
