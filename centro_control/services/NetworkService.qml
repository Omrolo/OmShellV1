import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool enabled: true
    property string connectedNetwork: "No conectado"
    property var networks: []

    // ─────────────────────────────
    // WiFi activo
    // ─────────────────────────────

    Process {
        id: getConnected

        command: [
            "sh",
            "-c",
            "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | grep ':wifi:connected:' | head -n1 | cut -d':' -f4-"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()

                if (output.length > 0)
                    root.connectedNetwork = output
                else
                    root.connectedNetwork = "No conectado"
            }
        }
    }

    // ─────────────────────────────
    // Estado del WiFi
    // ─────────────────────────────

    Process {
        id: getWifiState

        command: [
            "nmcli",
            "radio",
            "wifi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.enabled = text.trim() === "enabled"
            }
        }
    }

    // ─────────────────────────────
    // Lista de redes
    // ─────────────────────────────

    Process {
        id: getNetworks

        command: [
            "sh",
            "-c",
            "nmcli -t -f SSID dev wifi | sort -u"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                let result = []

                for (let i = 0; i < lines.length; i++) {
                    const name = lines[i].trim()

                    if (name.length > 0 && !result.includes(name))
                        result.push(name)
                }

                root.networks = result
            }
        }
    }

    // ─────────────────────────────
    // Cambiar WiFi ON/OFF
    // ─────────────────────────────

    Process {
        id: setWifi

        function toggle(value) {
            command = [
                "nmcli",
                "radio",
                "wifi",
                value ? "on" : "off"
            ]

            running = true
        }

        onExited: {
            refreshTimer.restart()
        }
    }

    // ─────────────────────────────
    // Conectar a una red
    // ─────────────────────────────

    Process {
        id: connectWifi

        function connect(network) {
            command = [
                "nmcli",
                "device",
                "wifi",
                "connect",
                network
            ]

            running = true
        }

        onExited: {
            // Esperamos a que NetworkManager termine
            refreshTimer.restart()
        }
    }

    // ─────────────────────────────
    // Actualización retrasada
    // ─────────────────────────────

    Timer {
        id: refreshTimer

        interval: 1500
        repeat: false

        onTriggered: root.refresh()
    }

    // ─────────────────────────────
    // Actualizar todo
    // ─────────────────────────────

    function refresh() {
        if (!getConnected.running)
            getConnected.running = true

        if (!getWifiState.running)
            getWifiState.running = true
    }

    function refreshNetworks() {
        if (!getNetworks.running)
            getNetworks.running = true
    }

    function toggleWifi() {
        const newState = !root.enabled

        setWifi.toggle(newState)
    }

    function connect(network) {
        connectWifi.connect(network)
    }

    // ─────────────────────────────
    // Actualización automática
    // ─────────────────────────────

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: root.refresh()
    }

    Component.onCompleted: {
        refresh()
        refreshNetworks()
    }
}