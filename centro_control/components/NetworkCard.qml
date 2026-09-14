import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var network
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
                icon: "󰖩"

                active:
                    root.network.enabled

                onClicked:
                    root.network.toggleWifi()
            }

            Rectangle {
                Layout.fillWidth: true

                height: 38

                radius: 10

                color: "#313244"

                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter

                        leftMargin: 12
                        rightMargin: 12
                    }

                    text:
                        root.network.connectedNetwork

                    color: "#cdd6f4"

                    elide: Text.ElideRight
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
                        root.network.refreshNetworks()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true

            visible:
                root.menuOpen

            implicitHeight:
                listColumn.implicitHeight + 16

            radius: 10

            color: "#313244"

            ColumnLayout {
                id: listColumn

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top

                    margins: 8
                }

                spacing: 4

                Repeater {
                    model:
                        root.network.networks

                    delegate: Rectangle {
                        Layout.fillWidth: true

                        height: 34

                        radius: 7

                        color: "#45475a"

                        Text {//redes disponibles
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter

                                leftMargin: 10
                            }

                            text: modelData

                            color: "#cdd6f4"
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked:
                                root.network.connect(modelData)
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

                        text: "Más opciones"

                        color: "#a6adc8"
                    }
                }
            }
        }
    }
}