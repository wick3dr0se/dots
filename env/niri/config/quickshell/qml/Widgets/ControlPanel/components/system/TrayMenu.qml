import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "root:/Data" as Data

// System tray context menu
Rectangle {
    id: root
    width: parent.width
    height: visible ? calculatedHeight : 0
    visible: false
    enabled: visible
    clip: true
    color: Data.ThemeManager.bgColor
    border.color: Data.ThemeManager.accentColor
    border.width: 2
    radius: 20

    required property var menu
    required property var systemTrayY
    required property var systemTrayHeight

    property bool containsMouse: trayMenuMouseArea.containsMouse
    property bool menuJustOpened: false
    property point triggerPoint: Qt.point(0, 0)
    property Item originalParent
    property int totalCount: opener.children ? opener.children.values.length : 0

    signal hideRequested()

    MouseArea {
        id: trayMenuMouseArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: false
    }

    onVisibleChanged: {
        if (visible) {
            menuJustOpened = true
            Qt.callLater(function() {
                menuJustOpened = false
            })
        }
    }

    function toggle() { 
        visible = !visible
        if (visible) {
            menuJustOpened = true
            Qt.callLater(function() {
                menuJustOpened = false
            })
        }
    }

    function show(point, parentItem) { 
        visible = true
        menuJustOpened = true
        Qt.callLater(function() {
            menuJustOpened = false
        })
    }

    function hide() { 
        visible = false 
        menuJustOpened = false
        // Small delay before notifying hide to prevent control panel flicker
        Qt.callLater(function() {
            hideRequested()
        })
    }

    // Smart positioning to avoid screen edges
    y: {
        var preferredY = systemTrayY + systemTrayHeight + 10
        var availableSpace = parent.height - preferredY - 20
        if (calculatedHeight > availableSpace) {
            return systemTrayY - height - 10
        }
        return preferredY
    }

    Behavior on height {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    // Dynamic height calculation based on menu item count and types
    property int calculatedHeight: {
        if (totalCount === 0) return 40
        var separatorCount = 0
        var regularItemCount = 0

        if (opener.children && opener.children.values) {
            for (var i = 0; i < opener.children.values.length; i++) {
                if (opener.children.values[i].isSeparator) {
                    separatorCount++
                } else {
                    regularItemCount++
                }
            }
        }

        // Calculate total height: separators + grid rows + margins
        var separatorHeight = separatorCount * 12
        var regularItemRows = Math.ceil(regularItemCount / 2)
        var regularItemHeight = regularItemRows * 32
        return Math.max(80, 35 + separatorHeight + regularItemHeight + 40)
    }

    // Menu opener handles the native menu integration
    QsMenuOpener {
        id: opener
        menu: root.menu
    }

    // Grid layout for menu items (2 columns)
    GridView {
        id: gridView
        anchors.fill: parent
        anchors.margins: 20
        cellWidth: width / 2
        cellHeight: 32
        interactive: false
        flow: GridView.FlowLeftToRight
        layoutDirection: Qt.LeftToRight

        model: ScriptModel {
            values: opener.children ? [...opener.children.values] : []
        }

        delegate: Item {
            id: entry
            required property var modelData
            required property int index

            width: gridView.cellWidth - 4
            height: modelData.isSeparator ? 12 : 30

            // Separator line
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                visible: modelData.isSeparator
                color: "transparent"

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    height: 1
                    color: Qt.darker(Data.ThemeManager.accentColor, 1.5)
                    opacity: 0.6
                }
            }

            // Regular menu item
            Rectangle {
                id: itemBackground
                anchors.fill: parent
                anchors.margins: 2
                visible: !modelData.isSeparator
                color: "transparent"
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    Image {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        source: modelData?.icon ?? ""
                        visible: (modelData?.icon ?? "") !== ""
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        Layout.fillWidth: true
                        color: mouseArea.containsMouse ? Data.ThemeManager.accentColor : Data.ThemeManager.fgColor
                        text: modelData?.text ?? ""
                        font.pixelSize: 11
                        font.family: "Roboto"
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: (modelData?.enabled ?? true) && root.visible && !modelData.isSeparator

                    onEntered: itemBackground.color = Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.15)
                    onExited: itemBackground.color = "transparent"
                    onClicked: {
                        modelData.triggered()
                        root.hide()
                    }
                }
            }
        }
    }

    // Empty state indicator
    Item {
        anchors.centerIn: gridView
        visible: gridView.count === 0

        Label {
            anchors.centerIn: parent
            text: "No tray items available"
            color: Qt.darker(Data.ThemeManager.fgColor, 2)
            font.pixelSize: 14
            font.family: "Roboto"
        }
    }
} 