import QtQuick 2.0

Column {
    id: container

    property date dateTime: new Date()
    property color color: config.text
    property alias timeFont: time.font
    property alias dateFont: date.font

    anchors {
      top: parent.top
      horizontalCenter: parent.horizontalCenter
    }

    Timer {
        interval: 100; running: true; repeat: true;
        onTriggered: container.dateTime = new Date()
    }

    Text {
        id: time
        anchors.horizontalCenter: parent.horizontalCenter

        color: container.color

        text : Qt.formatTime(container.dateTime, "h:mm A")

        font {
            family: config.Font
            pointSize: 72
            weight: Font.Black
        }
    }

    Text {
        id: date
        anchors.horizontalCenter: parent.horizontalCenter

        color: container.color

        text : Qt.formatDate(container.dateTime, Qt.DefaultLocaleLongDate)

        font.pointSize: 24
    }
}
