import QtQuick
import QtQuick.Controls
import "root:/Data" as Data

Rectangle {
    id: root
    required property var shell
    required property string iconText
    property string labelText: ""
    
    // Add active state property
    property bool isActive: false
    
    radius: 20
    
    // Modified color logic to handle active state
    color: {
        if (isActive) {
            return mouseArea.containsMouse ? 
                   Qt.lighter(Data.ThemeManager.accentColor, 1.1) : 
                   Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
        } else {
            return mouseArea.containsMouse ? 
                   Qt.lighter(Data.ThemeManager.accentColor, 1.2) : 
                   Qt.lighter(Data.ThemeManager.bgColor, 1.15)
        }
    }
    
    border.width: isActive ? 2 : 1
    border.color: isActive ? Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.3)
    
    signal clicked()
    signal mouseChanged(bool containsMouse)
    property bool isHovered: mouseArea.containsMouse
    readonly property alias containsMouse: mouseArea.containsMouse
    
    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    scale: isHovered ? 1.05 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 2
        
        Text {
            text: root.iconText
            font.family: "Material Symbols Outlined"
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
            color: {
                if (root.isActive) {
                    return root.isHovered ? "#ffffff" : Data.ThemeManager.accentColor
                } else {
                    return root.isHovered ? "#ffffff" : Data.ThemeManager.accentColor
                }
            }
            
            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        Label {
            text: root.labelText
            font.family: "Roboto"
            font.pixelSize: 8
            color: {
                if (root.isActive) {
                    return root.isHovered ? "#ffffff" : Data.ThemeManager.accentColor
                } else {
                    return root.isHovered ? "#ffffff" : Data.ThemeManager.accentColor
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter
            font.weight: root.isActive ? Font.Bold : Font.Medium
            visible: root.labelText !== ""
            
            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onContainsMouseChanged: root.mouseChanged(containsMouse)
        onClicked: root.clicked()
    }
}