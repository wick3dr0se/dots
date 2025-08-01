import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services

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

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            text: NiriIPC.focusedWindowTitle
            color: config.theme?.text || "white"
            font.pixelSize: config.panel?.fontSize || 12
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        Clock {
            Layout.alignment: Qt.AlignRight
        }
    }
}
