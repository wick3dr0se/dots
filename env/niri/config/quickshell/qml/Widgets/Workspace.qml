import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "root:/Data" as Data

// Hyprland workspace indicator
Column {
    id: root
    property var shell
    spacing: 8

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            width: 22
            height: 22
            radius: 6
            color: modelData.active ? Data.ThemeManager.accentColor : "transparent"
            border.color: Data.ThemeManager.accentColor
            border.width: modelData.active ? 0 : 1
            opacity: modelData.active ? 1 : 0.6

            Text {
                anchors.centerIn: parent
                text: modelData.name || modelData.id
                color: modelData.active ? Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
                font.family: "Roboto"
                font.pixelSize: 12
                font.bold: modelData.active
            }

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
                onPressAndHold: {
                    // Move focused window to workspace (regular workspaces only)
                    if (modelData.id > 0) {
                        Hyprland.dispatch(`movetoworkspace ${modelData.id}`)
                    }
                }
            }
        }
    }

    // Workspace synchronization
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            Hyprland.refreshWorkspaces()
        }
    }

    Component.onCompleted: Hyprland.refreshWorkspaces()
}
