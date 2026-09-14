import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // ==========================================
    // CAMBIA AQUÍ EL ANCHO Y LARGO DE TU CALENDARIO
    // ==========================================
    implicitWidth: 300  // Ancho deseado por defecto
    implicitHeight: 320 // Alto deseado por defecto

    // O si deseas forzar un tamaño exacto:
    width: implicitWidth
    height: implicitHeight

    property date now: new Date()

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property int year: now.getFullYear()
    readonly property int month: now.getMonth()
    readonly property int day: now.getDate()

    readonly property int firstDay: new Date(year, month, 1).getDay()
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()

    readonly property var monthNames: [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Encabezado
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.monthNames[root.month] + " " + root.year
            color: "#cdd6f4"
            font.bold: true
            font.pixelSize: 18
        }

        // Grilla del Calendario
        // Grilla del Calendario
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 4

            // Encabezado de Días (D, L, M, M, J, V, S)
            Repeater {
                model: ["D", "L", "M", "M", "J", "V", "S"]

                Text {
                    // Layout.preferredWidth: 0 fuerza a que todas las columnas midan exactamente lo mismo
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0 

                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    color: "#a6adc8"
                    font.bold: true
                }
            }

            // Días del Mes
            Repeater {
                model: 42

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    readonly property int calculatedDay: index - root.firstDay + 1
                    readonly property bool valid: calculatedDay > 0 && calculatedDay <= root.daysInMonth

                    // Resaltado de Día Actual (se adapta proporcionalmente)
                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 0.8
                        height: width
                        radius: width / 2
                        visible: parent.valid && parent.calculatedDay === root.day
                        color: "#89b4fa"
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: parent.valid
                        text: parent.valid ? parent.calculatedDay : ""
                        color: parent.calculatedDay === root.day ? "#1e1e2e" : "#cdd6f4"
                    }
                }
            }
        }
    }
}