import QtQuick
import Quickshell

import qs.services

Row {
    id: switcher

    spacing: 4

    Repeater {
        model: WorkspaceManager.workspaces

        Rectangle {
            id: pill

            color: model.isFocused ? config.theme?.success : config.theme?.base_deep
            height: 20
            radius: height / 2
            width: 35

            Text {
                id: label

                anchors.centerIn: parent
                color: model.isFocused ? config.theme?.base_deep : config.theme?.text
                font.bold: model.isFocused
                text: model.name.length > 0 ? model.name : model.idx
            }
        }
    }
}
