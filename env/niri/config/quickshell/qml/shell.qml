import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import QtQuick

import "root:/Data" as Data
import "root:/Services" as Services
import "root:/Layout" as Layout
import "root:/Widgets/Lockscreen"

ShellRoot {
    id: root

    property var shellInstance: Quickshell.shell
    property var notificationService

    property var defaultAudioSink: Pipewire.defaultAudioSink
    property int volume: defaultAudioSink && defaultAudioSink.audio ? Math.round(defaultAudioSink.audio.volume * 100) : 0

    property var notificationWindow: null  // Set by Desktop.qml
    property var notificationServer: notificationService ? notificationService.notificationServer : null

    // Notification history management
    property ListModel notificationHistory: ListModel {
        Component.onDestruction: clear()
    }
    property int maxHistoryItems: Data.Settings.historyLimit
    property int cleanupThreshold: maxHistoryItems + 5

    property string weatherLocation: Data.Settings.weatherLocation
    property var weatherData: null
    property bool weatherLoading: false
    property alias weatherService: weatherService

    property alias lockscreen: lockscreen

    Layout.Desktop {
        id: desktop
        shell: root
        notificationService: notificationService
    }

    Services.NotificationService {
        id: notificationService
        shell: root
    }

    Services.WeatherService {
        id: weatherService
        shell: root
    }

    Services.MatugenService {
        id: matugenService
        shell: root
    }

    Lockscreen {
        id: lockscreen
        shell: root
    }

    Component.onCompleted: {
        weatherService.loadWeather()
        
        // Connect MatugenService to the Matugen theme
        Data.ThemeManager.matugen.setMatugenService(matugenService)
        console.log("MatugenService connected to Matugen theme")
        
        // Register service with MatugenManager for global access
        Data.MatugenManager.setService(matugenService)
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function addToNotificationHistory(notification) {
        notificationHistory.insert(0, {
            appName: notification.appName,
            summary: notification.summary,
            body: notification.body,
            timestamp: new Date(),
            icon: notification.appIcon ? String(notification.appIcon) : ""
        })

        // Immediate cleanup when threshold exceeded
        if (notificationHistory.count > cleanupThreshold) {
            const removeCount = notificationHistory.count - maxHistoryItems
            notificationHistory.remove(maxHistoryItems, removeCount)
        }
    }

    // Periodic cleanup every 30 minutes
    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: {
            if (notificationHistory.count > maxHistoryItems) {
                const removeCount = notificationHistory.count - maxHistoryItems
                notificationHistory.remove(maxHistoryItems, removeCount)
            }
            
            gc()
        }
    }
    
    // Aggressive memory cleanup every 10 minutes
    Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: {
            // More aggressive cleanup threshold
            if (notificationHistory.count > maxHistoryItems * 0.8) {
                const removeCount = notificationHistory.count - Math.floor(maxHistoryItems * 0.7)
                notificationHistory.remove(Math.floor(maxHistoryItems * 0.7), removeCount)
            }
            
            // Force garbage collection
            gc()
            Qt.callLater(gc)
        }
    }
}
