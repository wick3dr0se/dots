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
            font.pixelSize: config.panel?.font_size || 12
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        // right side container for clock & menu button
        Item {
            Layout.alignment: Qt.AlignRight
            Layout.preferredWidth: rightContent.width
            Layout.preferredHeight: parent.height

            Row {
                id: rightContent
                spacing: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Clock {
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: menuButton
                    width: 24
                    height: 20
                    color: menuArea.containsMouse ? (config.theme?.surface || "#313244") : "transparent"
                    radius: 4
                    anchors.verticalCenter: parent.verticalCenter

                    // three dots icon
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Repeater {
                            model: 3
                            Rectangle {
                                width: 3
                                height: 3
                                radius: 1.5
                                color: config.theme?.text || "white"
                            }
                        }
                    }

                    MouseArea {
                        id: menuArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: dropdownMenu.visible = !dropdownMenu.visible
                    }
                }
            }
        }
    }

    DropdownMenu {
        id: dropdownMenu
        parentWindow: topBar
    }
}