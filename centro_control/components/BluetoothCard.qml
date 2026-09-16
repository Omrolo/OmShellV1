import QtQuick
import QtQuick.Layouts
import Quickshell


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
                id: deviceslayout


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
                id: optionsButton

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

        PopupWindow {
            id: bluetoothDevicesPopup

            visible: root.menuOpen

            width: 275

            implicitHeight: devicesColumn.implicitHeight + 16

            color: "transparent"


                anchor.rect {
                x: 0
                y: deviceslayout.height + 3
                width: deviceslayout.width
                height: 10
            }

            anchor.item: deviceslayout
            anchor.gravity: Edges.Bottom
            anchor.edges: Edges.Top


            Rectangle {
                anchors.fill: parent

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

                    spacing: 4

                    Repeater {
                        model: root.bluetooth.devices

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

                                text: modelData.name

                                color: "#cdd6f4"
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    root.bluetooth.connect(
                                        modelData.mac
                                    )

                                    root.menuOpen = false
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        height: 34

                        radius: 7

                        color: "#45475a"

                        Text {
                            anchors.centerIn: parent

                            text: "Vincular nuevo dispositivo"

                            color: "#a6adc8"
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                // Tu lógica para vincular
                            }
                        }
                    }
                }
            }
        }
    }
}