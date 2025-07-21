import QtQuick
import QtQuick.Controls
import "root:/Data" as Data

// Notification settings content
Item {
    id: notificationSettings
    width: parent.width
    height: contentColumn.height
    
    // Expose the text input focus for parent keyboard management
    property bool anyTextInputFocused: appNameInput.activeFocus
    
    Column {
        id: contentColumn
        width: parent.width
        spacing: 20
        
        // Display Time Setting
        Column {
            width: parent.width
            spacing: 12
            
            Text {
                text: "Display Time"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Text {
                text: "How long notifications stay visible on screen"
                color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                font.pixelSize: 13
                font.family: "Roboto"
                wrapMode: Text.Wrap
                width: parent.width
            }
            
            Row {
                spacing: 16
                width: parent.width
                
                Slider {
                    id: displayTimeSlider
                    width: parent.width - timeLabel.width - 16
                    height: 30
                    from: 2000
                    to: 15000
                    stepSize: 1000
                    value: Data.Settings.displayTime
                    
                    onValueChanged: {
                        Data.Settings.displayTime = value
                    }
                    
                    background: Rectangle {
                        width: displayTimeSlider.availableWidth
                        height: 6
                        radius: 3
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: displayTimeSlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Data.ThemeManager.accentColor
                        }
                    }
                    
                    handle: Rectangle {
                        x: displayTimeSlider.leftPadding + displayTimeSlider.visualPosition * (displayTimeSlider.availableWidth - width)
                        y: displayTimeSlider.topPadding + displayTimeSlider.availableHeight / 2 - height / 2
                        width: 20
                        height: 20
                        radius: 10
                        color: Data.ThemeManager.accentColor
                        border.color: Qt.lighter(Data.ThemeManager.accentColor, 1.2)
                        border.width: 2
                        
                        scale: displayTimeSlider.pressed ? 1.2 : 1.0
                        
                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
                
                Text {
                    id: timeLabel
                    text: (displayTimeSlider.value / 1000).toFixed(1) + "s"
                    color: Data.ThemeManager.fgColor
                    font.pixelSize: 14
                    font.family: "Roboto"
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                }
            }
        }
        
        // Max History Items
        Column {
            width: parent.width
            spacing: 12
            
            Text {
                text: "History Limit"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Text {
                text: "Maximum number of notifications to keep in history"
                color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                font.pixelSize: 13
                font.family: "Roboto"
                wrapMode: Text.Wrap
                width: parent.width
            }
            
            Row {
                spacing: 16
                width: parent.width
                
                Slider {
                    id: historySlider
                    width: parent.width - historyLabel.width - 16
                    height: 30
                    from: 10
                    to: 100
                    stepSize: 5
                    value: Data.Settings.historyLimit
                    
                    onValueChanged: {
                        Data.Settings.historyLimit = value
                    }
                    
                    background: Rectangle {
                        width: historySlider.availableWidth
                        height: 6
                        radius: 3
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: historySlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Data.ThemeManager.accentColor
                        }
                    }
                    
                    handle: Rectangle {
                        x: historySlider.leftPadding + historySlider.visualPosition * (historySlider.availableWidth - width)
                        y: historySlider.topPadding + historySlider.availableHeight / 2 - height / 2
                        width: 20
                        height: 20
                        radius: 10
                        color: Data.ThemeManager.accentColor
                        border.color: Qt.lighter(Data.ThemeManager.accentColor, 1.2)
                        border.width: 2
                        
                        scale: historySlider.pressed ? 1.2 : 1.0
                        
                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
                
                Text {
                    id: historyLabel
                    text: historySlider.value + " items"
                    color: Data.ThemeManager.fgColor
                    font.pixelSize: 14
                    font.family: "Roboto"
                    anchors.verticalCenter: parent.verticalCenter
                    width: 60
                }
            }
        }
        
        // Ignored Apps Setting
        Column {
            width: parent.width
            spacing: 12
            
            Text {
                text: "Ignored Applications"
                color: Data.ThemeManager.fgColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Text {
                text: "Applications that won't show notifications"
                color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                font.pixelSize: 13
                font.family: "Roboto"
                wrapMode: Text.Wrap
                width: parent.width
            }
            
            // Current ignored apps list
            Rectangle {
                width: parent.width
                height: Math.max(100, ignoredAppsFlow.height + 16)
                radius: 12
                color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                border.width: 1
                border.color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                
                Flow {
                    id: ignoredAppsFlow
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    
                    Repeater {
                        model: Data.Settings.ignoredApps
                        delegate: Rectangle {
                            width: appNameText.width + removeButton.width + 16
                            height: 28
                            radius: 14
                            color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.15)
                            border.width: 1
                            border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                
                                Text {
                                    id: appNameText
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData
                                    color: Data.ThemeManager.fgColor
                                    font.pixelSize: 12
                                    font.family: "Roboto"
                                }
                                
                                Rectangle {
                                    id: removeButton
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: removeMouseArea.containsMouse ? 
                                           Qt.rgba(1, 0.3, 0.3, 0.8) : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.5)
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "×"
                                        color: "white"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    
                                    MouseArea {
                                        id: removeMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            Data.Settings.removeIgnoredApp(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Add new app button
                    Rectangle {
                        width: addAppText.width + 36
                        height: 28
                        radius: 14
                        color: addAppMouseArea.containsMouse ? 
                               Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : 
                               Qt.lighter(Data.ThemeManager.bgColor, 1.2)
                        border.width: 2
                        border.color: Data.ThemeManager.accentColor
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "add"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 14
                                color: Data.ThemeManager.accentColor
                            }
                            
                            Text {
                                id: addAppText
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Add App"
                                color: Data.ThemeManager.accentColor
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "Roboto"
                            }
                        }
                        
                        MouseArea {
                            id: addAppMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: addAppPopup.open()
                        }
                    }
                }
            }
            
            // Quick suggestions
            Column {
                width: parent.width
                spacing: 8
                
                Text {
                    text: "Common Apps"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                    font.pixelSize: 12
                    font.family: "Roboto"
                }
                
                Flow {
                    width: parent.width
                    spacing: 6
                    
                    Repeater {
                        model: ["Discord", "Spotify", "Steam", "Firefox", "Chrome", "VSCode", "Slack"]
                        delegate: Rectangle {
                            width: suggestedAppText.width + 16
                            height: 24
                            radius: 12
                            color: suggestionMouseArea.containsMouse ? 
                                   Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.1) : 
                                   "transparent"
                            border.width: 1
                            border.color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                            
                            Text {
                                id: suggestedAppText
                                anchors.centerIn: parent
                                text: modelData
                                color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                                font.pixelSize: 11
                                font.family: "Roboto"
                            }
                            
                            MouseArea {
                                id: suggestionMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Data.Settings.addIgnoredApp(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Add app popup
    Popup {
        id: addAppPopup
        parent: notificationSettings
        width: 280
        height: 160
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            color: Data.ThemeManager.bgColor
            border.color: Data.ThemeManager.accentColor
            border.width: 2
            radius: 20
        }
        
        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width - 40
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Add Ignored App"
                color: Data.ThemeManager.accentColor
                font.pixelSize: 16
                font.bold: true
                font.family: "Roboto"
            }
            
            Rectangle {
                width: parent.width
                height: 40
                radius: 20
                color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                border.width: appNameInput.activeFocus ? 2 : 1
                border.color: appNameInput.activeFocus ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                
                Behavior on border.color {
                    ColorAnimation { duration: 150 }
                }
                
                TextInput {
                    id: appNameInput
                    anchors.fill: parent
                    anchors.margins: 12
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
                            addAppButton.clicked()
                            event.accepted = true
                        }
                    }
                    
                    // Placeholder text implementation
                    Text {
                        anchors.fill: parent
                        anchors.margins: 12
                        text: "App name (e.g. Discord)"
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.5)
                        font.pixelSize: 14
                        font.family: "Roboto"
                        verticalAlignment: Text.AlignVCenter
                        visible: appNameInput.text === ""
                    }
                }
            }
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12
                
                Rectangle {
                    width: 80
                    height: 32
                    radius: 16
                    color: cancelMouseArea.containsMouse ? Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.1) : "transparent"
                    border.width: 1
                    border.color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Data.ThemeManager.fgColor
                        font.pixelSize: 12
                        font.family: "Roboto"
                    }
                    
                    MouseArea {
                        id: cancelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            appNameInput.text = ""
                            addAppPopup.close()
                        }
                    }
                }
                
                Rectangle {
                    id: addAppButton
                    width: 80
                    height: 32
                    radius: 16
                    color: addMouseArea.containsMouse ? Qt.lighter(Data.ThemeManager.accentColor, 1.1) : Data.ThemeManager.accentColor
                    
                    signal clicked()
                    onClicked: {
                        if (appNameInput.text.trim() !== "") {
                            if (Data.Settings.addIgnoredApp(appNameInput.text.trim())) {
                                appNameInput.text = ""
                                addAppPopup.close()
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Add"
                        color: Data.ThemeManager.bgColor
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "Roboto"
                    }
                    
                    MouseArea {
                        id: addMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: parent.clicked()
                    }
                }
            }
        }
        
        onOpened: {
            appNameInput.forceActiveFocus()
        }
    }
} 