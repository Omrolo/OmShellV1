import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PopupWindow {
    id: root

    property Item anchorItem: null

    grabFocus: true
    
    property bool caffeine: false

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

            spacing: 6

            IconButton {
                icon: "󰒲"
                iconXOffset: -4
                iconYOffset: -1

                onClicked: {
                    suspend()
                }
            }

            IconButton {
                icon: root.caffeine
                    ? "󰛐"
                    : "󰛑"

                iconXOffset: -4
                iconYOffset: 0

                iconColor: root.caffeine
                    ? "#51ff32"
                    : "#aaaaaa"

                onClicked: {
                    toggleCaffeine()
                }
            }

            IconButton {
                icon: "󰐥"
                iconColor: "#9d000a"
                iconXOffset: -1
                iconYOffset: -1

                onClicked: {
                    shutdown()
                }
            }
        }
    }

    Process {
        id: systemProcess
    }

    Process {
        id: caffeineOnProcess

        command: [
            "systemd-inhibit",
            "--what=idle:sleep",
            "--why=Caffeine",
            "sleep",
            "infinity"
        ]
    }

    Process {
        id: caffeineOffProcess

        command: [
            "pkill",
            "-f",
            "systemd-inhibit.*Caffeine"
        ]
    }

    function suspend() {
        systemProcess.command = [
            "systemctl",
            "suspend"
        ]

        systemProcess.running = true
    }

    function shutdown() {
        systemProcess.command = [
            "systemctl",
            "poweroff"
        ]

        systemProcess.running = true
    }

    function toggleCaffeine() {
        if (root.caffeine) {
            caffeineOffProcess.running = true
        } else {
            caffeineOnProcess.running = true
        }

        root.caffeine = !root.caffeine
    }
}