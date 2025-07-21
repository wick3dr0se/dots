import QtQuick
import QtQuick.Controls
import "root:/Data" as Data

// System settings content
Item {
    id: systemSettings
    width: parent.width
    height: contentColumn.height
    
    // Expose the text input focus for parent keyboard management
    property bool anyTextInputFocused: videoPathInput.activeFocus || wallpaperDirectoryInput.activeFocus
    
    Column {
        id: contentColumn
        width: parent.width
        spacing: 20
        
        // Video Recording Path
        Column {
            width: parent.width
            spacing: 8
            
            Text {
                text: "Video Recording Path"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                border.width: videoPathInput.activeFocus ? 2 : 1
                border.color: videoPathInput.activeFocus ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                
                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }
                
                TextInput {
                    id: videoPathInput
                    anchors.fill: parent
                    anchors.margins: 12
                    text: Data.Settings.videoPath
                    color: Data.ThemeManager.fgColor
                    font.pixelSize: 14
                    font.family: "Roboto"
                    selectByMouse: true
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    activeFocusOnTab: true
                    inputMethodHints: Qt.ImhNone
                    
                    onTextChanged: {
                        Data.Settings.videoPath = text
                    }
                    
                    Keys.onPressed: function(event) {
                        // Allow default text input behavior
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        videoPathInput.forceActiveFocus()
                    }
                }
            }
        }
        
        // Wallpaper Directory
        Column {
            width: parent.width
            spacing: 8
            
            Text {
                text: "Wallpaper Directory"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Rectangle {
                width: parent.width
                height: 40
                radius: 8
                color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                border.width: wallpaperDirectoryInput.activeFocus ? 2 : 1
                border.color: wallpaperDirectoryInput.activeFocus ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                
                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }
                
                TextInput {
                    id: wallpaperDirectoryInput
                    anchors.fill: parent
                    anchors.margins: 12
                    text: Data.Settings.wallpaperDirectory
                    color: Data.ThemeManager.fgColor
                    font.pixelSize: 14
                    font.family: "Roboto"
                    selectByMouse: true
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    activeFocusOnTab: true
                    inputMethodHints: Qt.ImhNone
                    
                    onTextChanged: {
                        Data.Settings.wallpaperDirectory = text
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            wallpaperDirectoryInput.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }
} 