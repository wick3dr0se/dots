import QtQuick
import "root:/Data" as Data
import "../components/system" as SystemComponents

// Wallpaper tab content
Item {
    id: wallpaperTab
    
    property bool isActive: false
    
    Column {
        anchors.fill: parent
        spacing: 16

        Text {
            text: "Wallpapers"
            color: Data.ThemeManager.accentColor
            font.pixelSize: 18
            font.bold: true
            font.family: "Roboto"
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
                active: wallpaperTab.isActive
                sourceComponent: active ? wallpaperSelectorComponent : null
            }
        }
    }
    
    Component {
        id: wallpaperSelectorComponent
        SystemComponents.WallpaperSelector {
            isVisible: parent && parent.parent && parent.parent.visible
        }
    }
} 