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

    width: 36
    height: 36

    color: "transparent"

    anchor.item: anchorItem

    anchor.gravity: Edges.Bottom
    anchor.edges: Edges.Top
    anchor.margins.top: 38

    Rectangle {
        anchors.fill: parent

        color: "#5b000000"
        radius: 10

        Column {
            anchors.centerIn: parent

            spacing: 8

            IconButton {
                icon: root.enabled
                    ? "󰂯"
                    : "󰂲"

                iconSize: 20
                iconYOffset: -1
                iconXOffset: -1

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