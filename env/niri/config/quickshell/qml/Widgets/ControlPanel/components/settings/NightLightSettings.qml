import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data

// Night Light settings content
Item {
    id: nightLightSettings
    width: parent.width
    height: contentColumn.height
    
    Column {
        id: contentColumn
        width: parent.width
        spacing: 20
        
        // Night Light Enable Toggle
        Row {
            width: parent.width
            spacing: 16
            
            Column {
                width: parent.width - nightLightToggle.width - 16
                spacing: 4
                
                Text {
                    text: "Enable Night Light"
                    color: Data.ThemeManager.fgColor
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "Roboto"
                }
                
                Text {
                    text: "Reduces blue light to help protect your eyes and improve sleep"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                    font.pixelSize: 13
                    font.family: "Roboto"
                    wrapMode: Text.Wrap
                }
            }
            
            Rectangle {
                id: nightLightToggle
                width: 50
                height: 28
                radius: 14
                color: Data.Settings.nightLightEnabled ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: Data.ThemeManager.bgColor
                    x: Data.Settings.nightLightEnabled ? parent.width - width - 4 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on x {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Data.Settings.nightLightEnabled = !Data.Settings.nightLightEnabled
                    }
                    onEntered: {
                        parent.scale = 1.05
                    }
                    onExited: {
                        parent.scale = 1.0
                    }
                }
                
                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
            }
        }
        
        // Warmth Level Slider
        Column {
            width: parent.width
            spacing: 12
            
            Text {
                text: "Warmth Level"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Text {
                text: "Adjust how warm the screen filter appears"
                color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                font.pixelSize: 13
                font.family: "Roboto"
                wrapMode: Text.Wrap
                width: parent.width
            }
            
            Row {
                width: parent.width
                spacing: 12
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Cool"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                    font.pixelSize: 12
                    font.family: "Roboto"
                }
                
                Slider {
                    id: warmthSlider
                    width: parent.width - 120
                    height: 30
                    from: 0.1
                    to: 1.0
                    value: Data.Settings.nightLightWarmth || 0.4
                    stepSize: 0.1
                    
                    onValueChanged: {
                        Data.Settings.nightLightWarmth = value
                    }
                    
                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.2)
                        
                        Rectangle {
                            width: warmthSlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Qt.rgba(1.0, 0.8 - warmthSlider.value * 0.3, 0.4, 1.0)
                        }
                    }
                    
                    handle: Rectangle {
                        x: warmthSlider.leftPadding + warmthSlider.visualPosition * (warmthSlider.availableWidth - width)
                        y: warmthSlider.topPadding + warmthSlider.availableHeight / 2 - height / 2
                        width: 20
                        height: 20
                        radius: 10
                        color: Data.ThemeManager.accentColor
                        border.color: Qt.lighter(Data.ThemeManager.accentColor, 1.2)
                        border.width: 2
                    }
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Warm"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                    font.pixelSize: 12
                    font.family: "Roboto"
                }
            }
        }
        
        // Auto-enable Toggle
        Row {
            width: parent.width
            spacing: 16
            
            Column {
                width: parent.width - autoToggle.width - 16
                spacing: 4
                
                Text {
                    text: "Auto-enable Schedule"
                    color: Data.ThemeManager.fgColor
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "Roboto"
                }
                
                Text {
                    text: "Automatically turn on night light at sunset/bedtime"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                    font.pixelSize: 13
                    font.family: "Roboto"
                    wrapMode: Text.Wrap
                }
            }
            
            Rectangle {
                id: autoToggle
                width: 50
                height: 28
                radius: 14
                color: Data.Settings.nightLightAuto ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: Data.ThemeManager.bgColor
                    x: Data.Settings.nightLightAuto ? parent.width - width - 4 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on x {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Data.Settings.nightLightAuto = !Data.Settings.nightLightAuto
                    }
                    onEntered: {
                        parent.scale = 1.05
                    }
                    onExited: {
                        parent.scale = 1.0
                    }
                }
                
                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
            }
        }
        
        // Schedule Time Controls - visible when auto-enable is on
        Column {
            width: parent.width
            spacing: 16
            visible: Data.Settings.nightLightAuto
            opacity: Data.Settings.nightLightAuto ? 1.0 : 0.0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            
            Text {
                text: "Schedule Times"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            // Start and End Time Row
            Row {
                width: parent.width
                spacing: 20
                
                // Start Time
                Column {
                    id: startTimeColumn
                    width: (parent.width - parent.spacing) / 2
                    spacing: 8
                    
                    Text {
                        text: "Start Time"
                        color: Data.ThemeManager.fgColor
                        font.pixelSize: 14
                        font.bold: true
                        font.family: "Roboto"
                    }
                    
                    Text {
                        text: "Night light turns on"
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                        font.pixelSize: 12
                        font.family: "Roboto"
                    }
                    
                    Rectangle {
                        id: startTimeButton
                        width: parent.width
                        height: 40
                        radius: 8
                        color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                        border.width: 1
                        border.color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: (Data.Settings.nightLightStartHour || 20).toString().padStart(2, '0') + ":00"
                                color: Data.ThemeManager.fgColor
                                font.pixelSize: 16
                                font.bold: true
                                font.family: "Roboto"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                startTimePopup.open()
                            }
                        }
                    }
                    
                    // Start Time Popup
                    Popup {
                        id: startTimePopup
                        width: startTimeButton.width
                        height: 170
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        y: startTimeButton.y - height - 10
                        x: startTimeButton.x
                        dim: false
                        
                        background: Rectangle {
                            color: Data.ThemeManager.bgColor
                            radius: 12
                            border.width: 2
                            border.color: Data.ThemeManager.accentColor
                        }
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 12
                            
                            Text {
                                text: "Select Start Hour"
                                color: Data.ThemeManager.fgColor
                                font.pixelSize: 14
                                font.bold: true
                                font.family: "Roboto"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            GridLayout {
                                columns: 6
                                columnSpacing: 6
                                rowSpacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Repeater {
                                    model: 24
                                    delegate: Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 4
                                        color: (Data.Settings.nightLightStartHour || 20) === modelData ? 
                                               Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                                        border.width: 1
                                        border.color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.toString().padStart(2, '0')
                                            color: (Data.Settings.nightLightStartHour || 20) === modelData ? 
                                                   Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.family: "Roboto"
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                Data.Settings.nightLightStartHour = modelData
                                                startTimePopup.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // End Time
                Column {
                    id: endTimeColumn
                    width: (parent.width - parent.spacing) / 2
                    spacing: 8
                    
                    Text {
                        text: "End Time"
                        color: Data.ThemeManager.fgColor
                        font.pixelSize: 14
                        font.bold: true
                        font.family: "Roboto"
                    }
                    
                    Text {
                        text: "Night light turns off"
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                        font.pixelSize: 12
                        font.family: "Roboto"
                    }
                    
                    Rectangle {
                        id: endTimeButton
                        width: parent.width
                        height: 40
                        radius: 8
                        color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                        border.width: 1
                        border.color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                text: (Data.Settings.nightLightEndHour || 6).toString().padStart(2, '0') + ":00"
                                color: Data.ThemeManager.fgColor
                                font.pixelSize: 16
                                font.bold: true
                                font.family: "Roboto"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                endTimePopup.open()
                            }
                        }
                    }
                    
                    // End Time Popup
                    Popup {
                        id: endTimePopup
                        width: endTimeButton.width
                        height: 170
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        y: endTimeButton.y - height - 10
                        x: endTimeButton.x
                        dim: false
                        
                        background: Rectangle {
                            color: Data.ThemeManager.bgColor
                            radius: 12
                            border.width: 2
                            border.color: Data.ThemeManager.accentColor
                        }
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 12
                            
                            Text {
                                text: "Select End Hour"
                                color: Data.ThemeManager.fgColor
                                font.pixelSize: 14
                                font.bold: true
                                font.family: "Roboto"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            GridLayout {
                                columns: 6
                                columnSpacing: 6
                                rowSpacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Repeater {
                                    model: 24
                                    delegate: Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 4
                                        color: (Data.Settings.nightLightEndHour || 6) === modelData ? 
                                               Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                                        border.width: 1
                                        border.color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.toString().padStart(2, '0')
                                            color: (Data.Settings.nightLightEndHour || 6) === modelData ? 
                                                   Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.family: "Roboto"
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                Data.Settings.nightLightEndHour = modelData
                                                endTimePopup.close()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
