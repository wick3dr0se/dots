import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: lockscreenManager
    
    property bool isLocked: false
    property var targetWindow
    
    function lockScreen() {
        console.log("Loader lockscreen lockScreen() called")
        isLocked = true
        lockscreenLoader.active = true
        console.log("Loader active set to:", lockscreenLoader.active)
        console.log("isLocked set to:", isLocked)
    }
    
    function unlockScreen() {
        console.log("Loader lockscreen unlockScreen() called")
        isLocked = false
        lockscreenLoader.active = false
    }
    
    Loader {
        id: lockscreenLoader
        active: false
        
        onActiveChanged: {
            console.log("Loader active changed to:", active)
        }
        
        sourceComponent: PopupWindow {
            id: lockWindow
            visible: true
            color: "#1e1e2e"
            width: Screen.width
            height: Screen.height
            
            property string currentPassword: ""
            property bool authFailed: false
            
            Component.onCompleted: {
                console.log("Lock window created and completed")
                console.log("Screen dimensions:", Screen.width, "x", Screen.height)
            }
            
            onVisibleChanged: {
                console.log("Lock window visibility changed to:", visible)
            }
            
            // Fix the anchor - use proper window reference or remove if targeting full screen
            anchor {
                window: lockscreenManager.targetWindow
                rect.x: 0
                rect.y: 0
            }
            
            Rectangle {
                anchors.fill: parent
                color: "#1e1e2e"
                
                Rectangle {
                    anchors.fill: parent
                    color: "#000000"
                    opacity: 0.8
                }
                
                Column {
                    anchors.centerIn: parent
                    spacing: 40
                    
                    Text {
                        text: "🔐 LOCKED"
                        color: "white"
                        font.pixelSize: 48
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Rectangle {
                        width: 400
                        height: 60
                        color: "#313244"
                        border.color: lockWindow.authFailed ? "#f38ba8" : "#89b4fa"
                        border.width: 3
                        radius: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 15
                            
                            Repeater {
                                model: Math.min(lockWindow.currentPassword.length, 15)
                                Rectangle {
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: "#89b4fa"
                                }
                            }
                        }
                        
                        Text {
                            text: "Enter Password"
                            color: "#6c7086"
                            font.pixelSize: 18
                            anchors.centerIn: parent
                            visible: lockWindow.currentPassword.length === 0
                        }
                    }
                    
                    Text {
                        text: lockWindow.authFailed ? "❌ Wrong Password!" : "Type 'test' and click Unlock"
                        color: lockWindow.authFailed ? "#f38ba8" : "#cdd6f4"
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 25
                        
                        Rectangle {
                            width: 100
                            height: 45
                            color: "#585b70"
                            radius: 8
                            
                            Text {
                                text: "Type 'test'"
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: 13
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Setting test password")
                                    lockWindow.currentPassword = "test"
                                }
                            }
                        }
                        
                        Rectangle {
                            width: 80
                            height: 45
                            color: "#89b4fa"
                            radius: 8
                            
                            Text {
                                text: "Unlock"
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: 14
                                font.weight: Font.Bold
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Unlock attempt with password:", lockWindow.currentPassword)
                                    if (lockWindow.currentPassword === "test") {
                                        console.log("Correct password, unlocking")
                                        lockscreenManager.unlockScreen()
                                    } else {
                                        console.log("Wrong password")
                                        lockWindow.authFailed = true
                                        lockWindow.currentPassword = ""
                                        failTimer.start()
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            width: 70
                            height: 45
                            color: "#f38ba8"
                            radius: 8
                            
                            Text {
                                text: "Clear"
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: 14
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Clearing password")
                                    lockWindow.currentPassword = ""
                                    lockWindow.authFailed = false
                                }
                            }
                        }
                    }
                }
            }
            
            Timer {
                id: failTimer
                interval: 2000
                onTriggered: {
                    lockWindow.authFailed = false
                }
            }
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: (mouse) => {
                    console.log("Lock window mouse captured")
                    mouse.accepted = true
                }
            }
        }
    }
}