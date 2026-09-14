import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "../theme"

PanelWindow {
    id: root
    property var screen

    IpcHandler {
        target: "applauncher"
        function toggle() {
            AppLauncherState.toggle();
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: AppLauncherState.launcherVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "applauncher"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    mask: Region {
        item: AppLauncherState.launcherVisible ? maskCover : null
    }

    Item {
        id: maskCover
        anchors.fill: parent
    }

    color: "transparent" //NO TOCAR, es el mouse area

    property string searchQuery: ""
    property int selectedIndex: 0
    readonly property bool isSelected: searchQuery.trim() !== ""

    property var filteredApps: {
        var q = searchQuery.trim().toLowerCase();
        var appsObj = DesktopEntries.applications;
        var vals = (appsObj && appsObj.values) ? appsObj.values : [];

        if (q !== "") {
            return vals.filter(function (e) {
                if (!e) return false;
                if (e.name && e.name.toLowerCase().indexOf(q) !== -1) return true;
                if (e.genericName && e.genericName.toLowerCase().indexOf(q) !== -1) return true;
                
                var kw = e.keywords || [];
                for (var i = 0; i < kw.length; i++) {
                    if (kw[i] && kw[i].toLowerCase().indexOf(q) !== -1) return true;
                }
                return false;
            }).sort(function (a, b) {
                return (a.name || "").localeCompare(b.name || "");
            });
        }

        var recent = AppLauncherState.recentIds || [];
        return vals.slice().sort(function (a, b) {
            var ai = recent.indexOf(a.id);
            var bi = recent.indexOf(b.id);
            if (ai !== -1 && bi !== -1) return ai - bi;
            if (ai !== -1) return -1;
            if (bi !== -1) return 1;
            return (a.name || "").localeCompare(b.name || "");
        });
    }

    onFilteredAppsChanged: selectedIndex = 0

    function launchEntry(entry) {
        if (!entry) return;
        AppLauncherState.recordLaunch(entry.id);
        entry.execute();
        AppLauncherState.hide();
    }

    function navigate(delta) {
        if (!filteredApps || filteredApps.length === 0) return;
        selectedIndex = (selectedIndex + delta + filteredApps.length) % filteredApps.length;
        listview.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    Connections {
        target: AppLauncherState
        function onLauncherVisibleChanged() {
            if (AppLauncherState.launcherVisible) {
                searchInput.text = "";
                root.searchQuery = "";
                root.selectedIndex = 0;
                searchInput.forceActiveFocus();
            }
        }
    }

    readonly property color accentFill: '#f50b0b'
    readonly property color accentIcon: '#405bad'
    readonly property color fgDim: '#ffffff'//color textos

    readonly property int maxVisible: 7
    readonly property int itemH: 42
    readonly property int panelW: 440
    readonly property int panelH: contentColumn.implicitHeight + 24

    MouseArea {
        anchors.fill: parent
        enabled: Boolean(AppLauncherState.launcherVisible)
        onClicked: AppLauncherState.hide()
    }

    Rectangle {
        id: panel
        width: root.panelW
        height: root.panelH

        Behavior on height {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        clip: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        color: '#72000000'//caja principal color
        topLeftRadius: 18
        topRightRadius: 18
        border.color: '#0d004d' //color borde
        border.width: 2

        transform: Translate {
            y: AppLauncherState.launcherVisible ? 0 : root.panelH + 6
            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onWheel: function (wheel) {
                if (wheel.angleDelta.y < 0)
                    root.navigate(1);
                else
                    root.navigate(-1);
            }
        }

        Column {
            id: contentColumn
            anchors {
                top: parent.top
                topMargin: 12
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            spacing: 8

            Rectangle {
                width: 36
                height: 4
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: '#b3b3b3'//rectangulito de arriba pechocho
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: '#503e3e3e'//rectangulo de busqueda

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: '#2157f9'
                    border.width: 1
                    opacity: searchInput.activeFocus ? 0.55 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: 8

                    Text {
                        anchors.fill: parent
                        text: " Buscar Apps..."
                        color: '#ffffff'//color buscar apps
                        opacity: 1
                        font {
                            pixelSize: 13
                            family: "JetBrainsMono Nerd Font"
                        }
                        verticalAlignment: Text.AlignVCenter
                        visible: searchInput.text === ""
                    }

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        color: '#ffffff' //color fuentes cuando escribes en buscador
                        selectionColor: root.accentFill
                        font {
                            pixelSize: 13
                            family: "JetBrainsMono Nerd Font"
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true

                        onTextChanged: root.searchQuery = text

                        Keys.onPressed: function (event) {
                            if (event.key === Qt.Key_Up) {
                                root.navigate(-1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                root.navigate(1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.filteredApps && root.filteredApps.length > 0)
                                    root.launchEntry(root.filteredApps[root.selectedIndex]);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Escape) {
                                AppLauncherState.hide();
                                event.accepted = true;
                            }
                        }
                    }
                }
            }

            ListView {
                id: listview
                width: parent.width
                height: Math.min((root.filteredApps ? root.filteredApps.length : 0), root.maxVisible) * root.itemH
                model: root.filteredApps
                clip: true
                interactive: false

                Text {
                    anchors.centerIn: parent
                    visible: !root.filteredApps || root.filteredApps.length === 0
                    text: "No hay aplicaciones"
                    color: '#ffffff'
                    opacity: 1
                    font {
                        pixelSize: 13
                        family: "JetBrainsMono Nerd Font"
                    }
                }

                delegate: Item {
                    id: appRow
                    width: listview.width
                    height: root.itemH

                    readonly property bool sel: root.selectedIndex == index
                    readonly property bool isRecent: {
                        if (root.isSelected || !modelData || !modelData.id) return false;
                        var list = AppLauncherState.recentIds;
                        if (!Array.isArray(list)) return false;
                        var idx = list.indexOf(modelData.id);
                        return idx !== -1 && idx < 5;
                        }

                    Rectangle {
                        anchors {
                            fill: parent
                            topMargin: 2
                            bottomMargin: 2
                        }
                        radius: 10
                        color: appRow.sel ? '#c4242424' : "transparent" //(approw/ color highlight/colorNOhighligh)
                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                            spacing: 12

                            Rectangle {
                                width: 36
                                height: 36
                                radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                color: appRow.sel ? "transparent" : Qt.rgba(1, 1, 1, 0)//color de fondo iconos pexoxos (approw/ color highligh / color NOhighlight)
                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }

                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22
                                    source: (modelData && modelData.icon) ? "image://icon/" + modelData.icon : ""
                                    smooth: true
                                    mipmap: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: appIcon.status !== Image.Ready
                                    text: (modelData && modelData.name) ? modelData.name.charAt(0).toUpperCase() : "?"
                                    font {
                                        pixelSize: 15
                                        family: "JetBrainsMono Nerd Font"
                                        weight: Font.Bold
                                    }
                                    color: appRow.sel ? Colors.colBlue : Colors.colFg //colores de ahi,checar
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: (modelData && modelData.name) ? modelData.name : ""
                                    font {
                                        pixelSize: 13
                                        family: "JetBrainsMono Nerd Font"
                                        weight: appRow.sel ? Font.Medium : Font.Normal
                                    }
                                    color: appRow.sel ? '#b9bbff' : root.fgDim //color highlighted al ser seleccionado, investigar despues
                                }

                                Row {
                                    spacing: 6
                                    visible: appRow.isRecent || (modelData && modelData.genericName)

                                    Rectangle {
                                        visible: appRow.isRecent
                                        width: recentLabel.width + 8
                                        height: 14
                                        radius: 4
                                        color: '#6886e0' //color triangulito recientes
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: recentLabel
                                            anchors.centerIn: parent
                                            text: "Recientes:"
                                            font {
                                                pixelSize: 9
                                                family: "JetBrainsMono Nerd Font"
                                            }
                                            color: '#ffffff' //color texto recientes
                                        }
                                    }

                                    Text {
                                        visible: modelData && modelData.genericName ? true : false
                                        text: (modelData && modelData.genericName) ? modelData.genericName : ""
                                        font {
                                            pixelSize: 11
                                            family: "JetBrainsMono Nerd Font"
                                        }
                                        color: '#ffffff' //texto abajo del titulo
                                        opacity: 0.8
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: root.launchEntry(modelData)
                        }
                    }
                }
            }
        }
    }
}