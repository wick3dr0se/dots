import QtQuick
import "../../tabs" as Tabs

// Tab container with sliding animation
Item {
    id: tabContainer
    
    // Properties from parent
    required property var shell
    required property bool isRecording
    required property var triggerMouseArea
    property int currentTab: 0
    
    // Signals to forward
    signal recordingRequested()
    signal stopRecordingRequested()
    signal systemActionRequested(string action)
    signal performanceActionRequested(string action)
    
    // Hover detection combining all tab hovers
    property bool isHovered: {
        const tabHovers = [
            mainDashboard.isHovered,
            true, // Calendar tab should stay open when active
            true, // Clipboard tab should stay open when active
            true, // Notification tab should stay open when active
            true, // Wallpaper tab should stay open when active
            true, // Music tab should stay open when active
            true  // Settings tab should stay open when active
        ]
        return tabHovers[currentTab] || false
    }
    
    // Track when text inputs have focus for keyboard management
    property bool textInputFocused: currentTab === 6 && settingsTab.anyTextInputFocused
    
    clip: true

    // Sliding content container
    Row {
        id: slidingRow
        width: parent.width * 7  // 7 tabs wide
        height: parent.height
        spacing: 0
        
        // Animate horizontal position based on current tab
        x: -tabContainer.currentTab * tabContainer.width
        
        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        // Tab 0: Main Dashboard
        Tabs.MainDashboard {
            id: mainDashboard
            width: tabContainer.width
            height: parent.height
            
            shell: tabContainer.shell
            isRecording: tabContainer.isRecording
            triggerMouseArea: tabContainer.triggerMouseArea
            
            onRecordingRequested: tabContainer.recordingRequested()
            onStopRecordingRequested: tabContainer.stopRecordingRequested()
            onSystemActionRequested: function(action) { tabContainer.systemActionRequested(action) }
            onPerformanceActionRequested: function(action) { tabContainer.performanceActionRequested(action) }
        }

        // Tab 1: Calendar
        Tabs.CalendarTab {
            id: calendarTab
            width: tabContainer.width
            height: parent.height
            shell: tabContainer.shell
            isActive: tabContainer.currentTab === 1 || Math.abs(tabContainer.currentTab - 1) <= 1
        }

        // Tab 2: Clipboard
        Tabs.ClipboardTab {
            id: clipboardTab
            width: tabContainer.width
            height: parent.height
            shell: tabContainer.shell
            isActive: tabContainer.currentTab === 2 || Math.abs(tabContainer.currentTab - 2) <= 1
        }

        // Tab 3: Notifications
        Tabs.NotificationTab {
            id: notificationTab
            width: tabContainer.width
            height: parent.height
            shell: tabContainer.shell
            isActive: tabContainer.currentTab === 3 || Math.abs(tabContainer.currentTab - 3) <= 1
        }

        // Tab 4: Wallpapers
        Tabs.WallpaperTab {
            id: wallpaperTab
            width: tabContainer.width
            height: parent.height
            isActive: tabContainer.currentTab === 4 || Math.abs(tabContainer.currentTab - 4) <= 1
        }

        // Tab 5: Music
        Tabs.MusicTab {
            id: musicTab
            width: tabContainer.width
            height: parent.height
            shell: tabContainer.shell
            isActive: tabContainer.currentTab === 5 || Math.abs(tabContainer.currentTab - 5) <= 1
        }

        // Tab 6: Settings
        Tabs.SettingsTab {
            id: settingsTab
            width: tabContainer.width
            height: parent.height
            shell: tabContainer.shell
            isActive: tabContainer.currentTab === 6 || Math.abs(tabContainer.currentTab - 6) <= 1
        }
    }
} 