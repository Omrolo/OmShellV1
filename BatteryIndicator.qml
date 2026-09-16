import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Item {
    id: root

    implicitWidth: 33
    implicitHeight: 33

    signal clicked()

    readonly property var battery: {
        let devices = UPower.devices.values

        for (let i = 0; i < devices.length; i++) {
            let device = devices[i]

            if (device.isLaptopBattery)
                return device
        }

        return null
    }

    readonly property int percentage:
        battery ? Math.round(battery.percentage * 100) : 0

    readonly property bool pluggedIn:
        !UPower.onBattery

    property int iconX: 0
    property int iconY: 0

    Rectangle {
        id: island

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: 33
        height: 33

        radius: height / 2

        color: mouseArea.containsMouse
            ? Qt.lighter("#5b000000", 1.25)
            : "#5b000000"

        border.color: root.pluggedIn
            ? "#51ff32"
            : "transparent"

        border.width: root.pluggedIn ? 2 : 0

        Rectangle{
            id: fondo

            width: 20
            height: 8

            color:'#484848'

            x: 7
            y: 14

        }

        Text {
            x: (island.width - width) / 2 + root.iconX
            y: (island.height - height) / 2 + root.iconY

            text: {
                let value = root.percentage

                if (value >= 90) return ""
                if (value >= 70) return ""
                if (value >= 40) return ""
                if (value >= 15) return ""

                return ""
            }

            color: root.pluggedIn
                ? "#51ff32"
                : "#ffffff"

            font.family: "CaskaydiaCove Nerd Font"
            font.pixelSize: 24
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.clicked()
            }
        }
    }


    Rectangle{
        id: fondotexto

        width: 20
        height: 8
        radius: 10

        color: root.pluggedIn
            ?'#404040'
            : "transparent"

        x: 7
        y: 26
        // PORCENTAJE FLOTANTE
        Text {
            id: percentageText

            anchors.centerIn: parent

            text: root.percentage


            color: root.pluggedIn
                ? '#ffffff'
                : '#ffffff'

            font.family: "MartianMono Nerd Font"
            font.pixelSize: 8
            font.bold: true

            // Posición independiente
            x: 2
            y: -2

            // NO participa en implicitWidth/implicitHeight
        }
    }

    Text {
    id: iconocarga

    text: "󱐌"


    color: root.pluggedIn
        ? '#ffffff'
        : 'transparent'

    font.family: "MartianMono Nerd Font"
    font.pixelSize: 23


    x: 11
    y: 0

    // NO participa en implicitWidth/implicitHeight
    }
}