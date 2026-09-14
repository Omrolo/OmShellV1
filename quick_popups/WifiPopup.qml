import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PopupWindow {
    id: root

    property Item anchorItem: null

    grabFocus: true

    property bool enabled: true

    width: 40
    height: 40

    color: "transparent"

    anchor.item: anchorItem

    anchor.gravity: Edges.Bottom
    anchor.edges: Edges.Top
    anchor.margins.top: 30

    Rectangle {
        anchors.fill: parent

        color: "#5b000000"
        radius: width / 2

        Column {
            anchors.centerIn: parent

            spacing: 8

            IconButton {
                icon: root.enabled
                    ? ""
                    : "󰖪"


                iconColor: root.enabled
                    ? "#2157f9"
                    : "#777777"
                    
                iconSize: 20

                onClicked: {
                    root.toggleWifi()
                }
            }
        }
    }

    Process {
        id: wifiProcess
    }

    function toggleWifi() {
        wifiProcess.command = [
            "nmcli",
            "radio",
            "wifi",
            root.enabled ? "off" : "on"
        ]

        wifiProcess.running = true

        root.enabled = !root.enabled
    }
}