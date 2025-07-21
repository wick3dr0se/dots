import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data
import "../components/settings" as SettingsComponents

// Settings tab content with modular, collapsible categories
Item {
    id: settingsTab
    
    required property var shell
    property bool isActive: false
    
    // Track when any text input has focus for keyboard management
    property bool anyTextInputFocused: {
        try {
            return (notificationSettings && notificationSettings.anyTextInputFocused) ||
                   (systemSettings && systemSettings.anyTextInputFocused) ||
                   (weatherSettings && weatherSettings.anyTextInputFocused)
        } catch (e) {
            return false
        }
    }
    
    // Header
    Text {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        text: "Settings"
        color: Data.ThemeManager.accentColor
        font.pixelSize: 24
        font.bold: true
        font.family: "Roboto"
    }
    
    // Scrollable content
    ScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 16
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        
        clip: true
        contentWidth: width - 5  // Reserve space for scrollbar
        
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        
        Column {
            width: parent.width - 15  // Match contentWidth
            spacing: 16
            
            // VISUAL SETTINGS
            // Appearance Category
            SettingsComponents.SettingsCategory {
                id: appearanceCategory
                width: parent.width
                title: "Appearance"
                icon: "palette"
                
                content: Component {
                    SettingsComponents.AppearanceSettings {
                        width: parent.width
                    }
                }
            }
            
            // ⚙️ CORE SYSTEM SETTINGS
            // System Category
            SettingsComponents.SettingsCategory {
                id: systemCategory
                width: parent.width
                title: "System"
                icon: "settings"
                
                content: Component {
                    SettingsComponents.SystemSettings {
                        id: systemSettings
                        width: parent.width
                    }
                }
            }
            
            // Notifications Category
            SettingsComponents.SettingsCategory {
                id: notificationsCategory
                width: parent.width
                title: "Notifications"
                icon: "notifications"
                
                content: Component {
                    SettingsComponents.NotificationSettings {
                        id: notificationSettings
                        width: parent.width
                    }
                }
            }
            
            // 🎵 MEDIA & EXTERNAL SERVICES
            // Music Player Category
            SettingsComponents.SettingsCategory {
                id: musicPlayerCategory
                width: parent.width
                title: "Music Player"
                icon: "music_note"
                
                content: Component {
                    SettingsComponents.MusicPlayerSettings {
                        width: parent.width
                    }
                }
            }
            
            // Weather Category
            SettingsComponents.SettingsCategory {
                id: weatherCategory
                width: parent.width
                title: "Weather"
                icon: "wb_sunny"
                
                content: Component {
                    SettingsComponents.WeatherSettings {
                        id: weatherSettings
                        width: parent.width
                        shell: settingsTab.shell
                    }
                }
            }
            
            // ACCESSIBILITY & COMFORT
            // Night Light Category
            SettingsComponents.SettingsCategory {
                id: nightLightCategory
                width: parent.width
                title: "Night Light"
                icon: "dark_mode"
                
                content: Component {
                    SettingsComponents.NightLightSettings {
                        width: parent.width
                    }
                }
            }
        }
    }
}
