pragma Singleton

import QtQuick

QtObject {
    id: root

    property bool visible: false

    property bool wifiMenuOpen: false
    property bool bluetoothMenuOpen: false

    function toggle() {
        visible = !visible

        if (!visible) {
            wifiMenuOpen = false
            bluetoothMenuOpen = false
        }
    }

    function close() {
        visible = false
        wifiMenuOpen = false
        bluetoothMenuOpen = false
    }
}