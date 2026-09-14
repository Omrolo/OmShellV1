import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real brightness: 0.5

    Process {
        id: getBrightness

        command: [
            "sh",
            "-c",
            "brightnessctl -m | cut -d',' -f1,2"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()
                const parts = output.split(",")

                if (parts.length >= 2) {
                    const current = parseFloat(parts[0])
                    const maximum = parseFloat(parts[1])

                    if (maximum > 0)
                        root.brightness = current / maximum
                }
            }
        }
    }

    Process {
        id: setBrightness

        function change(value) {
            command = [
                "brightnessctl",
                "set",
                Math.round(value * 100) + "%"
            ]

            running = true
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: root.refresh()
    }

    function refresh() {
        getBrightness.running = true
    }

    function setBrightnessValue(value) {
        root.brightness = value
        setBrightness.change(value)
    }

    Component.onCompleted: refresh()
}