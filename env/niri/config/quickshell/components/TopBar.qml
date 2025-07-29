import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: topBar

    anchors.left: true
    anchors.right: true
    anchors.top: true
    color: config.theme?.base || "black"
    implicitHeight: config.panel?.height || 32

    RowLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: 6
        spacing: 10

        WorkspaceSwitcher {
            Layout.alignment: Qt.AlignLeft
        }
        Item {
            Layout.fillWidth: true
        }
        Clock {
            Layout.alignment: Qt.AlignRight
        }
    }
}
