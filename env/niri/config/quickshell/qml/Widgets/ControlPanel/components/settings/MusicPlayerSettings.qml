import QtQuick
import QtQuick.Controls
import "root:/Data" as Data

// Music Player settings content
Column {
    width: parent.width
    spacing: 20
    
    // Auto-switch to active player
    Column {
        width: parent.width
        spacing: 12
        
        Text {
            text: "Auto-switch to Active Player"
            color: Data.ThemeManager.fgColor
            font.pixelSize: 16
            font.bold: true
            font.family: "Roboto"
        }
        
        Text {
            text: "Automatically switch to the player that starts playing music"
            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
            font.pixelSize: 13
            font.family: "Roboto"
            wrapMode: Text.Wrap
            width: parent.width
        }
        
        Rectangle {
            width: 200
            height: 35
            radius: 18
            color: Data.Settings.autoSwitchPlayer ? Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.15)
            border.width: 1
            border.color: Data.ThemeManager.accentColor
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            Text {
                anchors.centerIn: parent
                text: Data.Settings.autoSwitchPlayer ? "Enabled" : "Disabled"
                color: Data.Settings.autoSwitchPlayer ? Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
                font.pixelSize: 14
                font.bold: true
                font.family: "Roboto"
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Data.Settings.autoSwitchPlayer = !Data.Settings.autoSwitchPlayer
                }
            }
        }
    }
    
    // Always show player dropdown
    Column {
        width: parent.width
        spacing: 12
        
        Text {
            text: "Always Show Player Dropdown"
            color: Data.ThemeManager.fgColor
            font.pixelSize: 16
            font.bold: true
            font.family: "Roboto"
        }
        
        Text {
            text: "Show the player selection dropdown even with only one player"
            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
            font.pixelSize: 13
            font.family: "Roboto"
            wrapMode: Text.Wrap
            width: parent.width
        }
        
        Rectangle {
            width: 200
            height: 35
            radius: 18
            color: Data.Settings.alwaysShowPlayerDropdown ? Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.15)
            border.width: 1
            border.color: Data.ThemeManager.accentColor
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            Text {
                anchors.centerIn: parent
                text: Data.Settings.alwaysShowPlayerDropdown ? "Enabled" : "Disabled"
                color: Data.Settings.alwaysShowPlayerDropdown ? Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
                font.pixelSize: 14
                font.bold: true
                font.family: "Roboto"
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Data.Settings.alwaysShowPlayerDropdown = !Data.Settings.alwaysShowPlayerDropdown
                }
            }
        }
    }
} 