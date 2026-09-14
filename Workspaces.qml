import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle{
    implicitWidth: row.implicitWidth + 22
    implicitHeight: 33
    radius: height / 2
    color: "#5b000000"

    RowLayout{
        id: row
        anchors.centerIn: parent
        spacing: 8

        Repeater{
            model:Hyprland.workspaces

            Rectangle {
                implicitWidth: modelData.active ? 11 : 6
                implicitHeight: implicitWidth
                radius: width / 2
                color: modelData.active ? "transparent" : '#000000' 
                border.width: modelData.active ? 2 : 0
                border.color: "#2157f9"

                Behavior on implicitWidth {
                    NumberAnimation {duration: 160; easing.type: Easing.OutCubic}
                }
            }
        }
    }
}