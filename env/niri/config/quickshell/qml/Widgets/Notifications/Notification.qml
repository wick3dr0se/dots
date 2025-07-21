// System notification manager
import QtQuick
import QtQuick.Controls
import Quickshell.Services.Notifications
import "root:/Data" as Data
import "root:/Core" as Core

Item {
    id: root
    required property var shell
    required property var notificationServer

    // Dynamic height based on visible notifications
    property int calculatedHeight: Math.min(notifications.length, maxNotifications) * 100 + 100 // Add 100px for bottom margin

    // Simple array to store notifications with tracking
    property var notifications: []
    property int maxNotifications: 5
    property var animatedNotificationIds: ({})  // Track which notifications have been animated

    // Handle new notifications
    Connections {
        target: notificationServer
        function onNotification(notification) {
            if (!notification || !notification.id) return

            // Filter empty notifications
            if (!notification.appName && !notification.summary && !notification.body) {
                return
            }
            
            // Filter ignored applications (case-insensitive) - same logic as NotificationService
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
                return // Don't display ignored notifications
            }

            // Create simple notification object
            let newNotification = {
                "id": notification.id,
                "appName": notification.appName || "App",
                "summary": notification.summary || "",
                "body": notification.body || "",
                "timestamp": Date.now(),
                "shouldSlideOut": false,
                "icon": notification.icon || notification.image || notification.appIcon || "",
                "rawNotification": notification  // Keep reference to original
            }

            // Add to beginning
            notifications.unshift(newNotification)

            // Trigger model update first to let new notification animate
            notificationsChanged()

            // Delay trimming to let new notification animate
            if (notifications.length > maxNotifications) {
                trimTimer.restart()
            }
        }
    }

    // Timer to delay trimming notifications (let new ones animate first)
    Timer {
        id: trimTimer
        interval: 500  // Wait 500ms before trimming
        running: false
        repeat: false
        onTriggered: {
            if (notifications.length > maxNotifications) {
                notifications = notifications.slice(0, maxNotifications)
                notificationsChanged()
            }
        }
    }

    // Global timer to check for expired notifications
    Timer {
        id: cleanupTimer
        interval: Math.min(500, Data.Settings.displayTime / 10)  // Check every 500ms or 1/10th of display time, whichever is shorter
        running: true
        repeat: true
        onTriggered: {
            let currentTime = Date.now()
            let hasExpiredNotifications = false
            
            // Mark notifications older than displayTime setting for slide-out
            for (let i = 0; i < notifications.length; i++) {
                let notification = notifications[i]
                let age = currentTime - notification.timestamp
                if (age >= Data.Settings.displayTime && !notification.shouldSlideOut) {
                    notification.shouldSlideOut = true
                    hasExpiredNotifications = true
                }
            }
            
            // Trigger update if any notifications were marked for slide-out
            if (hasExpiredNotifications) {
                notificationsChanged()
            }
        }
    }

    function removeNotification(notificationId) {
        let initialLength = notifications.length
        notifications = notifications.filter(function(n) { return n.id !== notificationId })
        if (notifications.length !== initialLength) {
            // Remove from animated tracking
            delete animatedNotificationIds[notificationId]
            notificationsChanged()
        }
    }

    // Simple Column with Repeater
    Column {
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40   // Create space on left for top-left corner
        anchors.rightMargin: Data.Settings.borderWidth + 20  // Border width plus corner space
        anchors.bottomMargin: 100 // Create more space at bottom for bottom corner
        spacing: 0

        Repeater {
            model: notifications.length  // Show all notifications, not just maxNotifications
            
            delegate: Rectangle {
                id: notificationRect
                property var notification: index < notifications.length ? notifications[index] : null
                
                width: 400
                height: 100
                color: Data.ThemeManager.bgColor
                
                // Only bottom visible notification gets bottom-left radius
                radius: 0
                bottomLeftRadius: index === Math.min(notifications.length, maxNotifications) - 1 && index < maxNotifications ? 15 : 0
                
                // Only show if within maxNotifications limit
                visible: index < maxNotifications
                
                // Animation state
                property bool hasSlideIn: false
                
                // Check for expiration and start slide-out if needed
                onNotificationChanged: {
                    if (notification && notification.shouldSlideOut && !slideOutAnimation.running) {
                        slideOutAnimation.start()
                    }
                }

                // Start off-screen for new notifications
                Component.onCompleted: {
                    if (notification) {
                        // Check if notification should slide out immediately
                        if (notification.shouldSlideOut) {
                            slideOutAnimation.start()
                            return
                        }
                        
                        // Check if this notification is truly new (recently added)
                        let notificationAge = Date.now() - notification.timestamp
                        let shouldAnimate = !animatedNotificationIds[notification.id] && notificationAge < 1000  // Only animate if less than 1 second old
                        
                        if (shouldAnimate) {
                            x = 420
                            opacity = 0
                            hasSlideIn = false
                            slideInAnimation.start()
                            // Mark as animated
                            animatedNotificationIds[notification.id] = true
                        } else {
                            x = 0
                            opacity = 1
                            hasSlideIn = true
                            // Mark as animated if not already
                            animatedNotificationIds[notification.id] = true
                        }
                    }
                }

                // Slide-in animation
                ParallelAnimation {
                    id: slideInAnimation
                    NumberAnimation {
                        target: notificationRect
                        property: "x"
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: notificationRect
                        property: "opacity"
                        to: 1
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    onFinished: {
                        hasSlideIn = true
                    }
                }

                // Slide-out animation
                ParallelAnimation {
                    id: slideOutAnimation
                    NumberAnimation {
                        target: notificationRect
                        property: "x"
                        to: 420
                        duration: 250
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: notificationRect
                        property: "opacity"
                        to: 0
                        duration: 250
                        easing.type: Easing.InCubic
                    }
                    onFinished: {
                        if (notification) {
                            removeNotification(notification.id)
                        }
                    }
                }

                // Click to dismiss
                MouseArea {
                    anchors.fill: parent
                    onClicked: slideOutAnimation.start()
                }

                // Content
                Row {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    // App icon
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Qt.rgba(255, 255, 255, 0.1)
                        anchors.verticalCenter: parent.verticalCenter

                        // Application icon (if available)
                        Image {
                            id: appIcon
                            source: {
                                if (!notification || !notification.icon) return ""
                                
                                let icon = notification.icon
                                
                                // Apply same processing as tray system
                                if (icon.includes("?path=")) {
                                    const [name, path] = icon.split("?path=");
                                    const fileName = name.substring(name.lastIndexOf("/") + 1);
                                    return `file://${path}/${fileName}`;
                                }
                                
                                // Handle file paths properly
                                if (icon.startsWith('/')) {
                                    return "file://" + icon
                                }
                                
                                return icon
                            }
                            anchors.fill: parent
                            anchors.margins: 2
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: source.toString() !== ""
                            
                            onStatusChanged: {
                                // Icon status handling can be added here if needed
                            }
                        }

                        // Fallback text (first letter of app name)
                        Text {
                            anchors.centerIn: parent
                            text: notification && notification.appName ? notification.appName.charAt(0).toUpperCase() : "!"
                            color: Data.ThemeManager.accentColor
                            font.family: "Roboto"
                            font.pixelSize: 16
                            font.bold: true
                            visible: !appIcon.visible
                        }
                    }

                    // Content
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 60
                        spacing: 4

                        Text {
                            text: notification ? notification.appName : ""
                            color: Data.ThemeManager.accentColor
                            font.family: "Roboto"
                            font.bold: true
                            font.pixelSize: 15
                            width: Math.min(parent.width, 250)  // Earlier line break
                            elide: Text.ElideRight
                        }

                        Text {
                            text: notification ? notification.summary : ""
                            color: Data.ThemeManager.fgColor
                            font.family: "Roboto"
                            font.pixelSize: 14
                            width: Math.min(parent.width, 250)  // Earlier line break
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }

                        Text {
                            text: notification ? notification.body : ""
                            color: Qt.lighter(Data.ThemeManager.fgColor, 1.3)
                            font.family: "Roboto"
                            font.pixelSize: 13
                            width: Math.min(parent.width, 250)  // Earlier line break
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }
                }

                // Top corner for first notification
                Core.Corners {
                    position: "bottomright"
                    size: 1.3
                    fillColor: Data.ThemeManager.bgColor
                    offsetX: -361
                    offsetY: -13
                    visible: index === 0 && index < maxNotifications
                }

                // Bottom corner for last visible notification
                Core.Corners {
                    position: "bottomright"
                    size: 1.3
                    fillColor: Data.ThemeManager.bgColor
                    offsetX: 39
                    offsetY: 78
                    visible: index === Math.min(notifications.length, maxNotifications) - 1 && index < maxNotifications
                }
            }
        }
    }
}
