import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data
import "root:/Widgets/System" as System
import "../components/widgets" as Widgets
import "../components/controls" as Controls
import "../components/system" as SystemComponents

// Main dashboard content (tab 0)
Item {
    id: mainDashboard
    
    // Properties from parent
    required property var shell
    required property bool isRecording
    required property var triggerMouseArea
    
    // Signals to forward
    signal recordingRequested()
    signal stopRecordingRequested()
    signal systemActionRequested(string action)
    signal performanceActionRequested(string action)
    
    // Hover detection for auto-hide
    property bool isHovered: {
        const mouseStates = {
            userProfileHovered: userProfile ? userProfile.isHovered : false,
            weatherDisplayHovered: weatherDisplay ? weatherDisplay.containsMouse : false,
            recordingButtonHovered: recordingButton ? recordingButton.isHovered : false,
            controlsHovered: controls ? controls.containsMouse : false,
            trayHovered: trayMouseArea ? trayMouseArea.containsMouse : false,
            systemTrayHovered: systemTrayModule ? systemTrayModule.containsMouse : false,
            trayMenuHovered: inlineTrayMenu ? inlineTrayMenu.containsMouse : false,
            trayMenuVisible: inlineTrayMenu ? inlineTrayMenu.visible : false
        }
        return Object.values(mouseStates).some(state => state)
    }
    
    // Night Light overlay controller (invisible - manages screen overlay)
    Widgets.NightLight {
        id: nightLightController
        shell: mainDashboard.shell
        visible: false  // This widget manages overlay windows, doesn't need to be visible
    }

    Column {
        anchors.fill: parent
        spacing: 28

        // User profile row with weather
        Row {
            width: parent.width
            spacing: 18

            Widgets.UserProfile {
                id: userProfile
                width: parent.width - weatherDisplay.width - parent.spacing
                height: 80
                shell: mainDashboard.shell
            }

            Widgets.WeatherDisplay {
                id: weatherDisplay
                width: parent.width * 0.18
                height: userProfile.height
                shell: mainDashboard.shell
            }
        }

        // Recording and system controls section
        Column {
            width: parent.width
            spacing: 28

            Widgets.RecordingButton {
                id: recordingButton
                width: parent.width
                height: 48
                shell: mainDashboard.shell
                isRecording: mainDashboard.isRecording

                onRecordingRequested: mainDashboard.recordingRequested()
                onStopRecordingRequested: mainDashboard.stopRecordingRequested()
            }

            Controls.Controls {
                id: controls
                width: parent.width
                isRecording: mainDashboard.isRecording
                shell: mainDashboard.shell
                onPerformanceActionRequested: function(action) { mainDashboard.performanceActionRequested(action) }
                onSystemActionRequested: function(action) { mainDashboard.systemActionRequested(action) }
            }
        }

        // System tray integration with menu
        Column {
            id: systemTraySection
            width: parent.width
            spacing: 8

            property bool containsMouse: trayMouseArea.containsMouse || systemTrayModule.containsMouse

            Rectangle {
                id: trayBackground
                width: parent.width
                height: 40
                radius: 20
                color: Qt.darker(Data.ThemeManager.bgColor, 1.15)

                property bool isActive: false

                MouseArea {
                    id: trayMouseArea
                    anchors.fill: parent
                    anchors.margins: -10
                    hoverEnabled: true
                    propagateComposedEvents: true
                    preventStealing: false
                    onEntered: trayBackground.isActive = true
                    onExited: {
                        // Only deactivate if we're not hovering over tray menu or system tray module
                        if (!inlineTrayMenu.visible && !inlineTrayMenu.containsMouse) {
                            Qt.callLater(function() {
                                if (!systemTrayModule.containsMouse && !inlineTrayMenu.containsMouse && !inlineTrayMenu.visible) {
                                    trayBackground.isActive = false
                                }
                            })
                        }
                    }
                }

                System.SystemTray {
                    id: systemTrayModule
                    anchors.centerIn: parent
                    shell: mainDashboard.shell
                    bar: parent
                    trayMenu: inlineTrayMenu
                }
            }
        }

        SystemComponents.TrayMenu {
            id: inlineTrayMenu
            parent: mainDashboard
            width: parent.width
            menu: null
            systemTrayY: systemTraySection.y
            systemTrayHeight: systemTraySection.height
            z: 100  // High z-index to appear above other content
            onHideRequested: trayBackground.isActive = false
        }
    }
} 