import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data
import "root:/Widgets/Notifications" as Notifications

// Notification tab content
Item {
    id: notificationTab
    
    required property var shell
    property bool isActive: false
    
    Column {
        anchors.fill: parent
        spacing: 16

        RowLayout {
            width: parent.width
            spacing: 16

            Text {
                text: "Notification History"
                color: Data.ThemeManager.accentColor
                font.pixelSize: 18
                font.bold: true
                font.family: "Roboto"
            }

            Text {
                text: "(" + (notificationTab.shell.notificationHistory ? notificationTab.shell.notificationHistory.count : 0) + ")"
                color: Data.ThemeManager.fgColor
                font.family: "Roboto"
                font.pixelSize: 12
                opacity: 0.7
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: clearNotifText.implicitWidth + 16
                height: 24
                radius: 12
                color: clearNotifMouseArea.containsMouse ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : "transparent"
                border.color: Data.ThemeManager.accentColor
                border.width: 1

                Text {
                    id: clearNotifText
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: Data.ThemeManager.accentColor
                    font.family: "Roboto"
                    font.pixelSize: 11
                }

                MouseArea {
                    id: clearNotifMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: notificationTab.shell.notificationHistory.clear()
                }
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height - parent.children[0].height - parent.spacing
            color: Qt.lighter(Data.ThemeManager.bgColor, 1.2)
            radius: 20
            clip: true

            Loader {
                anchors.fill: parent
                anchors.margins: 20
                active: notificationTab.isActive
                sourceComponent: active ? notificationHistoryComponent : null
            }
        }
    }
    
    Component {
        id: notificationHistoryComponent  
        Item {
            anchors.fill: parent
            
            Notifications.NotificationHistory {
                anchors.fill: parent
                shell: notificationTab.shell
                clip: true
                
                Component.onCompleted: {
                    for (let i = 0; i < children.length; i++) {
                        let child = children[i]
                        if (child.objectName === "contentColumn" || child.toString().includes("ColumnLayout")) {
                            if (child.children && child.children.length > 0) {
                                child.children[0].visible = false
                            }
                        }
                    }
                }
            }
        }
    }
} 