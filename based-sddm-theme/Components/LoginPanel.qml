import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import QtQuick.Layouts 1.15

Item {
  property var user: userField.text
  property var password: passwordField.text
  property var session: sessionPanel.session
  property var inputHeight: Screen.height * 0.032
  property var inputWidth: Screen.width * 0.16

  property var panelWidth: Screen.width * 0.45
  property var panelHeight: Screen.height

  ShaderEffectSource{
    id: backgroundShader
    sourceItem: backgroundImage
    width: panelWidth
    height: panelHeight
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }
    sourceRect: Qt.rect(x,y, width, height)
  }

  LinearGradient {
    id: backgroundBlurMask
    anchors.fill: backgroundShader
    gradient: Gradient {
      // GradientStop { position: 0; color: "#ffffffff"}
      GradientStop { position: 0; color: "#00ffffff" }
      GradientStop { position: 0.25; color: "#ffffffff" }
      GradientStop { position: 0.75; color: "#ffffffff" }
      GradientStop { position: 1; color: "#00ffffff" }
    }
    start: Qt.point(0, 0)
    end: Qt.point(panelWidth, 0)
    visible: false
  }

  MaskedBlur {
    id: backgroundBlur
    anchors.fill: backgroundShader
    source: backgroundShader
    maskSource: backgroundBlurMask
    radius: 100
    samples: 50
  }

  Item {
    width: panelWidth
    height: panelHeight
    anchors {
      verticalCenter: parent.verticalCenter
      horizontalCenter: parent.horizontalCenter
    }

    Clock {
      id: time
      anchors.topMargin: 20
      visible: config.ClockEnabled == "true" ? true : false
    }

    Column {
      id: loginArea
      spacing: 40

      width: inputWidth
      anchors {
        verticalCenter: parent.verticalCenter
        horizontalCenter: parent.horizontalCenter
      }

      Column {
        width: parent.width
        spacing: 8

        UserField {
          id: userField
          height: inputHeight
          width: parent.width
        }

        PasswordField {
          id: passwordField
          height: inputHeight
          width: parent.width
          onAccepted: loginButton.clicked()
        }
      }

      Button {
        id: loginButton
        height: inputHeight
        width: parent.width
        enabled: user != "" && password != "" ? true : false
        hoverEnabled: true
        contentItem: Text {
          id: buttonText
          renderType: Text.NativeRendering
          font {
            family: config.Font
            pointSize: config.FontSize
            bold: true
          }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          color: config.crust
          text: "Login"
        }
        background: Rectangle {
          id: buttonBackground
          color: config.lavender
          radius: 8
        }
        states: [
          State {
            name: "pressed"
            when: loginButton.down
            PropertyChanges {
              target: buttonBackground
              color: config.teal
            }
            PropertyChanges {
              target: buttonText
            }
          },
          State {
            name: "hovered"
            when: loginButton.hovered
            PropertyChanges {
              target: buttonBackground
              color: config.teal
            }
            PropertyChanges {
              target: buttonText
            }
          },
          State {
            name: "enabled"
            when: loginButton.enabled
            PropertyChanges {
              target: buttonBackground
            }
            PropertyChanges {
              target: buttonText
            }
          }
        ]
        transitions: Transition {
          PropertyAnimation {
            properties: "color"
            duration: 300
          }
        }
        onClicked: {
          sddm.login(user, password, session)
        }
      }

    }

    RowLayout {
      width: loginArea.width
      anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: 20
      }

      Row {
        spacing: 8
        PowerButton {
          id: powerButton
        }
        RebootButton {
          id: rebootButton
        }
        SleepButton {
          id: sleepButton
        }
        Layout.fillWidth: true;
      }

      SessionPanel {
        id: sessionPanel
        Layout.alignment: Qt.AlignRight
      }
    }
    Connections {
      target: sddm

      function onLoginFailed() {
        passwordField.text = ""
        passwordField.focus = true
      }
    }
  }
}
