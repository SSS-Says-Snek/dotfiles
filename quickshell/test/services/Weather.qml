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
        weatherCode: 1000,
        isDay: true
    })

    readonly property string icon: codeToIcon(data.weatherCode, data.isDay)

    function processData(text) {
        var dummy = {}
        var json = JSON.parse(text)
        dummy.temp = json.current.temp_f
        dummy.weatherCode = json.current.condition.code
        dummy.isDay = json.current.is_day === 1

        root.data = dummy
    }

    // https://www.weatherapi.com/docs/weather_conditions.json
    function codeToIcon(code, isDay) {
        const fog = [1030, 1135, 1147];
        const thunder = [1087, 1273, 1276, 1279, 1282];
        const snow = [1066, 1114, 1117, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258];
        const sleet = [1069, 1072, 1168, 1171, 1198, 1201, 1204, 1207, 1237, 1249, 1252, 1261, 1264];

        if (code === 1000)
            return isDay ? "\ue30d" : "\ue32b";
        if (code === 1003)
            return isDay ? "\ue302" : "\ue379";
        if (code === 1006 || code === 1009)
            return "\ue312";
        if (fog.includes(code))
            return "\ue313";
        if (thunder.includes(code))
            return "\ue31d";
        if (snow.includes(code))
            return "\ue31a";
        if (sleet.includes(code))
            return "\ue3ad";
        // Everything left above the clear/cloudy codes is drizzle, rain or showers.
        if (code >= 1063)
            return "\ue318";

        return "\ue374";
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
