import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Io
import "./theme"
import "./app_launcher"
import "./centro_control"
import "./centro_control/state" as State
import "./quick_popups"

ShellRoot {
    id: root

    ControlCenter{}

    AudioPopup {
        id: audioPopup

        anchorItem: volumeButton

        volume: Number(vol.value)
    }


    BatteryPopup {
        id: batteryPopup

        anchorItem: batteryButton

        batteryPercent: Number(bat.value)
    }


    BluetoothPopup {
        id: bluetoothPopup

        anchorItem: bluetoothButton

        enabled: bt.value === "ON"
    }


    WifiPopup {
        id: wifiPopup

        anchorItem: wifiButton

        enabled: net.value !== ""
    }


    PowerPopup {
        id: powerPopup

        anchorItem: powerButton
    }


    PanelWindow {
        id: bar

        anchors {
            top: true
        }
        
        exclusiveZone:43

        implicitHeight: 46
        implicitWidth: 1250
        color: "transparent"

    Rectangle {

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 3


        height: 40
        width: 1250
        radius: 18


        color: '#9e000000'
    }


        Poller {
            id: clock
            command: "date +%H:%M"
            interval: 50000
        }

        Poller {
            id: vol
            command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"
            interval: 100
        }

        Poller {
            id: mute
            command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo MUTED || echo UNMUTED"
            interval: 100
        }

        Poller {
            id: bat
            command: "cat /sys/class/power_supply/BAT0/capacity"
            interval: 30000
        }

        Poller {
            id: bt
            command: "bluetoothctl show | grep -q 'Powered: yes' && echo ON || echo OFF"
            interval: 5000
        }

        Poller {
            id: net
            command: "nmcli -t -f TYPE,STATE,CONNECTION dev | awk -F: '$1==\"wifi\" && $2==\"connected\" {print $3}'"
            interval: 5000
        }

        Poller {
            id: wifiRadio

            command: "nmcli radio wifi"

            interval: 2000
        }



        readonly property var player:
            Mpris.players.values.find(p => p.isPlaying)
            ?? Mpris.players.values[0]
            ?? null

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 14
            spacing: 8

            Pill {
                icon: "" //busqueda insana
                iconSize: 25
                iconYOffset: -1
                iconXOffset: 0
                iconColor: "#2157f9"
                backgroundColor: "transparent"
                borderColor: "transparent"
                borderWidth: 3
                command: ["qs", "ipc", "call", "applauncher", "toggle"]
                implicitWidth:40                
            }

            Workspaces {}

            Pill {
                icon: ""
                maxLabelWidth: 200
                label: bar.player
                    ? `${bar.player.trackArtist || ""} : ${bar.player.trackTitle || ""}`
                    : ""
            }


            Pill {
                icon: ""
                label: clock.value
            }
        }

        RowLayout {
            id: centerGroup
            anchors.centerIn: parent
            spacing: 8

            Pill {
                icon: "           "//activar/desactivar centro de control
                iconSize: 20
                iconYOffset: 0
                iconXOffset: 2
                iconColor: '#353535'

                onClicked: {
                State.ControlCenterState.toggle()
                }
            }

        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 14

            spacing: 8

            // ─────────────────────────
            // VOLUMEN
            // ─────────────────────────

            Pill {
                id: volumeButton

                property bool isMuted: mute.value === "MUTED"

                icon: isMuted
                    ? ""
                    : vol.value >= 70
                        ? ""
                        : vol.value >= 33
                            ? ""
                            : vol.value >=1
                                ? ""
                                : ""

                iconSize: 20
                iconYOffset: -1

                iconColor: isMuted
                    ? "#9d000a"
                    : "#2157f9"

                backgroundColor: isMuted
                    ? "#e0454f"
                    : "#5b000000"

                borderColor: isMuted
                    ? "#820009"
                    : "#5b000000"

                borderWidth: isMuted
                    ? 2
                    : 0

                onClicked: {
                    audioPopup.visible = !audioPopup.visible
                }
                implicitWidth:33
            }


            // ─────────────────────────
            // BATERÍA
            // ─────────────────────────

            Pill {
                id: batteryButton

                icon: {
                    let value = Number(bat.value)

                    if (value >= 90) return ""
                    if (value >= 70) return ""
                    if (value >= 40) return ""
                    if (value >= 15) return ""

                    return ""
                }

                iconSize: 20
                iconYOffset: -1
                iconXOffset: 0
                iconColor: {
                    let value = Number(bat.value)

                    if (value <= 10)
                        return '#d70000'

                    if (value <= 20)
                        return '#e46700'

                    if (value <= 79)
                        return '#ffffff'

                    return "#51ff32"
                    }

                backgroundColor: "#5b000000"

                onClicked: {
                    batteryPopup.visible = !batteryPopup.visible
                }

                implicitWidth:33
            }


            // ─────────────────────────
            // BLUETOOTH
            // ─────────────────────────

             Pill {
                id: bluetoothButton

                property bool bluetoothOn: bt.value === "ON"

                icon: bluetoothOn
                    ? "󰂯"
                    : "󰂲"

                iconSize: 20
                iconYOffset: -1

                iconColor: bluetoothOn
                    ? "#2157f9"
                    : "#9d000a"

                backgroundColor: bluetoothOn
                    ? "#5b000000"
                    : "#e0454f"

                borderColor: bluetoothOn
                    ? "#5b000000"
                    : "#820009"

                borderWidth: bluetoothOn
                    ? 0
                    : 2

                onClicked: {
                        command = [
                        "bluetoothctl",
                        "power",
                        bluetoothOn ? "off" : "on"
                    ]
                }
                implicitWidth:33

                
            }


            // ─────────────────────────
            // WIFI
            // ─────────────────────────

            Pill {
                id: wifiButton

                property bool wifiOn: net.value !== ""

                icon: wifiOn
                    ? ""
                    : "󰖪"

                iconSize: 20
                iconYOffset: -1

                iconColor: wifiOn
                    ? "#2157f9"
                    : "#9d000a"

                backgroundColor: wifiOn
                    ? "#5b000000"
                    : "#e0454f"

                borderColor: wifiOn
                    ? "#5b000000"
                    : "#820009"

                borderWidth: wifiOn
                    ? 0
                    : 2

                onClicked: {
                    wifiPopup.toggleWifi()
                }

                implicitWidth:33
            }


            // ─────────────────────────
            // POWER
            // ─────────────────────────

            Pill {
                id: powerButton

                isSquare: true

                icon: "󰐥"

                iconSize: 25

                iconYOffset: 0
                iconXOffset: 0

                iconColor: "#9d000a"

                backgroundColor: "#e0454f"
                borderColor: "#820009"
                borderWidth: 2

                onClicked: {
                    powerPopup.visible = !powerPopup.visible
                }

            }
        }
    }

    Variants {
        model: Quickshell.screens

        AppLauncher {
            property var modelData
            screen: modelData
        }
    }
}