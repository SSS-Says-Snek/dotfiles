pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool hasLoaded: false

    property string weather_api_key: jsonConfig.weather_api_key
    property string weather_location: jsonConfig.weather_location
    property real latitude: jsonConfig.latitude
    property real longitude: jsonConfig.longitude

    FileView {
        id: jsonReader
        path: Quickshell.shellPath(".env")
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: jsonConfig

            property string weather_api_key: ""
            property string weather_location: ""
            property real latitude: 0.0
            property real longitude: 0.0
        }

        onLoaded: root.hasLoaded = true
    }
}
