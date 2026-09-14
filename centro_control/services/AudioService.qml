import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real volume: 0.5
    property bool muted: false

    // ─────────────────────────────
    // OBTENER VOLUMEN ACTUAL
    // ─────────────────────────────

    Process {
        id: getVolume

        command: [
            "wpctl",
            "get-volume",
            "@DEFAULT_AUDIO_SINK@"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()
                const match = output.match(/([0-9.]+)/)

                if (match)
                    root.volume = parseFloat(match[1])

                root.muted = output.includes("[MUTED]")
            }
        }
    }

    // ─────────────────────────────
    // MONITOR DE CAMBIOS DE AUDIO
    // ─────────────────────────────

    Process {
        id: monitor

        command: [
            "pactl",
            "subscribe"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => {
                // pactl subscribe manda eventos como:
                //
                // Event 'change' on sink #...
                //
                // Solo nos interesan cambios.
                if (data.includes("Event 'change'")) {
                    root.refresh()
                }
            }
        }

        // Si pactl se cierra por alguna razón,
        // intentamos volver a levantarlo.
        onRunningChanged: {
            if (!running)
                running = true
        }
    }

    // ─────────────────────────────
    // CAMBIAR VOLUMEN
    // ─────────────────────────────

    Process {
        id: setVolume

        function change(value) {
            command = [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                Math.round(value * 100) + "%"
            ]

            running = true
        }
    }

    // ─────────────────────────────
    // MUTE
    // ─────────────────────────────

    Process {
        id: mute

        function toggle() {
            command = [
                "wpctl",
                "set-mute",
                "@DEFAULT_AUDIO_SINK@",
                "toggle"
            ]

            running = true
        }
    }

    // ─────────────────────────────
    // ACTUALIZAR VOLUMEN
    // ─────────────────────────────

    function refresh() {
        if (!getVolume.running)
            getVolume.running = true
    }

    // ─────────────────────────────
    // API PARA CONTROL CENTER
    // ─────────────────────────────

    function setVolumeValue(value) {
        // Actualización inmediata de la interfaz
        root.volume = value

        // Cambiar volumen real
        setVolume.change(value)
    }

    function toggleMute() {
        mute.toggle()
    }

    // ─────────────────────────────
    // INICIO
    // ─────────────────────────────

    Component.onCompleted: {
        refresh()
    }
}