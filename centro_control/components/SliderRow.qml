import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    // ─────────────────────────────
    // PROPIEDADES PRINCIPALES
    // ─────────────────────────────

    property string icon: ""
    property real value: 0
    property bool muted: false

    signal iconClicked()
    signal valueChangedByUser(real value)

    // ─────────────────────────────
    // CONFIGURACIÓN
    // ─────────────────────────────

    // Cantidad de círculos
    property int dotCount: 20

    // Tamaño de cada círculo
    property real dotSize: 7

    // Separación entre círculos
    property real dotSpacing: 4

    // Colores
    property color activeColor: "#89b4fa"
    property color inactiveColor: "#45475a"
    property color hoverColor: "#b4befe"

    // Mostrar porcentaje
    property bool showPercentage: true

    // Ancho del porcentaje
    property int percentageWidth: 35

    // Permitir cambiar el valor
    property bool interactive: true

    // Mostrar icono
    property bool showIcon: true

    // ─────────────────────────────
    // LAYOUT
    // ─────────────────────────────

    spacing: 10

    IconButton {
        visible: root.showIcon

        icon: root.icon

        active: !root.muted

        onClicked: root.iconClicked()
    }

    Item {
        id: dotsArea

        Layout.fillWidth: true

        Layout.preferredHeight: root.dotSize + 12

        // Área para detectar clics
        MouseArea {
            anchors.fill: parent

            enabled: root.interactive

            hoverEnabled: true

            onClicked: mouse => {
                root.valueChangedByUser(
                    Math.max(
                        0,
                        Math.min(
                            1,
                            mouse.x / width
                        )
                    )
                )
            }

            onPositionChanged: mouse => {
                if (pressed) {
                    root.valueChangedByUser(
                        Math.max(
                            0,
                            Math.min(
                                1,
                                mouse.x / width
                            )
                        )
                    )
                }
            }
        }

        Row {
            anchors.centerIn: parent

            spacing: root.dotSpacing

            Repeater {
                model: root.dotCount

                Rectangle {
                    width: root.dotSize

                    height: root.dotSize

                    radius: width / 2

                    color:
                        index < Math.round(
                            root.value * root.dotCount
                        )
                        ? root.activeColor
                        : root.inactiveColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                }
            }
        }
    }

    Text {
        visible: root.showPercentage

        text: Math.round(root.value * 100) + "%"

        color: "#cdd6f4"

        Layout.preferredWidth: root.percentageWidth

        horizontalAlignment: Text.AlignRight
    }
}