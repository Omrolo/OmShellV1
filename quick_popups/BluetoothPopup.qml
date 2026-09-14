import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PopupWindow {
    id: root

    property Item anchorItem: null

    grabFocus: true

    property bool enabled: false

    width: 60
    height: 116

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
                    ? "󰂯"
                    : "󰂲"

                iconColor: root.enabled
                    ? "#2157f9"
                    : "#777777"

                onClicked: {
                    root.toggleBluetooth()
                }
            }
        }
    }

    Process {
        id: bluetoothProcess
    }

    function toggleBluetooth() {
        bluetoothProcess.command = [
            "bluetoothctl",
            "power",
            root.enabled ? "off" : "on"
        ]

        bluetoothProcess.running = true

        root.enabled = !root.enabled
    }
}