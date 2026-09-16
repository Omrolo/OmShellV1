import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string command: ""
    property int interval: 3000
    property string value: ""
    property bool enabled: true

    Process {
        id: proc

        command: ["sh", "-c", root.command]

        stdout: StdioCollector {
            onStreamFinished: {
                root.value = this.text.trim()
            }
        }
    }

    function update() {
        if (!root.enabled)
            return

        if (!proc.running)
            proc.running = true
    }

    Component.onCompleted: {
        update()
    }

    Timer {
        interval: root.interval
        running: root.enabled
        repeat: true

        onTriggered: {
            root.update()
        }
    }
}