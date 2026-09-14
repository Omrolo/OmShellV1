import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var bluetooth
    property bool menuOpen: false

    implicitHeight:
        column.implicitHeight

    ColumnLayout {
        id: column

        width: parent.width

        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            IconButton {
                icon: "󰂯"

                active:
                    root.bluetooth.enabled

                onClicked:
                    root.bluetooth.toggleBluetooth()
            }

            Rectangle {
                Layout.fillWidth: true

                height: 38

                radius: 10

                color: "#313244"

                Text {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter

                        leftMargin: 12
                    }

                    text:
                        root.bluetooth.enabled
                        ? "Bluetooth"
                        : "Desactivado"

                    color: "#cdd6f4"//color texto bluetooth
                }
            }

            IconButton {
                icon:
                    root.menuOpen
                    ? "󰅃"
                    : "󰅂"

                onClicked: {
                    root.menuOpen = !root.menuOpen

                    if (root.menuOpen)
                        root.bluetooth.refreshDevices()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true

            visible:
                root.menuOpen

            implicitHeight:
                devicesColumn.implicitHeight + 16

            radius: 10

            color: "#313244"

            ColumnLayout {
                id: devicesColumn

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top

                    margins: 8
                }

                Repeater {
                    model:
                        root.bluetooth.devices

                    delegate: Rectangle {
                        Layout.fillWidth: true

                        height: 34

                        radius: 7

                        color: "#45475a"

                        Text {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter

                                leftMargin: 10
                            }

                            text:
                                modelData.name

                            color: "#cdd6f4"//color texto opciones
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked:
                                root.bluetooth.connect(
                                    modelData.mac
                                )
                        }
                    }
                }
            }
        }
    }
}