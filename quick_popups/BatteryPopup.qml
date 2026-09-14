import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PopupWindow {
    id: root

    property Item anchorItem: null

    grabFocus: true

    property int batteryPercent: 100

    width: 36
    height: 110

    color: "transparent"

    anchor.item: anchorItem

    anchor.gravity: Edges.Bottom
    anchor.edges: Edges.Top
    anchor.margins.top: 38

    Rectangle {
        anchors.fill: parent

        color: '#9e000000'
        radius: 10

        Column {
            anchors.centerIn: parent

            spacing: 3

            IconButton {
                icon: "󰌪"
                iconXOffset: -3

                onClicked: {
                    root.setPowerProfile("power-saver")
                }
            }

            IconButton {
                icon: "󰾅"
                iconXOffset: -3
                iconYOffset: -2

                onClicked: {
                    root.setPowerProfile("balanced")
                }
            }

            IconButton {
                icon: "󰓅"
                iconXOffset: -3
                iconYOffset: -2

                onClicked: {
                    root.setPowerProfile("performance")
                }
            }
        }
    }

    Process {
        id: powerProfileProcess
    }

    function setPowerProfile(profile) {
        powerProfileProcess.command = [
            "powerprofilesctl",
            "set",
            profile
        ]

        powerProfileProcess.running = true
    }
}