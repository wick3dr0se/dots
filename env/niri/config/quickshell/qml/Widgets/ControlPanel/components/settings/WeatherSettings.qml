import QtQuick
import QtQuick.Controls
import "root:/Data" as Data

// Weather settings content
Item {
    id: weatherSettings
    width: parent.width
    height: contentColumn.height
    
    required property var shell
    
    // Expose the text input focus for parent keyboard management
    property bool anyTextInputFocused: locationInput.activeFocus
    
    Column {
        id: contentColumn
        width: parent.width
        spacing: 20
        
        // Location Setting
        Column {
            width: parent.width
            spacing: 8
            
            Text {
                text: "Location"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Row {
                width: parent.width
                spacing: 12
                
                Rectangle {
                    width: parent.width - applyButton.width - 12
                    height: 40
                    radius: 8
                    color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                    border.width: locationInput.activeFocus ? 2 : 1
                    border.color: locationInput.activeFocus ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    TextInput {
                        id: locationInput
                        anchors.fill: parent
                        anchors.margins: 12
                        text: Data.Settings.weatherLocation
                        color: Data.ThemeManager.fgColor
                        font.pixelSize: 14
                        font.family: "Roboto"
                        selectByMouse: true
                        clip: true
                        verticalAlignment: TextInput.AlignVCenter
                        focus: true
                        activeFocusOnTab: true
                        inputMethodHints: Qt.ImhNone
                        
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                applyButton.clicked()
                                event.accepted = true
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                locationInput.forceActiveFocus()
                            }
                        }
                    }
                }
                
                Rectangle {
                    id: applyButton
                    width: 80
                    height: 40
                    radius: 8
                    color: applyMouseArea.containsMouse ? Qt.lighter(Data.ThemeManager.accentColor, 1.1) : Data.ThemeManager.accentColor
                    
                    signal clicked()
                    onClicked: {
                        Data.Settings.weatherLocation = locationInput.text
                        weatherSettings.shell.weatherService.loadWeather()
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Apply"
                        color: Data.ThemeManager.bgColor
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "Roboto"
                    }
                    
                    MouseArea {
                        id: applyMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: parent.clicked()
                    }
                }
            }
        }
        
        // Temperature Units
        Column {
            width: parent.width
            spacing: 12
            
            Text {
                text: "Temperature Units"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Row {
                spacing: 12
                
                Rectangle {
                    width: 80
                    height: 35
                    radius: 18
                    color: !Data.Settings.useFahrenheit ? Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                    border.width: 1
                    border.color: Data.ThemeManager.accentColor
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "°C"
                        color: !Data.Settings.useFahrenheit ? Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
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
                            Data.Settings.useFahrenheit = false
                        }
                    }
                }
                
                Rectangle {
                    width: 80
                    height: 35
                    radius: 18
                    color: Data.Settings.useFahrenheit ? Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                    border.width: 1
                    border.color: Data.ThemeManager.accentColor
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "°F"
                        color: Data.Settings.useFahrenheit ? Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
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
                            Data.Settings.useFahrenheit = true
                        }
                    }
                }
            }
        }
    }
} 