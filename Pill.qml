import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property bool iconOnly: false

    // Atributos de contenido
    property string icon: ""
    property string label: ""
    property color iconColor: "#2157f9"
    property int iconSize: 16
    
    // Offset de precisión para el ícono
    property int iconXOffset: 0
    property int iconYOffset: 0
    
    property int maxLabelWidth: 400

    // Forma del botón
    property bool isSquare: false    // Activa si quieres que sea un botón cuadrado
    property int customRadius: -1    // Permite forzar un radio específico (-1 usa el cálculo por defecto)

    // Atributos de fondo y borde
    property color backgroundColor: "#5b000000"
    property color borderColor: "transparent"
    property int borderWidth: 0

    // Comportamiento
    property var command: []
    signal clicked()

    implicitHeight: 33
    implicitWidth: iconOnly
    ? implicitHeight
    : (isSquare ? implicitHeight : row.implicitWidth + 22)

    // Si customRadius tiene valor mayor a -1 lo usa; si es cuadrado usa 8; de lo contrario usa la mitad de la altura
    radius: customRadius >= 0 ? customRadius : (isSquare ? 8 : height / 2)

    color: mouseArea.containsMouse ? Qt.lighter(root.backgroundColor, 1.25) : root.backgroundColor
    border.color: root.borderColor
    border.width: root.borderWidth

    Process {
        id: proc
        command: root.command
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: root.icon
            color: root.iconColor
            font.family: "Iosevka Nerd Font"
            font.pixelSize: root.iconSize
            
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
            
            transform: Translate { 
                x: root.iconXOffset
                y: root.iconYOffset 
            }
        }

        Text {
            text: root.label
            color: "#f1eae0"
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 16

            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter

            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth

            visible: !root.iconOnly && root.label !== ""
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()
            if (root.command && root.command.length > 0) {
                proc.running = true
            }
        }
    }
}