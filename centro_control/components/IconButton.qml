import QtQuick

Rectangle {
    id: root

    property string icon: ""
    property bool active: false

    signal clicked()

    width: 38
    height: 38

    radius: 10

    color: active
        ? "#89b4fa"
        : "#313244"

    Text {
        anchors.centerIn: parent

        text: root.icon

        font.family: "Symbols Nerd Font"
        font.pixelSize: 20

        color: root.active
            ? '#202020'
            : "#cdd6f4"
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}