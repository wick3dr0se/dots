import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.components
import "generated_config.js" as Config

ShellRoot {
    property var config: Config.settings

    Component.onCompleted: {
        if (config && typeof config === "object") {
            console.log("[config.ini] Loaded!");
        } else {
            console.warn("[config.ini] Failed to parse config; using defaults");
        }
    }

    TopBar {
        id: topBar

    }
}
