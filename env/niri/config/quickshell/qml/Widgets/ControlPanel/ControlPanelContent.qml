import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "root:/Data" as Data
import "./components/navigation" as Navigation

// Panel content with tab layout - now clean and organized!
Item {
    id: contentRoot
    
    // Properties passed from parent
    required property var shell
    required property bool isRecording
    property int currentTab: 0
    property var tabIcons: []
    required property var triggerMouseArea
    
    // Signals to forward to parent
    signal recordingRequested()
    signal stopRecordingRequested()
    signal systemActionRequested(string action)
    signal performanceActionRequested(string action)
    
    // Hover detection for auto-hide
    property bool isHovered: {
        const mouseStates = {
            triggerHovered: triggerMouseArea.containsMouse,
            backgroundHovered: backgroundMouseArea.containsMouse,
            tabSidebarHovered: tabNavigation.containsMouse,
            tabContainerHovered: tabContainer.isHovered,
            tabContentActive: currentTab !== 0, // Non-main tabs stay open
            tabNavigationActive: tabNavigation.containsMouse
        }
        return Object.values(mouseStates).some(state => state)
    }
    
    // Expose text input focus state for keyboard management
    property bool textInputFocused: tabContainer.textInputFocused

    // Panel background with bottom-only rounded corners
    Rectangle {
        anchors.fill: parent
        color: Data.ThemeManager.bgColor
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: 20
        bottomRightRadius: 20
        z: -10  // Far behind everything to avoid layering conflicts
    }

    // Main content container with tab layout
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        anchors.margins: 9
        color: "transparent"
        radius: 12
        
        MouseArea {
            id: backgroundMouseArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            property alias containsMouse: backgroundMouseArea.containsMouse
        }

        // Left sidebar with tab navigation
        Navigation.TabNavigation {
            id: tabNavigation
            width: 40
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 9
            anchors.top: parent.top
            anchors.topMargin: 18

            currentTab: contentRoot.currentTab
            tabIcons: contentRoot.tabIcons
            
            onCurrentTabChanged: contentRoot.currentTab = currentTab
        }

        // Main tab content area with sliding animation
        Navigation.TabContainer {
            id: tabContainer
            width: parent.width - tabNavigation.width - 45
            height: parent.height - 36
            anchors.left: tabNavigation.right
            anchors.leftMargin: 9
            anchors.top: parent.top
            anchors.topMargin: 18

            shell: contentRoot.shell
            isRecording: contentRoot.isRecording
            triggerMouseArea: contentRoot.triggerMouseArea
            currentTab: contentRoot.currentTab
            
            onRecordingRequested: contentRoot.recordingRequested()
            onStopRecordingRequested: contentRoot.stopRecordingRequested()
            onSystemActionRequested: function(action) { contentRoot.systemActionRequested(action) }
            onPerformanceActionRequested: function(action) { contentRoot.performanceActionRequested(action) }
        }
    }

} 