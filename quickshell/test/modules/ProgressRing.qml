import QtQuick
import QtQuick.Shapes

import qs.settings

Rectangle {
    id: root

    anchors.fill: parent
    radius: width / 2
    color: transparentBg ? "transparent" : Theme.dashboardBg

    property color baseColor
    property color accentColor
    property int ringRadius
    property int thickness

    property int startAngle: 0
    property int sweep: 360

    property int baseStartAngle: startAngle
    property int baseSweep: sweep

    property real progress: 0.0
    property bool transparentBg: false
    property bool interactive: false

    // Emitted while scrubbing; value is clamped to [0, 1] along the arc.
    signal moved(real value)

    property bool dragging: false
    property real dragProgress: 0

    readonly property real visualProgress: dragging ? dragProgress : Math.max(0, Math.min(1, progress))

    function normDeg(deg) {
        deg %= 360
        if (deg < 0)
            deg += 360
        return deg
    }

    function angleAt(px, py) {
        const cx = width / 2
        const cy = height / 2
        return Math.atan2(py - cy, px - cx) * 180 / Math.PI
    }

    function progressFromPoint(px, py) {
        const deg = angleAt(px, py)
        const absSweep = Math.abs(root.sweep)

        if (absSweep < 0.001)
            return 0

        let delta
        if (root.sweep >= 0)
            delta = normDeg(deg - root.startAngle)
        else
            delta = normDeg(root.startAngle - deg)

        if (delta > absSweep)
            return (delta - absSweep) < (360 - delta) ? 1 : 0

        return delta / absSweep
    }

    function isOnRing(px, py) {
        const cx = width / 2
        const cy = height / 2
        const dx = px - cx
        const dy = py - cy
        const dist = Math.sqrt(dx * dx + dy * dy)
        const absSweep = Math.abs(root.sweep)
        const deg = angleAt(px, py)

        if (Math.abs(dist - root.ringRadius) > Math.max(root.thickness * 1.5, 16)) // tolerance
            return false

        // How far along the sweep direction from startAngle to this point.
        const delta = root.sweep >= 0 ? normDeg(deg - root.startAngle) : normDeg(root.startAngle - deg)
        return delta <= absSweep
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        asynchronous: true

        ShapePath {
            strokeColor: root.baseColor
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: root.baseStartAngle
                sweepAngle: root.baseSweep
            }
        }

        ShapePath {
            strokeColor: root.visualProgress > 0 ? root.accentColor : "transparent"
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.ringRadius
                radiusY: root.ringRadius
                startAngle: root.startAngle
                sweepAngle: root.sweep * root.visualProgress

                Behavior on sweepAngle {
                    enabled: !root.dragging && !root.interactive
                    NumberAnimation {
                        duration: 600
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on strokeColor {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: true

        cursorShape: containsMouse && root.isOnRing(mouseX, mouseY) ? Qt.PointingHandCursor : Qt.ArrowCursor

        onPressed: mouse => {
            if (!root.isOnRing(mouse.x, mouse.y)) {
                mouse.accepted = false
                return
            }

            root.dragging = true
            root.dragProgress = root.progressFromPoint(mouse.x, mouse.y)
            root.moved(root.dragProgress)
        }

        onPositionChanged: mouse => {
            if (!root.dragging)
                return
            root.dragProgress = root.progressFromPoint(mouse.x, mouse.y)
            root.moved(root.dragProgress)
        }

        onReleased: {
            if (!root.dragging)
                return
            root.dragging = false
        }

        onCanceled: root.dragging = false

        // This MouseArea sits above CenterPopup's wheel catcher; forward scrolls
        // so the dashboard wheel still spins while the pointer is over the ring.
        onWheel: event => {
            for (let p = root.parent; p; p = p.parent) {
                if (typeof p.scroll === "function") {
                    p.scroll(event.angleDelta.y)
                    event.accepted = true
                    return
                }
            }
        }
    }
}
