import Quickshell.Io
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "root:/Data/" as Data

Rectangle {
    id: root
    required property var shell
    property url avatarSource: Data.Settings.avatarSource
    property string userName: ""        // will be set by process output
    property string userInfo: ""        // will hold uptime string

    property bool isActive: false
    property bool isHovered: false      // track hover state

    radius: 20
    width: 220
    height: 80

    color: {
        if (isActive) {
            return isHovered ?
                   Qt.lighter(Data.ThemeManager.accentColor, 1.1) :
                   Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
        } else {
            return isHovered ?
                   Qt.lighter(Data.ThemeManager.accentColor, 1.2) :
                   Qt.lighter(Data.ThemeManager.bgColor, 1.15)
        }
    }

    border.width: isActive ? 2 : 1
    border.color: isActive ? Data.ThemeManager.accentColor : Qt.lighter(Data.ThemeManager.bgColor, 1.3)

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: avatarCircle
            width: 52
            height: 52
            radius: 20
            clip: true
            border.color: Data.ThemeManager.accentColor
            border.width: 3
            color: "transparent"

            Image {
                id: avatarImage
                anchors.fill: parent
                anchors.margins: 2
                source: Data.Settings.avatarSource
                fillMode: Image.PreserveAspectCrop
                cache: false
                visible: false  // Hide the original image
                asynchronous: true
                sourceSize.width: 48  // Limit image resolution to save memory
                sourceSize.height: 48
            }

            OpacityMask {
                anchors.fill: avatarImage
                source: avatarImage
                maskSource: Rectangle {
                    width: avatarImage.width
                    height: avatarImage.height
                    radius: 18  // Proportionally smaller than parent (48/52 * 20 ≈ 18)
                    visible: false
                }
            }
        }

        Column {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - avatarCircle.width - gifContainer.width - parent.spacing * 2

            Text {
                width: parent.width
                text: root.userName === "" ? "Loading..." : root.userName
                font.family: "Roboto"
                font.pixelSize: 16
                font.bold: true
                color: isHovered || root.isActive ? Data.ThemeManager.bgColor : Data.ThemeManager.accentColor
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                width: parent.width
                text: root.userInfo === "" ? "Loading uptime..." : root.userInfo
                font.family: "Roboto"
                font.pixelSize: 11
                font.bold: true
                color: isHovered || root.isActive ? "#cccccc" : Qt.lighter(Data.ThemeManager.accentColor, 1.6)
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        Rectangle {
            id: gifContainer
            width: 80
            height: 80
            radius: 12
            color: "transparent"
            anchors.verticalCenter: parent.verticalCenter

            AnimatedImage {
                id: animatedImage
                source: "root:/Assets/smiling-wolf.gif"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                playing: true
                cache: false
                speed: 1.0
                asynchronous: true
            }

            // Always enable layer effects for rounded corners
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: gifContainer.width
                    height: gifContainer.height
                    radius: gifContainer.radius
                    visible: false
                }
            }
            

        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
    }

    Process {
        id: usernameProcess
        running: true  // Always run to get username
        command: ["sh", "-c", "whoami"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                const line = data.trim();
                if (line.length > 0) {
                    root.userName = line.charAt(0).toUpperCase() + line.slice(1);
                }
            }
        }
    }

    Process {
        id: uptimeProcess
        running: false
        command: ["sh", "-c", "uptime"]  // Use basic uptime command

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                const line = data.trim();
                if (line.length > 0) {
                    // Parse traditional uptime output: " 10:30:00 up  1:23,  2 users,  load average: 0.08, 0.02, 0.01"
                    const match = line.match(/up\s+(.+?),\s+\d+\s+user/);
                    if (match && match[1]) {
                        root.userInfo = "Up: " + match[1].trim();
                    } else {
                        // Fallback parsing
                        const upIndex = line.indexOf("up ");
                        if (upIndex !== -1) {
                            const afterUp = line.substring(upIndex + 3);
                            const commaIndex = afterUp.indexOf(",");
                            if (commaIndex !== -1) {
                                root.userInfo = "Up: " + afterUp.substring(0, commaIndex).trim();
                            } else {
                                root.userInfo = "Up: " + afterUp.trim();
                            }
                        } else {
                            root.userInfo = "Uptime unknown";
                        }
                    }
                } else {
                    root.userInfo = "Uptime unknown";
                }
            }
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                console.log("Uptime error:", data);
                root.userInfo = "Uptime error";
            }
        }
    }

    Timer {
        id: uptimeTimer
        interval: 300000   // Update every 5 minutes
        running: true      // Always run the uptime timer
        repeat: true
        onTriggered: {
            uptimeProcess.running = false
            uptimeProcess.running = true
        }
    }

    Component.onCompleted: {
        uptimeProcess.running = true  // Start uptime process on component load
    }

    Component.onDestruction: {
        if (usernameProcess.running) {
            usernameProcess.running = false
        }
        if (uptimeProcess.running) {
            uptimeProcess.running = false
        }
        if (uptimeTimer.running) {
            uptimeTimer.running = false
        }
    }
}
