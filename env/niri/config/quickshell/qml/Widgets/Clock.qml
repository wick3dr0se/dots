import QtQuick
import QtQuick.Controls
import Quickshell
import "root:/Data" as Data
import "root:/Core" as Core

// Clock with border integration
Item {
    id: clockRoot
    width: clockBackground.width
    height: clockBackground.height

    Rectangle {
        id: clockBackground
        width: clockText.implicitWidth + 24
        height: 32
        
        color: Data.ThemeManager.bgColor
        
        // Rounded corner for border integration
        topRightRadius: height / 2

        Text {
            id: clockText
            anchors.centerIn: parent
            font.family: "Roboto"
            font.pixelSize: 14
            font.bold: true
            color: Data.ThemeManager.accentColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatTime(new Date(), "HH:mm")
        }
    }

    // Update every minute
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
    }

    // Border integration corner pieces
    Core.Corners {
        id: topLeftCorner
        position: "topleft"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: -39
        offsetY: -26
        z: 0  // Same z-level as clock background
    }
    
    Core.Corners {
        id: topLeftCorner2
        position: "topleft"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: 20
        offsetY: 6
        z: 0  // Same z-level as clock background
    }
}