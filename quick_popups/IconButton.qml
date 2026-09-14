import QtQuick

Rectangle {
    id: root

    property string icon: ""
    property color iconColor: "#2157f9"
    property int iconSize: 23
    property bool transparentBackground: false

    property int iconXOffset: 0
    property int iconYOffset: 0

    signal clicked()

    width: 30
    height: 30

    radius: 50

color: transparentBackground
    ? "transparent"
    : mouseArea.containsMouse
        ? "#7a000000"
        : "#5b000000"

    border.width: 0

    Text {
        anchors.centerIn: parent

        text: root.icon
        color: root.iconColor

        font.family: "Iosevka Nerd Font"
        font.pixelSize: root.iconSize

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        transform: Translate {
            x: root.iconXOffset
            y: root.iconYOffset
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: root.clicked()
    }
}