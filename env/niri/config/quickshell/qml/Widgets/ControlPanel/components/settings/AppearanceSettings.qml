import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data

// Appearance settings content
Column {
    width: parent.width
    spacing: 20
    
    // Theme Setting in Collapsible Section
    SettingsCategory {
        width: parent.width
        title: "Theme Setting"
        icon: "palette"
        
        content: Component {
            Column {
                width: parent.width
                spacing: 30  // Increased spacing between major sections
                
                // Dark/Light Mode Switch
                Column {
                    width: parent.width
                    spacing: 12
                    
                    Text {
                        text: "Theme Mode"
                        color: Data.ThemeManager.fgColor
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "Roboto"
                    }
                    
                    Row {
                        spacing: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Text {
                            text: "Light"
                            color: Data.ThemeManager.fgColor
                            font.pixelSize: 14
                            font.family: "Roboto"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        // Toggle switch - enhanced design
                        Rectangle {
                            width: 64
                            height: 32
                            radius: 16
                            color: Data.ThemeManager.currentTheme.type === "dark" ? 
                                   Qt.lighter(Data.ThemeManager.accentColor, 0.8) : 
                                   Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.2)
                            border.width: 2
                            border.color: Data.ThemeManager.currentTheme.type === "dark" ? 
                                         Data.ThemeManager.accentColor : 
                                         Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.4)
                            anchors.verticalCenter: parent.verticalCenter
                            
                            // Inner track shadow
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 2
                                radius: parent.radius - 2
                                color: "transparent"
                                border.width: 1
                                border.color: Qt.rgba(0, 0, 0, 0.1)
                            }
                            
                            // Toggle handle
                            Rectangle {
                                id: toggleHandle
                                width: 26
                                height: 26
                                radius: 13
                                color: Data.ThemeManager.currentTheme.type === "dark" ? 
                                       Data.ThemeManager.bgColor : Data.ThemeManager.panelBackground
                                border.width: 2
                                border.color: Data.ThemeManager.currentTheme.type === "dark" ? 
                                             Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
                                anchors.verticalCenter: parent.verticalCenter
                                x: Data.ThemeManager.currentTheme.type === "dark" ? parent.width - width - 3 : 3
                                
                                // Handle shadow
                                Rectangle {
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: 1
                                    width: parent.width - 2
                                    height: parent.height - 2
                                    radius: parent.radius - 1
                                    color: Qt.rgba(0, 0, 0, 0.1)
                                    z: -1
                                }
                                
                                // Handle highlight
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width - 6
                                    height: parent.height - 6
                                    radius: parent.radius - 3
                                    color: Qt.rgba(255, 255, 255, 0.15)
                                }
                                
                                Behavior on x {
                                    NumberAnimation { 
                                        duration: 250
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 0.3
                                    }
                                }
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                            }
                            
                            // Background color transition
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                            
                            Behavior on border.color {
                                ColorAnimation { duration: 200 }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onClicked: {
                                    console.log("Theme switch clicked, current:", Data.ThemeManager.currentThemeId)
                                    var currentFamily = Data.ThemeManager.currentThemeId.replace(/_dark$|_light$/, "")
                                    var newType = Data.ThemeManager.currentTheme.type === "dark" ? "light" : "dark"
                                    var newThemeId = currentFamily + "_" + newType
                                    console.log("Switching to:", newThemeId)
                                    Data.ThemeManager.setTheme(newThemeId)
                                    
                                    // Force update the settings if currentTheme isn't being saved properly
                                    if (!Data.Settings.currentTheme) {
                                        Data.Settings.currentTheme = newThemeId
                                        Data.Settings.saveSettings()
                                    }
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
                        
                        Text {
                            text: "Dark"
                            color: Data.ThemeManager.fgColor
                            font.pixelSize: 14
                            font.family: "Roboto"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    width: parent.width - 40
                    height: 1
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.1)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // Theme Selection
                Column {
                    width: parent.width
                    spacing: 12
                    
                    Text {
                        text: "Theme Family"
                        color: Data.ThemeManager.fgColor
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "Roboto"
                    }
                    
                    Text {
                        text: "Choose your preferred theme family"
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                        font.pixelSize: 13
                        font.family: "Roboto"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    // Compact 2x2 grid for themes
                    GridLayout {
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        property var themeFamily: {
                            var currentFamily = Data.ThemeManager.currentThemeId.replace(/_dark$|_light$/, "")
                            return currentFamily
                        }
                        
                        property var themeFamilies: [
                            { id: "oxocarbon", name: "Oxocarbon", description: "IBM Carbon" },
                            { id: "dracula", name: "Dracula", description: "Vibrant" },
                            { id: "gruvbox", name: "Gruvbox", description: "Retro" },
                            { id: "catppuccin", name: "Catppuccin", description: "Pastel" },
                            { id: "matugen", name: "Matugen", description: "Generated" }
                        ]
                        
                        Repeater {
                            model: parent.themeFamilies
                            delegate: Rectangle {
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 50
                                radius: 10
                                color: parent.themeFamily === modelData.id ? 
                                       Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                                border.width: parent.themeFamily === modelData.id ? 2 : 1
                                border.color: parent.themeFamily === modelData.id ? 
                                             Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                                
                                Row {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 10
                                    spacing: 6
                                    
                                    // Compact theme preview colors
                                    Row {
                                        spacing: 1
                                        property var previewTheme: Data.ThemeManager.themes[modelData.id + "_" + Data.ThemeManager.currentTheme.type] || Data.ThemeManager.themes[modelData.id + "_dark"]
                                        Rectangle { width: 4; height: 14; radius: 1; color: parent.previewTheme.base00 }
                                        Rectangle { width: 4; height: 14; radius: 1; color: parent.previewTheme.base0E }
                                        Rectangle { width: 4; height: 14; radius: 1; color: parent.previewTheme.base0D }
                                        Rectangle { width: 4; height: 14; radius: 1; color: parent.previewTheme.base0B }
                                    }
                                    
                                    Column {
                                        spacing: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Text {
                                            text: modelData.name
                                            color: parent.parent.parent.parent.themeFamily === modelData.id ? 
                                                   Data.ThemeManager.bgColor : Data.ThemeManager.fgColor
                                            font.pixelSize: 12
                                            font.bold: parent.parent.parent.parent.themeFamily === modelData.id
                                            font.family: "Roboto"
                                        }
                                        
                                        Text {
                                            text: modelData.description
                                            color: parent.parent.parent.parent.themeFamily === modelData.id ? 
                                                   Qt.rgba(Data.ThemeManager.bgColor.r, Data.ThemeManager.bgColor.g, Data.ThemeManager.bgColor.b, 0.8) : 
                                                   Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                                            font.pixelSize: 9
                                            font.family: "Roboto"
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    
                                    onClicked: {
                                        var themeType = Data.ThemeManager.currentTheme.type
                                        var newThemeId = modelData.id + "_" + themeType
                                        console.log("Theme card clicked:", newThemeId)
                                        Data.ThemeManager.setTheme(newThemeId)
                                    }
                                    
                                    onEntered: {
                                        parent.scale = 1.02
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
                    }
                }
                
                // Separator
                Rectangle {
                    width: parent.width - 40
                    height: 1
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.1)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // Accent Colors
                Column {
                    width: parent.width
                    spacing: 12
                    
                    Text {
                        text: "Accent Colors"
                        color: Data.ThemeManager.fgColor
                        font.pixelSize: 15
                        font.bold: true
                        font.family: "Roboto"
                    }
                    
                    Text {
                        text: "Choose your preferred accent color for " + Data.ThemeManager.currentTheme.name
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                        font.pixelSize: 13
                        font.family: "Roboto"
                        wrapMode: Text.Wrap
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    // Compact flow layout for accent colors
                    Flow {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 20 // Margins to prevent clipping
                        spacing: 8
                        
                        property var accentColors: {
                            var currentFamily = Data.ThemeManager.currentThemeId.replace(/_dark$|_light$/, "")
                            var themeColors = []
                            
                            // Theme-specific accent colors - reduced to 5 per theme for compactness
                            if (currentFamily === "dracula") {
                                themeColors.push(
                                    { name: "Magenta", dark: "#ff79c6", light: "#e91e63" },
                                    { name: "Purple", dark: "#bd93f9", light: "#6c7ce0" },
                                    { name: "Cyan", dark: "#8be9fd", light: "#17a2b8" },
                                    { name: "Green", dark: "#50fa7b", light: "#27ae60" },
                                    { name: "Orange", dark: "#ffb86c", light: "#f39c12" }
                                )
                            } else if (currentFamily === "gruvbox") {
                                themeColors.push(
                                    { name: "Orange", dark: "#fe8019", light: "#d65d0e" },
                                    { name: "Red", dark: "#fb4934", light: "#cc241d" },
                                    { name: "Yellow", dark: "#fabd2f", light: "#d79921" },
                                    { name: "Green", dark: "#b8bb26", light: "#98971a" },
                                    { name: "Purple", dark: "#d3869b", light: "#b16286" }
                                )
                            } else if (currentFamily === "catppuccin") {                            
                                themeColors.push(
                                    { name: "Mauve", dark: "#cba6f7", light: "#8839ef" },
                                    { name: "Blue", dark: "#89b4fa", light: "#1e66f5" },
                                    { name: "Teal", dark: "#94e2d5", light: "#179299" },
                                    { name: "Green", dark: "#a6e3a1", light: "#40a02b" },
                                    { name: "Peach", dark: "#fab387", light: "#fe640b" }
                                )
                            } else if (currentFamily === "matugen") {
                                // Use dynamic matugen colors if available
                                if (Data.ThemeManager.matugen && Data.ThemeManager.matugen.isMatugenActive()) {
                                    themeColors.push(
                                        { name: "Primary", dark: Data.ThemeManager.matugen.getMatugenColor("primary") || "#adc6ff", light: Data.ThemeManager.matugen.getMatugenColor("primary") || "#0f62fe" },
                                        { name: "Secondary", dark: Data.ThemeManager.matugen.getMatugenColor("secondary") || "#bfc6dc", light: Data.ThemeManager.matugen.getMatugenColor("secondary") || "#6272a4" },
                                        { name: "Tertiary", dark: Data.ThemeManager.matugen.getMatugenColor("tertiary") || "#debcdf", light: Data.ThemeManager.matugen.getMatugenColor("tertiary") || "#b16286" },
                                        { name: "Surface", dark: Data.ThemeManager.matugen.getMatugenColor("surface_tint") || "#adc6ff", light: Data.ThemeManager.matugen.getMatugenColor("surface_tint") || "#0f62fe" },
                                        { name: "Error", dark: Data.ThemeManager.matugen.getMatugenColor("error") || "#ffb4ab", light: Data.ThemeManager.matugen.getMatugenColor("error") || "#ba1a1a" }
                                    )
                                } else {
                                    // Fallback matugen colors
                                    themeColors.push(
                                        { name: "Primary", dark: "#adc6ff", light: "#0f62fe" },
                                        { name: "Secondary", dark: "#bfc6dc", light: "#6272a4" },
                                        { name: "Tertiary", dark: "#debcdf", light: "#b16286" },
                                        { name: "Surface", dark: "#adc6ff", light: "#0f62fe" },
                                        { name: "Error", dark: "#ffb4ab", light: "#ba1a1a" }
                                    )
                                }
                            } else { // oxocarbon and fallback
                                themeColors.push(
                                    { name: "Purple", dark: "#be95ff", light: "#8a3ffc" },
                                    { name: "Blue", dark: "#78a9ff", light: "#0f62fe" },
                                    { name: "Cyan", dark: "#3ddbd9", light: "#007d79" },
                                    { name: "Green", dark: "#42be65", light: "#198038" },
                                    { name: "Pink", dark: "#ff7eb6", light: "#d12771" }
                                )
                            }
                            
                            return themeColors
                        }
                        
                        Repeater {
                            model: parent.accentColors
                            delegate: Rectangle {
                                width: 60
                                height: 50
                                radius: 10
                                color: Qt.lighter(Data.ThemeManager.bgColor, 1.15)
                                border.width: Data.ThemeManager.accentColor.toString() === (Data.ThemeManager.currentTheme.type === "dark" ? modelData.dark : modelData.light) ? 3 : 1
                                border.color: Data.ThemeManager.accentColor.toString() === (Data.ThemeManager.currentTheme.type === "dark" ? modelData.dark : modelData.light) ? 
                                             Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    
                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: Data.ThemeManager.currentTheme.type === "dark" ? modelData.dark : modelData.light
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    
                                    Text {
                                        text: modelData.name
                                        color: Data.ThemeManager.fgColor
                                        font.pixelSize: 9
                                        font.family: "Roboto"
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    
                                    onClicked: {
                                        // Set custom accent
                                        Data.Settings.useCustomAccent = true
                                        Data.ThemeManager.setCustomAccent(modelData.dark, modelData.light)
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
                    }
                }
            }
        }
    }
    
    // Animation Settings in Collapsible Section
    SettingsCategory {
        width: parent.width
        title: "Animation Settings"
        icon: "animation"
        
        content: Component {
            Column {
                width: parent.width
                spacing: 20
                
                Text {
                    text: "Configure workspace change animations"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                    font.pixelSize: 13
                    font.family: "Roboto"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // Workspace Burst Toggle
                Row {
                    width: parent.width
                    height: 40
                    
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 80
                        
                        Text {
                            text: "Workspace Burst Effect"
                            color: Data.ThemeManager.fgColor
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "Roboto"
                        }
                        
                        Text {
                            text: "Expanding rings when switching workspaces"
                            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                            font.pixelSize: 11
                            font.family: "Roboto"
                        }
                    }
                    
                    // Toggle switch for burst
                    Rectangle {
                        width: 50
                        height: 25
                        radius: 12.5
                        anchors.verticalCenter: parent.verticalCenter
                        //anchors.right: parent.right
                        color: Data.Settings.workspaceBurstEnabled ? 
                               Qt.lighter(Data.ThemeManager.accentColor, 0.8) : 
                               Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.2)
                        border.width: 1
                        border.color: Data.Settings.workspaceBurstEnabled ? 
                                     Data.ThemeManager.accentColor : 
                                     Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.4)
                        
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: Data.ThemeManager.bgColor
                            border.width: 1.5
                            border.color: Data.Settings.workspaceBurstEnabled ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
                            //anchors.verticalCenter: parent.verticalCenter
                            x: Data.Settings.workspaceBurstEnabled ? parent.width - width - 2.5 : 2.5
                            
                            Behavior on x {
                                NumberAnimation { 
                                    duration: 200
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Data.Settings.workspaceBurstEnabled = !Data.Settings.workspaceBurstEnabled
                            }
                        }
                    }
                }
                
                // Workspace Glow Toggle
                Row {
                    width: parent.width
                    height: 40
                    
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 80
                        
                        Text {
                            text: "Workspace Shadow Glow"
                            color: Data.ThemeManager.fgColor
                            font.pixelSize: 14
                            font.bold: true
                            font.family: "Roboto"
                        }
                        
                        Text {
                            text: "Accent color glow in workspace shadow"
                            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                            font.pixelSize: 11
                            font.family: "Roboto"
                        }
                    }
                    
                    // Toggle switch for glow
                    Rectangle {
                        width: 50
                        height: 25
                        radius: 12.5
                        anchors.verticalCenter: parent.verticalCenter
                        //anchors.right: parent.right
                        color: Data.Settings.workspaceGlowEnabled ? 
                               Qt.lighter(Data.ThemeManager.accentColor, 0.8) : 
                               Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.2)
                        border.width: 1
                        border.color: Data.Settings.workspaceGlowEnabled ? 
                                     Data.ThemeManager.accentColor : 
                                     Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.4)
                        
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: Data.ThemeManager.bgColor
                            border.width: 1.5
                            border.color: Data.Settings.workspaceGlowEnabled ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
                            anchors.verticalCenter: parent.verticalCenter
                            x: Data.Settings.workspaceGlowEnabled ? parent.width - width - 2.5 : 2.5
                            
                            Behavior on x {
                                NumberAnimation { 
                                    duration: 200
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Data.Settings.workspaceGlowEnabled = !Data.Settings.workspaceGlowEnabled
                            }
                        }
                    }
                }
            }
        }
    }
} 
