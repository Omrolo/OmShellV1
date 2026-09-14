import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string title: "Sin reproducción"
    property string artist: ""
    property string artUrl: ""

    property real position: 0
    property real length: 1

    property bool playing: false

    // ─────────────────────────────
    // Metadata
    // ─────────────────────────────

    Process {
        id: getMetadata

        command: [
            "sh",
            "-c",
            "playerctl metadata --format '{{title}}|||{{artist}}|||{{mpris:artUrl}}|||{{position}}|||{{mpris:length}}' 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()

                if (output.length === 0) {
                    root.title = "Sin reproducción"
                    root.artist = ""
                    root.artUrl = ""
                    root.position = 0
                    root.length = 1
                    return
                }

                const parts = output.split("|||")

                if (parts.length >= 5) {
                    root.title = parts[0] || "Sin reproducción"
                    root.artist = parts[1] || ""
                    root.artUrl = parts[2] || ""

                    root.position = parseFloat(parts[3]) || 0
                    root.length = parseFloat(parts[4]) || 1
                }
            }
        }
    }

    // ─────────────────────────────
    // Estado
    // ─────────────────────────────

    Process {
        id: getStatus

        command: [
            "sh",
            "-c",
            "playerctl status 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.playing = text.trim() === "Playing"
            }
        }
    }

    // ─────────────────────────────
    // Controles
    // ─────────────────────────────

    Process {
        id: previousPlayer

        command: [
            "playerctl",
            "previous"
        ]
    }

    Process {
        id: nextPlayer

        command: [
            "playerctl",
            "next"
        ]
    }

    Process {
        id: playPausePlayer

        command: [
            "playerctl",
            "play-pause"
        ]
    }

    // ─────────────────────────────
    // Actualización
    // ─────────────────────────────

    function refresh() {
        getMetadata.running = true
        getStatus.running = true
    }

    // ─────────────────────────────
    // Controles públicos
    // ─────────────────────────────

    function previous() {
        previousPlayer.running = true

        refresh()
    }

    function next() {
        nextPlayer.running = true

        refresh()
    }

    function playPause() {
        playPausePlayer.running = true

        // No invertimos manualmente `playing`.
        // Esperamos a que playerctl nos diga el estado real.
        refresh()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}