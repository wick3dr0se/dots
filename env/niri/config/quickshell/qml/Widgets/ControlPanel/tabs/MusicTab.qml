import QtQuick
import "root:/Data" as Data
import "../components/media" as Media

// Music tab content
Item {
    id: musicTab
    
    required property var shell
    property bool isActive: false
    
    Column {
        anchors.fill: parent
        spacing: 16

        Text {
            text: "Music Player"
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
                active: musicTab.isActive
                sourceComponent: active ? musicPlayerComponent : null
            }
        }
    }
    
    Component {
        id: musicPlayerComponent
        Media.MusicPlayer {
            shell: musicTab.shell
        }
    }
} 