import QtQuick
import Quickshell
import Quickshell.Io

PopupWindow {
    id: dropdown
    implicitWidth: 200
    implicitHeight: 140
    color: "transparent"
    visible: false
    
    property var parentWindow
    property int offsetX: 6
    property int offsetY: 6
    
    anchor {
        window: parentWindow
        rect.x: (parentWindow?.width || 0) - implicitWidth - offsetX
        rect.y: (parentWindow?.height || 0) + offsetY
    }

    Rectangle {
        anchors.fill: parent
        color: config.theme?.surface || "#313244"
        border.color: config.theme?.border || "#585b70"
        border.width: 1
        radius: 8

        Column {
            id: menuContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 4

            // settings menu item
            Rectangle {
                width: parent.width
                height: 32
                color: settingsArea.containsMouse ? (config.theme?.surface_hover || "#45475a") : "transparent"
                radius: 4

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    spacing: 8

                    Rectangle {
                        width: 16
                        height: 16
                        color: config.theme?.text || "white"
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Settings"
                        color: config.theme?.text || "white"
                        font.pixelSize: config.panel?.font_size || 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: settingsArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        dropdown.visible = false
                        console.log("Settings clicked")
                    }
                }
            }

            // divider
            Rectangle {
                width: parent.width
                height: 2
                color: config.theme?.border || "#585b70"
            }

            // lock screen menu item
            Rectangle {
                width: parent.width
                height: 32
                color: lockArea.containsMouse ? (config.theme?.surface_hover || "#45475a") : "transparent"
                radius: 4

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    spacing: 8

                    Rectangle {
                        width: 16
                        height: 16
                        color: config.theme?.text || "white"
                        radius: 8
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Lock Screen"
                        color: config.theme?.text || "white"
                        font.pixelSize: config.panel?.font_size || 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: lockArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        dropdown.visible = false
                        console.log("Lock screen clicked")
                        // Process { command: ["swaylock"] }
                    }
                }
            }

            // power off menu item
            Rectangle {
                width: parent.width
                height: 32
                color: powerArea.containsMouse ? (config.theme?.destructive || "#f38ba8") : "transparent"
                radius: 4

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    spacing: 8

                    Rectangle {
                        width: 16
                        height: 16
                        color: powerArea.containsMouse ? (config.theme?.base || "#1e1e2e") : (config.theme?.destructive || "#f38ba8")
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Power Off"
                        color: powerArea.containsMouse ? (config.theme?.text || "#cdd6f4") : (config.theme?.destructive || "#f38ba8")
                        font.pixelSize: config.panel?.font_size || 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: powerArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        dropdown.visible = false
                        console.log("Power off clicked")
                        // Process { command: ["systemctl", "poweroff"] }
                    }
                }
            }
        }
    }

    // simple auto-hide timer
    Timer {
        id: autoHideTimer
        interval: 2000
        running: dropdown.visible
        onTriggered: {
            dropdown.visible = false
        }
    }
}