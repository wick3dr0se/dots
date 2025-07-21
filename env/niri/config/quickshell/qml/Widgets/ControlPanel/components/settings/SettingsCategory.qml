import QtQuick
import QtQuick.Controls
import "root:/Data" as Data

// Reusable collapsible settings category component
Item {
    id: categoryRoot
    
    property string title: ""
    property string icon: ""
    property bool expanded: false
    property alias content: contentLoader.sourceComponent
    
    height: headerRect.height + (expanded ? contentLoader.height + 20 : 0)
    
    Behavior on height {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    
    // Category header
    Rectangle {
        id: headerRect
        width: parent.width
        height: 50
        radius: 12
        color: expanded ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.1) : 
                         Qt.lighter(Data.ThemeManager.bgColor, 1.15)
        border.width: expanded ? 2 : 1
        border.color: expanded ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
        
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 16
            spacing: 12
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: categoryRoot.icon
                font.family: "Material Symbols Outlined"
                font.pixelSize: 20
                color: expanded ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: categoryRoot.title
                color: expanded ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
        }
        
        // Expand/collapse arrow
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 16
            text: expanded ? "expand_less" : "expand_more"
            font.family: "Material Symbols Outlined"
            font.pixelSize: 20
            color: expanded ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
            
            Behavior on rotation {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                categoryRoot.expanded = !categoryRoot.expanded
            }
        }
    }
    
    // Category content
    Loader {
        id: contentLoader
        anchors.top: headerRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: expanded ? 20 : 0
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        
        visible: expanded
        opacity: expanded ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }
} 