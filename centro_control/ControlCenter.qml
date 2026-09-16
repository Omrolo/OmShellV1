import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Io
import Quickshell

import "state" as State
import "services" as Services
import "components" as Components

PanelWindow {
    id: root

    visible: State.ControlCenterState.visible
    // ============================================================
    // OPACIDADES
    // ============================================================

    property real panelOpacity: 1.0

    property real leftColumnOpacity: 1.0
    property real centerColumnOpacity: 1.0
    property real mediaColumnOpacity: 1.0


    // ============================================================
    // PANEL WINDOW
    // ============================================================

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"


    // ============================================================
    // SERVICES
    // ============================================================

    Services.AudioService {
        id: audio
    }

    Services.BrightnessService {
        id: brightness
    }

    Services.NetworkService {
        id: network
    }

    Services.BluetoothService {
        id: bluetooth
    }

    Services.MediaService {
        id: media
    }

    Services.WeatherService {
        id: weather
    }


    // ============================================================
    // PANEL PRINCIPAL
    // ============================================================

    Rectangle {
        id: panel

        width: 800
        height: 400

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 43

        bottomLeftRadius: 18
        bottomRightRadius: 18

        color: '#9e000000'
        opacity: root.panelOpacity

        border.width: 0
        border.color: '#000000'



        // ========================================================
        // DETECCIÓN DEL MOUSE
        //
        // Mientras el mouse esté dentro del panel:
        //     permanece abierto.
        //
        // Cuando sale:
        //     se cierra automáticamente.
        // ========================================================

        HoverHandler {
            id: panelHover

            onHoveredChanged: {
                if (!hovered) {
                    State.ControlCenterState.close()
                }
            }
        }


        // ========================================================
        // CONTENIDO
        // ========================================================

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10


            // ====================================================
            // COLUMNA IZQUIERDA
            // ====================================================

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 3

                color: '#54000000'
                radius: 14

                opacity: root.leftColumnOpacity


                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 1


                    Components.CalendarCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        height: 1

                        color: "#45475a"
                    }


                    Text {
                        Layout.alignment: Qt.AlignHCenter

                        text: {
                            const days = [
                                "Dom",
                                "Lun",
                                "Mar",
                                "Mié",
                                "Jue",
                                "Vie",
                                "Sáb"
                            ]

                            const now = new Date()

                            const day =
                                String(now.getDate()).padStart(2, "0")

                            const month =
                                String(now.getMonth() + 1).padStart(2, "0")

                            const year =
                                String(now.getFullYear()).slice(-2)

                            return days[now.getDay()]
                                   + " "
                                   + day
                                   + "/"
                                   + month
                                   + "/"
                                   + year
                        }

                        color: "#cdd6f4"
                        font.bold: true
                    }


                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            text: weather.icon

                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 24

                            color: "#f9e2af"
                        }


                        Text {
                            text: weather.temperature

                            color: "#cdd6f4"
                            font.pixelSize: 20
                        }


                        Text {
                            text: Qt.formatTime(
                                new Date(),
                                "HH:mm"
                            )

                            color: "#a6adc8"
                        }
                    }


                    Text {
                        Layout.alignment: Qt.AlignHCenter

                        text: weather.nextTemperature
                              + " próxima hora"

                        color: "#a6adc8"
                    }
                }
            }




            // ====================================================
            // COLUMNA CENTRAL
            // ====================================================

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 4

                color: '#54000000'
                radius: 14

                opacity: root.centerColumnOpacity


                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14


                    // --------------------------------------------
                    // VOLUMEN
                    // --------------------------------------------

                    Components.SliderRow {
                        Layout.fillWidth: true

                        icon: audio.muted
                            ? "󰖁"
                            : "󰕾"

                        value: audio.volume
                        muted: audio.muted

                        // CONFIGURACIÓN
                        dotCount: 17
                        dotSize: 7
                        dotSpacing: 4

                        activeColor: "#89b4fa"
                        inactiveColor: "#45475a"

                        showPercentage: true
                        showIcon: true

                        onIconClicked: {
                            audio.toggleMute()
                        }

                        onValueChangedByUser: {
                            audio.setVolumeValue(value)
                        }
                    }


                    // --------------------------------------------
                    // BRILLO
                    // --------------------------------------------

                    Components.SliderRow {
                        Layout.fillWidth: true

                        icon: "󰃠"

                        value: brightness.brightness

                        // CONFIGURACIÓN
                        dotCount: 17
                        dotSize: 7
                        dotSpacing: 4

                        activeColor: "#89b4fa"
                        inactiveColor: "#45475a"

                        showPercentage: true
                        showIcon: true

                        onValueChangedByUser: {
                            brightness.setBrightnessValue(value)
                        }
                    }


                    Rectangle {
                        Layout.fillWidth: true
                        height: 1

                        color: "#45475a"
                    }


                    // --------------------------------------------
                    // WIFI
                    // --------------------------------------------

                    Components.NetworkCard {
                        Layout.fillWidth: true

                        network: network
                    }


                    // --------------------------------------------
                    // BLUETOOTH
                    // --------------------------------------------

                    Components.BluetoothCard {
                        Layout.fillWidth: true

                        bluetooth: bluetooth
                    }


                    Item {
                        Layout.fillHeight: true
                    }
                }
            }


            // ====================================================
            // COLUMNA DERECHA / MEDIA
            // ====================================================

            Components.MediaCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 3

                opacity: root.mediaColumnOpacity

                media: media
            }
        }
    }
}