import QtQuick 2.12
import QtQuick.Controls 2.12

TextField {
  id: userField
  height: inputHeight
  width: inputWidth
  selectByMouse: true
  echoMode: TextInput.Normal
  selectionColor: config.overlay0
  renderType: Text.NativeRendering
  font {
    family: config.Font
    pointSize: config.FontSize
    bold: true
  }
  color: config.text
  horizontalAlignment: Text.AlignHCenter
  placeholderText: "Username"
  text: userModel.lastUser

  background: Rectangle {
    id: userFieldBackground
    color: config.base
    radius: 8

    border {
      color: config.surface1
      width: 2
    }
  }

  Image {
    source: Qt.resolvedUrl("../icons/user.svg")
    id: icon
    anchors.verticalCenter: parent.verticalCenter
    x: 10 

    sourceSize: Qt.size(width, height)
    fillMode: Image.Stretch
  }
  states: [
    State {
      name: "focused"
      when: userField.activeFocus
      PropertyChanges {
        target: userFieldBackground
        color: config.surface0

        border.color: config.sky
      }
    },
    State {
      name: "hovered"
      when: userField.hovered
      PropertyChanges {
        target: userFieldBackground
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
