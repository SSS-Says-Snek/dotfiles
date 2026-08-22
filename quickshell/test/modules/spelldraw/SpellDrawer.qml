import QtQuick
import QtQuick.Layouts

import "js/SpellParser.js" as SpellParser
import "js/SpellDispatcher.js" as SpellDispatcher

import Quickshell.Io

import qs.settings

Item {
    id: root

    signal closeRequested

    function registerHook(hookId, fn) {
        SpellDispatcher.registerHook(hookId, fn)
    }

    onVisibleChanged: if (visible) {
        clearCanvas()
        canvas.forceActiveFocus()
    }

    function clearCanvas() {
        strokes = []
        currentStroke = []
        prevRing = null
        glyphAST = null
        matchResult = null

        ringPct = 0
        canvas.requestPaint()
    }

    property var strokes: []      // Array<Array<{x,y}>>
    property var currentStroke: []
    property var glyphAST: null
    property var matchResult: null
    property var prevRing: null
    property bool isDrawing: false
    property bool dictionaryLoaded: false

    property real ringPct: 0

    property var sigilDict: []
    property var signDict: []
    property var spellDictionary: null

    // Info panel
    ColumnLayout {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.rightMargin: 10

        InfoRow {
            Layout.alignment: Qt.AlignRight
            visible: root.ringPct != 0
            icon: "mat-circle"
            text: `${root.ringPct}% Complete`
            color: Theme.mauve
        }

        InfoRow {
            Layout.alignment: Qt.AlignRight
            visible: root.glyphAST && root.glyphAST.primarySigil

            icon: root.glyphAST && root.glyphAST.primarySigil ? `sigils/${root.glyphAST.primarySigil.id.toLowerCase()}` : "sigils/fire"
            text: root.glyphAST && root.glyphAST.primarySigil ? `${root.glyphAST.primarySigil.id} (${(root.glyphAST.primarySigil.confidence * 100).toFixed(0)}%)` : ""
            color: {
                if (!visible) {
                    return Theme.mauve
                }
                const sigil = root.glyphAST.primarySigil.id.toLowerCase()
                if (sigil == "fire") {
                    return Theme.red
                } else if (sigil == "water") {
                    return Theme.blue
                } else if (sigil == "wind") {
                    return Theme.sapphire
                } else if (sigil == "light") {
                    return Theme.yellow
                } else if (sigil == "earth") {
                    return Theme.peach
                }
            }
        }

        InfoRow {
            Layout.alignment: Qt.AlignRight
            visible: root.glyphAST && root.glyphAST.signs.length > 0
            icon: "tabler-scribble"
            text: {
                if (!visible) {
                    return ""
                }
                const numSigns = root.glyphAST.signs.length
                return `${numSigns} ${numSigns == 1 ? "sign" : "signs"}`
            }
            color: Theme.sapphire
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        focus: true

        onPaint: {
            let ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.lineCap = "round"
            ctx.lineJoin = "round";

            // Draw user non-ring + ring strokes
            let ringIdxSet = {}
            if (root.glyphAST && root.glyphAST.ring.found && root.glyphAST.ring.strokeIndices) {
                let ridx = root.glyphAST.ring.strokeIndices
                for (let ri = 0; ri < ridx.length; ri++)
                    ringIdxSet[ridx[ri]] = true
            }

            for (let s = 0; s < root.strokes.length; s++) {
                let stroke = root.strokes[s]
                if (!stroke || stroke.length < 2)
                    continue
                let isRingStroke = !!ringIdxSet[s]
                ctx.beginPath()
                ctx.moveTo(stroke[0].x, stroke[0].y)
                for (let p = 1; p < stroke.length; p++)
                    ctx.lineTo(stroke[p].x, stroke[p].y)

                if (isRingStroke) {
                    let closed = root.glyphAST.ring.complete
                    ctx.strokeStyle = closed ? Qt.alpha(Theme.green, 0.5) : Qt.alpha(Theme.peach, 0.5)
                    ctx.lineWidth = 2.8
                    ctx.globalAlpha = 0.75
                } else {
                    ctx.strokeStyle = Theme.text
                    ctx.lineWidth = 2.4
                    ctx.globalAlpha = 0.82
                }
                ctx.stroke()
                ctx.globalAlpha = 1.0
            }

            // Current stroke
            if (root.currentStroke.length > 1) {
                ctx.beginPath()
                ctx.moveTo(root.currentStroke[0].x, root.currentStroke[0].y)
                for (let q = 1; q < root.currentStroke.length; q++)
                    ctx.lineTo(root.currentStroke[q].x, root.currentStroke[q].y)
                ctx.strokeStyle = Theme.mauve
                ctx.lineWidth = 2.4
                ctx.globalAlpha = 0.90
                ctx.stroke()
                ctx.globalAlpha = 1.0
            }

            if (root.glyphAST && root.glyphAST.ring.found) {
                let ring = root.glyphAST.ring
                let rcx = ring.center.x
                let rcy = ring.center.y
                let rr = ring.radius
                let neat = ring.neatness || 0;

                // Outer ring ghost circle
                ctx.beginPath()
                ctx.arc(rcx, rcy, rr, 0, 2 * Math.PI)
                if (ring.complete) {
                    ctx.strokeStyle = "rgba(" + Math.round(120 + neat * 100) + "," + Math.round(200 + neat * 55) + "," + Math.round(180 + neat * 60) + ",0.35)"
                    ctx.lineWidth = 1.8
                    ctx.setLineDash([])
                } else {
                    ctx.strokeStyle = Qt.alpha(Theme.peach, 0.3)
                    ctx.lineWidth = 1.4
                    ctx.setLineDash([10, 7])
                }
                ctx.stroke()
                ctx.setLineDash([]);

                // Crosshair
                ctx.strokeStyle = ring.complete ? Qt.alpha(Theme.green, 0.5) : Qt.alpha(Theme.peach, 0.5)
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.moveTo(rcx - 6, rcy)
                ctx.lineTo(rcx + 6, rcy)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(rcx, rcy - 6)
                ctx.lineTo(rcx, rcy + 6)
                ctx.stroke();

                // Layer boundaries (e.g center/middle/out)
                if (ring.complete) {
                    for (let lr = 0; lr < 2; lr++) {
                        let lrFrac = lr === 0 ? 0.30 : 0.68
                        ctx.beginPath()
                        ctx.arc(rcx, rcy, rr * lrFrac, 0, 2 * Math.PI)
                        ctx.strokeStyle = Qt.alpha(Theme.mauve, 0.2)
                        ctx.lineWidth = 1
                        ctx.setLineDash([4, 5])
                        ctx.stroke()
                        ctx.setLineDash([])
                    }

                    let pen = ring.floodPenetration || 0
                    if (pen > 0.01) {
                        ctx.beginPath()
                        ctx.arc(rcx, rcy, rr * 0.20, 0, 2 * Math.PI)
                        ctx.fillStyle = "rgba(240,80,60," + (pen * 0.4) + ")"
                        ctx.fill()
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: function (mouse) {
                if (mouse.button === Qt.RightButton) {
                    root.clearCanvas()
                    return
                }
                root.isDrawing = true
                root.currentStroke = [
                    {
                        x: mouse.x,
                        y: mouse.y
                    }
                ]
                canvas.requestPaint()
            }

            onPositionChanged: function (mouse) {
                if (!root.isDrawing)
                    return
                root.currentStroke.push({
                    x: mouse.x,
                    y: mouse.y
                })
                root.currentStroke = root.currentStroke // Trigger ts binding
                canvas.requestPaint()
            }

            onReleased: function (mouse) {
                if (!root.isDrawing)
                    return
                root.isDrawing = false
                if (root.currentStroke.length > 1) {
                    root.strokes.push(root.currentStroke)
                    root.strokes = root.strokes
                    root.currentStroke = [] // Trigger ts binding (slowed + reverb)
                    root.runParser()
                }
            }

            onDoubleClicked: function (mouse) {
                root.dispatchSpell()
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Space && root.glyphAST) {
                console.log(JSON.stringify(root.glyphAST, null, 2))
                event.accepted = true
            }
        }
    }

    function runParser() {
        if (!root.dictionaryLoaded)
            return
        if (root.strokes.length === 0)
            return

        let ast = SpellParser.parse(root.strokes, root.sigilDict, root.signDict, root.prevRing)
        root.prevRing = ast.ring
        root.glyphAST = ast

        updateStatus(ast);

        if (ast.ring.activationEvent) {
            root.ringPct = 100
            castTimer.restart()
        }

        canvas.requestPaint()
    }

    function updateStatus(ast) {
        if (!ast.ring.found) {
            // Nothing happens
            return
        }
        if (!ast.ring.complete) {
            let pct = (ast.ring.coverageRatio * 100).toFixed(0);
            // let gap = ast.ring.gapDeg.toFixed(0)
            // let pen = (ast.ring.floodPenetration * 100).toFixed(0)
            root.ringPct = pct
            return
        }
    }

    function dispatchSpell() {
        if (!root.glyphAST || !root.spellDictionary)
            return
        let match = SpellDispatcher.matchSpell(root.glyphAST, root.spellDictionary)
        root.matchResult = match

        if (match) {
            SpellDispatcher.dispatchHook(match, root.glyphAST)
            canvas.requestPaint()
            closeTimer.restart()
        } else {
            canvas.requestPaint()
        }
    }

    Timer {
        id: castTimer
        interval: 380
        repeat: false
        onTriggered: root.dispatchSpell()
    }

    Timer {
        id: closeTimer
        interval: 1400
        repeat: false
        onTriggered: root.closeRequested()
    }

    Component.onCompleted: root.dictionaryLoaded = true

    FileView {
        path: Qt.resolvedUrl("sigils.json")
        onLoaded: {
            root.sigilDict = JSON.parse(this.text())
        }
    }

    FileView {
        path: Qt.resolvedUrl("signs.json")
        onLoaded: {
            root.signDict = JSON.parse(this.text())
        }
    }

    FileView {
        path: Qt.resolvedUrl("spell_dictionary.json")
        onLoaded: {
            root.spellDictionary = JSON.parse(this.text())
        }
    }
}
