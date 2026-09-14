import QtQuick
import QtCore
import Quickshell

pragma Singleton

QtObject {
    id: root

    property bool launcherVisible: false
    property var recentIds: []

    property Settings settings: Settings {
        id: _settings
        category: "AppLauncher"
        property string recentIdsSerialized: "[]"
    }

    Component.onCompleted: {
        try {
            var parsed = JSON.parse(settings.recentIdsSerialized);
            recentIds = Array.isArray(parsed) ? parsed : [];
        } catch (e) {
            recentIds = [];
        }
    }

    function toggle() {
        launcherVisible = !launcherVisible;
    }

    function show() {
        launcherVisible = true;
    }

    function hide() {
        launcherVisible = false;
    }

    function recordLaunch(id) {
        if (!id) return;
        var list = (recentIds || []).slice();
        var idx = list.indexOf(id);

        if (idx !== -1) {
            list.splice(idx, 1);
        }
        list.unshift(id);

        if (list.length > 12) list = list.slice(0, 12);

        recentIds = list;
        settings.recentIdsSerialized = JSON.stringify(list);
    }

    function clearRecent() {
        recentIds = [];
        settings.recentIdsSerialized = "[]";
    }
}