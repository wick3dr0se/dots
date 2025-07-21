import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "root:/Data/" as Data

// Notification service with app filtering
Item {
    id: service
    
    property var shell
    property alias notificationServer: notificationServer
    
    property int maxHistorySize: Data.Settings.historyLimit
    property int cleanupThreshold: maxHistorySize + 10
    
    // Periodic cleanup every 30 minutes
    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: cleanupNotifications()
    }
    
    function cleanupNotifications() {
        if (shell.notificationHistory && shell.notificationHistory.count > cleanupThreshold) {
            const removeCount = shell.notificationHistory.count - maxHistorySize
            shell.notificationHistory.remove(maxHistorySize, removeCount)
        }
        
        // Remove invalid entries
        if (shell.notificationHistory) {
            for (let i = shell.notificationHistory.count - 1; i >= 0; i--) {
                const item = shell.notificationHistory.get(i)
                if (!item || !item.appName) {
                    shell.notificationHistory.remove(i)
                }
            }
        }
    }
    
    NotificationServer {
        id: notificationServer
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true
        
        onNotification: (notification) => {
            // Filter empty notifications
            if (!notification.appName && !notification.summary && !notification.body) {
                if (typeof notification.dismiss === 'function') {
                    notification.dismiss()
                }
                return
            }
            
            // Filter ignored applications (case-insensitive)
            var shouldIgnore = false
            if (notification.appName && Data.Settings.ignoredApps && Data.Settings.ignoredApps.length > 0) {
                for (var i = 0; i < Data.Settings.ignoredApps.length; i++) {
                    if (Data.Settings.ignoredApps[i].toLowerCase() === notification.appName.toLowerCase()) {
                        shouldIgnore = true
                        break
                    }
                }
            }
            
            if (shouldIgnore) {
                if (typeof notification.dismiss === 'function') {
                    notification.dismiss()
                }
                return
            }
            
            // Add to history and cleanup if needed
            if (shell.notificationHistory) {
                shell.addToNotificationHistory(notification, maxHistorySize)
                
                if (shell.notificationHistory.count > cleanupThreshold) {
                    cleanupNotifications()
                }
            }
            
            // Show notification window
            if (shell.notificationWindow && shell.notificationWindow.screen === Quickshell.primaryScreen) {
                shell.notificationWindow.visible = true
            }
        }
    }
    
    Component.onDestruction: {
        if (shell.notificationHistory) {
            shell.notificationHistory.clear()
        }
    }
} 