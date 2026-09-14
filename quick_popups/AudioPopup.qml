import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../centro_control/services"

PopupWindow {
    id: root

    property Item anchorItem: null

    grabFocus: true

    property int volume: 50
    property bool muted: false

    width: 33
    height: 120

    color: "transparent"

    anchor.item: anchorItem

    anchor.gravity: Edges.Bottom
    anchor.edges: Edges.Top
    anchor.margins.top: 38

    AudioService{
        id: audioService
    }

    Rectangle {
        anchors.fill: parent

        color: '#9e000000'
        radius: 10

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            spacing: 2



            Slider {
                id: volumeSlider

                anchors.horizontalCenter: parent.horizontalCenter

                orientation: Qt.Vertical

                width: 40
                height: 75

                from: 0
                to: 100

                value: 100

                onMoved: {
                    audioService.setVolumeValue(value / 100)
                }

                handle: Rectangle{
                    width: 14
                    height: 14

                    radius: width / 2

                    x: volumeSlider.width / 2 - width / 2

                    y: volumeSlider.visualPosition
                            * (volumeSlider.height - height)

                    color: "#FFFFFF"

                    
                }
            }

            IconButton {
                anchors.horizontalCenter: parent.horizontalCenter

                icon: ""

                transparentBackground: true

                iconXOffset: -1

                iconColor: root.muted
                    ? "#9d000a"
                    : "#777777"




                onClicked: {
                    muteProcess.running = true
                    root.muted = !root.muted
                }
            }
        }
    }

    Process {
        id: volumeProcess
    }

    Process {
        id: muteProcess

        command: [
            "wpctl",
            "set-mute",
            "@DEFAULT_AUDIO_SINK@",
            "toggle"
        ]
    }
}