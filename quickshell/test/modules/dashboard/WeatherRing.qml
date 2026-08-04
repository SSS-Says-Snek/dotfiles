import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import qs.settings
import qs.services

Item {
    id: root

    // Deg F
    property real minTemp: 0
    property real maxTemp: 110
    property real thickness: 24

    readonly property real temp: parseFloat(Weather.data.temp)
    readonly property bool hasReading: !isNaN(temp)
    readonly property real progress: hasReading ? Math.max(0, Math.min(1, (temp - minTemp) / (maxTemp - minTemp))) : 0

    readonly property real ringRadius: (Math.min(width, height) - thickness) / 2

    // Lerp the hues
    readonly property color tempColor: {
        const stops = [[0, Theme.sapphire], [0.6, Theme.green], [0.8, Theme.yellow], [1, Theme.red]];

        for (let i = 1; i < stops.length; i++)
            if (progress <= stops[i][0])
                return mix(stops[i - 1][1], stops[i][1], (progress - stops[i - 1][0]) / (stops[i][0] - stops[i - 1][0]));

        return stops[stops.length - 1][1];
    }

    function mix(from, to, t) {
        const a = Qt.color(from);
        const b = Qt.color(to);

        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#a0181825"

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            asynchronous: true

            ShapePath {
                strokeColor: Theme.surface0
                strokeWidth: root.thickness
                fillColor: "transparent"

                PathAngleArc {
                    centerX: root.width / 2
                    centerY: root.height / 2
                    radiusX: root.ringRadius
                    radiusY: root.ringRadius
                    startAngle: -90
                    sweepAngle: 360
                }
            }

            ShapePath {
                strokeColor: root.progress > 0 ? root.tempColor : "transparent"
                strokeWidth: root.thickness
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.width / 2
                    centerY: root.height / 2
                    radiusX: root.ringRadius
                    radiusY: root.ringRadius
                    startAngle: -180
                    sweepAngle: 270 * root.progress

                    Behavior on sweepAngle {
                        NumberAnimation {
                            duration: 600
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        spacing: -5

        ColumnLayout {
            Layout.alignment:  Qt.AlignHCenter
            spacing: -2
            z: 1

            Text {
                Layout.alignment:  Qt.AlignHCenter
                text: Math.round(Weather.data.temp) + "°F"
                color: root.tempColor

                font {
                    family: Theme.font
                    pixelSize: 14
                }
            }

            Text {
                Layout.alignment:  Qt.AlignHCenter
                text: Weather.text
                color: root.tempColor

                font {
                    family: Theme.font
                    pixelSize: 14
                }
            }
        }

        Text {
            Layout.alignment:  Qt.AlignHCenter
            text: Weather.icon
            color: root.tempColor

            font {
                family: Theme.font
                pixelSize: Math.round(Math.min(root.width, root.height) * 0.40)
            }
        }

    }
}
