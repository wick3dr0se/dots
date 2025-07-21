import QtQuick
import "root:/Data" as Data

// Tab navigation sidebar
Item {
    id: tabNavigation
    
    property int currentTab: 0
    property var tabIcons: []
    property bool containsMouse: sidebarMouseArea.containsMouse || tabColumn.containsMouse
    
    MouseArea {
        id: sidebarMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
    }

    // Tab button background - matches system controls
    Rectangle {
        width: 38
        height: tabColumn.height + 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
        radius: 19
        border.width: 1
        border.color: Qt.lighter(Data.ThemeManager.bgColor, 1.3)
        
        // Subtle inner shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: Qt.darker(Data.ThemeManager.bgColor, 1.05)
            radius: parent.radius - 1
            opacity: 0.3
        }
    }

    // Tab icon buttons
    Column {
        id: tabColumn
        spacing: 6
        anchors.top: parent.top
        anchors.topMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        
        property bool containsMouse: {
            for (let i = 0; i < tabRepeater.count; i++) {
                const tab = tabRepeater.itemAt(i)
                if (tab && tab.mouseArea && tab.mouseArea.containsMouse) {
                    return true
                }
            }
            return false
        }

        Repeater {
            id: tabRepeater
            model: 7
            delegate: Rectangle {
                width: 30
                height: 30
                radius: 15
                
                // Dynamic background based on state
                color: {
                    if (tabNavigation.currentTab === index) {
                        return Data.ThemeManager.accentColor
                    } else if (tabMouseArea.containsMouse) {
                        return Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.15)
                    } else {
                        return "transparent"
                    }
                }
                
                // Subtle shadow for active tab
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                    border.width: tabNavigation.currentTab === index ? 0 : (tabMouseArea.containsMouse ? 1 : 0)
                    visible: tabNavigation.currentTab !== index
                }
                
                property alias mouseArea: tabMouseArea
                
                MouseArea {
                    id: tabMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        tabNavigation.currentTab = index
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: tabNavigation.tabIcons[index] || ""
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 16
                    color: {
                        if (tabNavigation.currentTab === index) {
                            return Data.ThemeManager.bgColor
                        } else if (tabMouseArea.containsMouse) {
                            return Data.ThemeManager.accentColor
                        } else {
                            return Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                        }
                    }
                    
                    // Smooth color transitions
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                // Smooth transitions
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                // Subtle scale effect on hover
                scale: tabMouseArea.containsMouse ? 1.05 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }
        }
    }
} 