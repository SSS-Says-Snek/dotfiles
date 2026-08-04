import QtQuick
import QtQuick.Shapes

Rectangle {
    id: root
    anchors.fill: parent
    radius: width / 2
    color: "#a0181825"

    property color baseColor
    property color accentColor
    property int ringRadius
    property int thickness

    property int startAngle: 0
    property int sweep: 360

    property real progress: 0.0

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: true

        ShapePath {
            strokeColor: root.baseColor
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
            strokeColor: root.progress > 0 ? root.accentColor : "transparent"
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: root.startAngle
                sweepAngle: root.sweep * root.progress

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
