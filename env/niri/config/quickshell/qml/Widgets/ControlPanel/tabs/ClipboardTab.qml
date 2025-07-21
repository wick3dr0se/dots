import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data
import "root:/Widgets/System" as System

// Clipboard tab content
Item {
    id: clipboardTab
    
    required property var shell
    property bool isActive: false
    
    Column {
        anchors.fill: parent
        spacing: 16

        RowLayout {
            width: parent.width
            spacing: 16

            Text {
                text: "Clipboard History"
                color: Data.ThemeManager.accentColor
                font.pixelSize: 18
                font.bold: true
                font.family: "Roboto"
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: clearClipText.implicitWidth + 16
                height: 24
                radius: 12
                color: clearClipMouseArea.containsMouse ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : "transparent"
                border.color: Data.ThemeManager.accentColor
                border.width: 1

                Text {
                    id: clearClipText
                    anchors.centerIn: parent
                    text: "Clear All"
                    color: Data.ThemeManager.accentColor
                    font.family: "Roboto"
                    font.pixelSize: 11
                }

                MouseArea {
                    id: clearClipMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (clipboardLoader.item && clipboardLoader.item.children[0]) {
                            let clipComponent = clipboardLoader.item.children[0]
                            if (clipComponent.clearClipboardHistory) {
                                clipComponent.clearClipboardHistory()
                            }
                        }
                    }
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
                id: clipboardLoader
                anchors.fill: parent
                anchors.margins: 20
                active: clipboardTab.isActive
                sourceComponent: active ? clipboardHistoryComponent : null
                onLoaded: {
                    if (item && item.children[0]) {
                        item.children[0].refreshClipboardHistory()
                    }
                }
            }
        }
    }
    
    Component {
        id: clipboardHistoryComponent
        Item {
            anchors.fill: parent
            
            System.Cliphist {
                id: cliphistComponent
                anchors.fill: parent
                shell: clipboardTab.shell
                
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