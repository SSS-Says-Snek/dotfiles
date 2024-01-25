import QtQuick 2.12
import QtQuick.Controls 2.12

TextField {
  id: passwordField
  focus: true
  selectByMouse: true
  placeholderText: "Password"
  echoMode: TextInput.Password
  passwordCharacter: "•"
  passwordMaskDelay: 1000
  selectionColor: config.overlay0
  renderType: Text.NativeRendering
  font.family: config.Font
  font.pointSize: config.FontSize
  font.bold: true
  color: config.text
  horizontalAlignment: TextInput.AlignHCenter

  background: Rectangle {
    id: passFieldBackground
    radius: 8
    color: config.base

    border {
      color: config.surface1
      width: 2
    }
  }

  Image {
    source: Qt.resolvedUrl("../icons/password.svg")
    id: icon
    anchors.verticalCenter: parent.verticalCenter
    x: 10 

    sourceSize: Qt.size(width, height)
    fillMode: Image.Stretch
  }

  states: [
    State {
      name: "focused"
      when: passwordField.activeFocus
      PropertyChanges {
        target: passFieldBackground
        color: config.surface0

        border.color: config.sky
      }
    },
    State {
      name: "hovered"
      when: passwordField.hovered
      PropertyChanges {
        target: passFieldBackground
        color: config.surface1
      }
    }
  ]
  transitions: Transition {
    PropertyAnimation {
      properties: "color"
      duration: 300
    }
  }
}
