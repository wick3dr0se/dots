import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "root:/Data" as Data

// Night light widget with pure Qt overlay (no external dependencies)
Rectangle {
    id: root
    property var shell: null
    color: Qt.darker(Data.ThemeManager.bgColor, 1.15)
    radius: 20

    property bool containsMouse: nightLightMouseArea.containsMouse
    property bool isActive: Data.Settings.nightLightEnabled
    property real warmth: Data.Settings.nightLightWarmth  // 0=no filter, 1=very warm (0-1 scale)
    property real strength: isActive ? warmth : 0
    property bool autoSchedulerActive: false  // Flag to prevent manual override during auto changes

    signal entered()
    signal exited()

    // Night light overlay window
    property var overlayWindow: null

    // Hover state management for parent components
    onContainsMouseChanged: {
        if (containsMouse) {
            entered()
        } else {
            exited()
        }
    }

    // Background with warm tint when active
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: isActive ? Qt.rgba(1.0, 0.6, 0.2, 0.15) : "transparent"
        
        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }

    MouseArea {
        id: nightLightMouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        // Right-click to cycle through warmth levels
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                cycleWarmth()
            } else {
                toggleNightLight()
            }
        }
    }

    // Night light icon with dynamic color
    Text {
        anchors.centerIn: parent
        text: isActive ? "light_mode" : "dark_mode"
        font.pixelSize: 24
        font.family: "Material Symbols Outlined"
        color: isActive ? 
               Qt.rgba(1.0, 0.8 - strength * 0.3, 0.4 - strength * 0.2, 1.0) :  // Warm orange when active
               (containsMouse ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor)
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }

    // Warmth indicator dots
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 3
        visible: isActive && containsMouse
        
        Repeater {
            model: 3
            delegate: Rectangle {
                width: 4
                height: 4
                radius: 2
                color: index < Math.ceil(warmth * 3) ? 
                       Qt.rgba(1.0, 0.7 - index * 0.2, 0.3, 0.8) : 
                       Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }
    }

    // Watch for settings changes
    Connections {
        target: Data.Settings
        function onNightLightEnabledChanged() {
            if (Data.Settings.nightLightEnabled) {
                createOverlay()
            } else {
                removeOverlay()
            }
            
            // Set manual override flag if this wasn't an automatic change
            if (!autoSchedulerActive) {
                Data.Settings.nightLightManualOverride = true
                Data.Settings.nightLightManuallyEnabled = Data.Settings.nightLightEnabled
                console.log("Manual night light change detected - override enabled, manually set to:", Data.Settings.nightLightEnabled)
            }
        }
        function onNightLightWarmthChanged() {
            updateOverlay()
        }
    }
    
    // Functions to control night light
    function toggleNightLight() {
        Data.Settings.nightLightEnabled = !Data.Settings.nightLightEnabled
    }

    function cycleWarmth() {
        // Cycle through warmth levels: 0.2 -> 0.4 -> 0.6 -> 1.0 -> 0.2
        var newWarmth = warmth >= 1.0 ? 0.2 : (warmth >= 0.6 ? 1.0 : warmth + 0.2)
        Data.Settings.nightLightWarmth = newWarmth
    }

    function createOverlay() {
        if (overlayWindow) return

        var qmlString = `
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: nightLightOverlay
    screen: Quickshell.primaryScreen || Quickshell.screens[0]
    
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    
    color: "transparent"
    
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-nightlight"
    exclusiveZone: 0
    
    // Click-through overlay
    mask: Region {}
    
    Rectangle {
        id: overlayRect
        anchors.fill: parent
        color: "transparent"  // Initial color, will be set by parent
        
        // Smooth transitions when warmth changes
        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }
    
    // Function to update overlay color
    function updateColor(newWarmth) {
        overlayRect.color = Qt.rgba(1.0, 0.8 - newWarmth * 0.4, 0.3 - newWarmth * 0.25, 0.1 + newWarmth * 0.2)
    }
}
        `

        try {
            overlayWindow = Qt.createQmlObject(qmlString, root)
            // Set initial color
            updateOverlay()
        } catch (e) {
            console.error("Failed to create night light overlay:", e)
        }
    }

    function updateOverlay() {
        if (overlayWindow && overlayWindow.updateColor) {
            overlayWindow.updateColor(warmth)
        }
    }

    function removeOverlay() {
        if (overlayWindow) {
            overlayWindow.destroy()
            overlayWindow = null
        }
    }

    // Preset warmth levels for easy access
    function setLow() { Data.Settings.nightLightWarmth = 0.2 }        // Light warmth
    function setMedium() { Data.Settings.nightLightWarmth = 0.4 }     // Medium warmth  
    function setHigh() { Data.Settings.nightLightWarmth = 0.6 }       // High warmth
    function setMax() { Data.Settings.nightLightWarmth = 1.0 }        // Maximum warmth

    // Auto-enable based on time (basic sunset/sunrise simulation)
    Timer {
        interval: 60000  // Check every minute
        running: true
        repeat: true
        onTriggered: checkAutoEnable()
    }

    function checkAutoEnable() {
        if (!Data.Settings.nightLightAuto) return
        
        var now = new Date()
        var hour = now.getHours()
        var minute = now.getMinutes()
        var startHour = Data.Settings.nightLightStartHour || 20
        var endHour = Data.Settings.nightLightEndHour || 6
        
        // Handle overnight schedules (e.g., 20:00 to 6:00)
        var shouldBeActive = false
        if (startHour > endHour) {
            // Overnight: active from startHour onwards OR before endHour
            shouldBeActive = (hour >= startHour || hour < endHour)
        } else if (startHour < endHour) {
            // Same day: active between startHour and endHour
            shouldBeActive = (hour >= startHour && hour < endHour)
        } else {
            // startHour === endHour: never auto-enable
            shouldBeActive = false
        }
        
        // Debug logging
        console.log(`Night Light Auto Check: ${hour}:${minute.toString().padStart(2, '0')} - Should be active: ${shouldBeActive}, Currently active: ${Data.Settings.nightLightEnabled}, Manual override: ${Data.Settings.nightLightManualOverride}`)
        
        // Smart override logic - only block conflicting actions
        if (Data.Settings.nightLightManualOverride) {
            // If user manually enabled, allow auto-disable but block auto-enable
            if (Data.Settings.nightLightManuallyEnabled && !shouldBeActive && Data.Settings.nightLightEnabled) {
                console.log("Auto-disabling night light (respecting schedule after manual enable)")
                autoSchedulerActive = true
                Data.Settings.nightLightEnabled = false
                Data.Settings.nightLightManualOverride = false  // Reset after respecting schedule
                autoSchedulerActive = false
                return
            }
            // If user manually disabled, block auto-enable until next cycle
            else if (!Data.Settings.nightLightManuallyEnabled && shouldBeActive && !Data.Settings.nightLightEnabled) {
                // Check if this is the start of a new schedule cycle
                var isNewCycle = (hour === startHour && minute === 0)
                if (isNewCycle) {
                    console.log("New schedule cycle starting - resetting manual override")
                    Data.Settings.nightLightManualOverride = false
                } else {
                    console.log("Manual disable override active - skipping auto-enable")
                    return
                }
            }
            // Other cases - reset override and continue
            else {
                Data.Settings.nightLightManualOverride = false
            }
        }
        
        // Auto-enable when schedule starts
        if (shouldBeActive && !Data.Settings.nightLightEnabled) {
            console.log("Auto-enabling night light")
            autoSchedulerActive = true
            Data.Settings.nightLightEnabled = true
            autoSchedulerActive = false
        }
        // Auto-disable when schedule ends
        else if (!shouldBeActive && Data.Settings.nightLightEnabled) {
            console.log("Auto-disabling night light")
            autoSchedulerActive = true
            Data.Settings.nightLightEnabled = false
            autoSchedulerActive = false
        }
    }

    // Cleanup on destruction
    Component.onDestruction: {
        removeOverlay()
    }

    // Initialize overlay state based on settings
    Component.onCompleted: {
        if (Data.Settings.nightLightEnabled) {
            createOverlay()
        }
    }
}