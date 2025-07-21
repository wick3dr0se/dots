import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Shapes
import "root:/Data/" as Data
import "root:/Core" as Core

Item {
    id: osd
    property var shell

    QtObject {
        id: modeEnum
        readonly property int volume: 0
        readonly property int brightness: 1
    }

    property int mode: -1
    property int lastVolume: -1
    property int lastBrightness: -1

    width: osdBackground.width
    height: osdBackground.height
    visible: false

    Timer {
        id: hideTimer
        interval: 2500
        onTriggered: hideOsd()
    }

    FileView {
        id: brightnessFile
        path: "/tmp/brightness_osd_level"
        watchChanges: true
        blockLoading: true

        onLoaded: updateBrightness()
        onFileChanged: {
            brightnessFile.reload()
            updateBrightness()
        }

        function updateBrightness() {
            const val = parseInt(brightnessFile.text())
            if (!isNaN(val) && val !== lastBrightness) {
                lastBrightness = val
                mode = modeEnum.brightness
                showOsd()
            }
        }
    }

    Connections {
        target: shell
        function onVolumeChanged() {
            if (shell.volume !== lastVolume && lastVolume !== -1) {
                lastVolume = shell.volume
                mode = modeEnum.volume
                showOsd()
            }
            lastVolume = shell.volume
        }
    }

    Component.onCompleted: {
        if (shell?.volume !== undefined)
            lastVolume = shell.volume
    }

    function showOsd() {
        if (!osd.visible) {
            osd.visible = true
            slideInAnimation.start()
        }
        hideTimer.restart()
    }

    function hideOsd() {
        slideOutAnimation.start()
    }

    NumberAnimation {
        id: slideInAnimation
        target: osdBackground
        property: "x"
        from: osd.width
        to: 0
        duration: 300
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: slideOutAnimation
        target: osdBackground
        property: "x"
        from: 0
        to: osd.width
        duration: 250
        easing.type: Easing.InCubic
        onFinished: {
            osd.visible = false
            osdBackground.x = 0
        }
    }

    Rectangle {
        id: osdBackground
        width: 45
        height: 250
        color: Data.ThemeManager.bgColor
        topLeftRadius: 20
        bottomLeftRadius: 20

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                id: osdIcon
                font.family: "Roboto"
                font.pixelSize: 16
                color: Data.ThemeManager.fgColor
                text: {
                    if (mode === modeEnum.volume) {
                        if (!shell || shell.volume === undefined) return "󰝟"
                        const vol = shell.volume
                        return vol === 0 ? "󰝟" : vol < 33 ? "󰕿" : vol < 66 ? "󰖀" : "󰕾"
                    } else if (mode === modeEnum.brightness) {
                        const b = lastBrightness
                        return b < 0 ? "󰃞" : b < 33 ? "󰃟" : b < 66 ? "󰃠" : "󰃝"
                    }
                    return ""
                }
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on text {
                    SequentialAnimation {
                        PropertyAnimation { target: osdIcon; property: "scale"; to: 1.2; duration: 100 }
                        PropertyAnimation { target: osdIcon; property: "scale"; to: 1.0; duration: 100 }
                    }
                }
            }

            Rectangle {
                width: 10
                height: parent.height - osdIcon.height - osdLabel.height - 36
                radius: 5
                color: Qt.darker(Data.ThemeManager.accentColor, 1.5)
                border.color: Qt.darker(Data.ThemeManager.accentColor, 2.0)
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: fillBar
                    width: parent.width - 2
                    radius: parent.radius - 1
                    x: 1
                    color: Data.ThemeManager.accentColor
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    height: {
                        const val = mode === modeEnum.volume ? shell?.volume : lastBrightness
                        const maxHeight = parent.height - 2
                        return maxHeight * Math.max(0, Math.min(1, val / 100))
                    }
                    Behavior on height {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
            }

            Text {
                id: osdLabel
                text: {
                    const val = mode === modeEnum.volume ? shell?.volume : lastBrightness
                    return val >= 0 ? val + "%" : "0%"
                }
                font.pixelSize: 10
                font.weight: Font.Bold
                color: Data.ThemeManager.fgColor
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on text {
                    PropertyAnimation { target: osdLabel; property: "opacity"; from: 0.7; to: 1.0; duration: 150 }
                }
            }
        }
    }

    Core.Corners {
        position: "bottomright"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: 39 + osdBackground.x
        offsetY: 78
    }

    Core.Corners {
        position: "topright"
        size: 1.3
        fillColor: Data.ThemeManager.bgColor
        offsetX: 39 + osdBackground.x
        offsetY: -26
    }
}