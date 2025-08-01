import QtQuick 2.15

Text {
    id: clock

    property string dateFormat: "ddd MMM dd yyyy"
    property bool hovered: false
    property string timeFormat: config.clock?.military_time === "true" ? "HH:mm:ss" : "hh:mm:ss AP"

    function updateClock() {
        var now = new Date();
        text = hovered ? Qt.formatDate(now, dateFormat) : Qt.formatTime(now, timeFormat);
    }

    color: config?.theme?.text || "white"
    font.pixelSize: config.panel?.font_size || 12

    Component.onCompleted: updateClock()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            clock.hovered = true;
            clock.updateClock();
        }
        onExited: {
            clock.hovered = false;
            clock.updateClock();
        }
    }
    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: updateClock()
    }
}
