pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool hasLoaded: false

    property string weather_api_key: jsonConfig.weather_api_key
    property string weather_location: jsonConfig.weather_location

    FileView {
        id: jsonReader
        path: ".env"
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: jsonConfig

            property string weather_api_key: ""
            property string weather_location: ""
        }

        onLoaded: root.hasLoaded = true
    }
}
