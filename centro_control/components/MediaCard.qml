import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    property var media

    color: '#54000000'

    radius: 14

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14

        spacing: 8

    Rectangle {
        id: albumCover

        Layout.fillWidth: true
        Layout.preferredHeight: width

        color: "transparent"

        // Propiedad para conservar la rotación
        property real rotationAngle: 0

        // Imagen circular
        Image {
            id: albumImage

            anchors.fill: parent

            source: root.media.artUrl

            fillMode: Image.PreserveAspectCrop

            visible: false
        }

        Rectangle {
            id: circleMask

            anchors.fill: parent

            radius: width / 2

            visible: false
        }

        OpacityMask {
            id: maskedImage

            anchors.fill: parent

            source: albumImage

            maskSource: circleMask

            rotation: albumCover.rotationAngle
        }

        Text {
            anchors.centerIn: parent

            visible: root.media.artUrl === ""

            text: "󰎈"

            font.family: "Symbols Nerd Font"

            font.pixelSize: 48

            color: "#a6adc8"
        }

        // Animación continua
        NumberAnimation {
            id: spinAnimation

            target: albumCover

            property: "rotationAngle"

            from: albumCover.rotationAngle

            to: albumCover.rotationAngle + 360

            duration: 12000

            loops: Animation.Infinite

            running: root.media.playing
        }
    }

        Text {
            Layout.fillWidth: true

            text: root.media.title

            color: "#cdd6f4"

            font.bold: true

            elide: Text.ElideRight

            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            Layout.fillWidth: true

            text: root.media.artist

            color: "#a6adc8"

            elide: Text.ElideRight

            horizontalAlignment: Text.AlignHCenter
        }

        Slider {
            Layout.fillWidth: true

            from: 0
            to: Math.max(root.media.length, 1)

            value: root.media.position
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            spacing: 12

            IconButton {
                icon: "󰒮"

                onClicked:
                    root.media.previous()
            }

            IconButton {
                icon:
                    root.media.playing
                    ? "󰏤"
                    : "󰐊"

                active: true

                onClicked:
                    root.media.playPause()
            }

            IconButton {
                icon: "󰒭"

                onClicked:
                    root.media.next()
            }
        }
    }
}