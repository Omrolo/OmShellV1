import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool enabled: true
    property string connectedDevice: "Sin dispositivo"

    property var devices: []

    // ─────────────────────────────
    // Estado de Bluetooth
    // ─────────────────────────────

    Process {
        id: getBluetoothState

        command: [
            "sh",
            "-c",
            "bluetoothctl show | grep 'Powered:'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim().toLowerCase()

                root.enabled = output.includes("powered: yes")
            }
        }
    }

    // ─────────────────────────────
    // Dispositivos emparejados
    // ─────────────────────────────

    Process {
        id: getDevices

        command: [
            "bluetoothctl",
            "devices",
            "Paired"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                let result = []

                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim()

                    if (line.startsWith("Device ")) {
                        const parts = line.split(" ")

                        if (parts.length >= 3) {
                            result.push({
                                mac: parts[1],
                                name: parts.slice(2).join(" ")
                            })
                        }
                    }
                }

                root.devices = result
            }
        }
    }

    // ─────────────────────────────
    // Encender / apagar Bluetooth
    // ─────────────────────────────

    Process {
        id: setBluetooth

        function toggle(value) {
            command = [
                "bluetoothctl",
                "power",
                value ? "on" : "off"
            ]

            running = true
        }
    }

    // ─────────────────────────────
    // Conectar dispositivo
    // ─────────────────────────────

    Process {
        id: connectBluetooth

        function connect(mac) {
            command = [
                "bluetoothctl",
                "connect",
                mac
            ]

            running = true
        }
    }

    // ─────────────────────────────
    // Actualizar estado
    // ─────────────────────────────

    function refresh() {
        getBluetoothState.running = true
    }

    // ─────────────────────────────
    // Actualizar dispositivos
    // ─────────────────────────────

    function refreshDevices() {
        getDevices.running = true
    }

    // ─────────────────────────────
    // Toggle Bluetooth
    // ─────────────────────────────

    function toggleBluetooth() {
        const newState = !root.enabled

        root.enabled = newState
        setBluetooth.toggle(newState)

        refresh()
    }

    // ─────────────────────────────
    // Conectar
    // ─────────────────────────────

    function connect(mac) {
        connectBluetooth.connect(mac)

        refresh()
    }

    // ─────────────────────────────
    // Actualización automática
    // ─────────────────────────────

    Timer {
        interval: 8000
        running: true
        repeat: true

        onTriggered: root.refresh()
    }

    Component.onCompleted: {
        refresh()
        refreshDevices()
    }
}