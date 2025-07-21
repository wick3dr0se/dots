import QtQuick
import QtQuick.Controls
import "root:/Data" as Data

// Calendar tab content
Item {
    id: calendarTab
    
    required property var shell
    property bool isActive: false
    
    Column {
        anchors.fill: parent
        spacing: 12

        Text {
            text: "Calendar"
            color: Data.ThemeManager.accentColor
            font.pixelSize: 18
            font.bold: true
            font.family: "Roboto"
        }

        Rectangle {
            width: parent.width
            height: parent.height - parent.children[0].height - parent.spacing
            color: Qt.lighter(Data.ThemeManager.bgColor, 1.2)
            radius: 20
            clip: true

            Loader {
                anchors.fill: parent
                anchors.margins: 16
                active: calendarTab.isActive
                sourceComponent: active ? calendarComponent : null
            }
        }
    }
    
    Component {
        id: calendarComponent
        Item {
            id: calendarRoot
            property var shell: calendarTab.shell

            readonly property date currentDate: new Date()
            property int month: currentDate.getMonth()
            property int year: currentDate.getFullYear()
            readonly property int currentDay: currentDate.getDate()

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // Month/Year header
                Text {
                    text: Qt.locale("en_US").monthName(calendarRoot.month) + " " + calendarRoot.year
                    color: Data.ThemeManager.accentColor
                    font.bold: true
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    height: 24
                }

                // Weekday headers (Monday-Sunday)
                Grid {
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 0
                    width: parent.width
                    height: 18

                    Repeater {
                        model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                        delegate: Text {
                            text: modelData
                            color: Data.ThemeManager.fgColor
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            width: parent.width / 7
                            height: 18
                            font.pixelSize: 11
                        }
                    }
                }

                // Calendar grid - single unified grid
                Grid {
                    columns: 7
                    rowSpacing: 3
                    columnSpacing: 3
                    width: parent.width

                    property int firstDayOfMonth: new Date(calendarRoot.year, calendarRoot.month, 1).getDay()
                    property int daysInMonth: new Date(calendarRoot.year, calendarRoot.month + 1, 0).getDate()
                    property int startOffset: (firstDayOfMonth === 0) ? 6 : firstDayOfMonth - 1 // Convert Sunday=0 to Monday=0
                    property int prevMonthDays: new Date(calendarRoot.year, calendarRoot.month, 0).getDate()

                    // Single repeater for all 42 calendar cells (6 weeks × 7 days)
                    Repeater {
                        model: 42
                        delegate: Rectangle {
                            width: (parent.width - (parent.columnSpacing * 6)) / 7
                            height: 26
                            radius: 13

                            // Calculate which day this cell represents
                            readonly property int dayNumber: {
                                if (index < parent.startOffset) {
                                    // Previous month
                                    return parent.prevMonthDays - parent.startOffset + index + 1
                                } else if (index < parent.startOffset + parent.daysInMonth) {
                                    // Current month
                                    return index - parent.startOffset + 1
                                } else {
                                    // Next month
                                    return index - parent.startOffset - parent.daysInMonth + 1
                                }
                            }

                            readonly property bool isCurrentMonth: index >= parent.startOffset && index < (parent.startOffset + parent.daysInMonth)
                            readonly property bool isToday: isCurrentMonth && dayNumber === calendarRoot.currentDay &&
                                                           calendarRoot.month === calendarRoot.currentDate.getMonth() &&
                                                           calendarRoot.year === calendarRoot.currentDate.getFullYear()

                            color: isToday ? Data.ThemeManager.accentColor : 
                                   isCurrentMonth ? Data.ThemeManager.bgColor : Qt.darker(Data.ThemeManager.bgColor, 1.4)

                            Text {
                                text: dayNumber
                                anchors.centerIn: parent
                                color: isToday ? Data.ThemeManager.bgColor :
                                       isCurrentMonth ? Data.ThemeManager.fgColor : Qt.darker(Data.ThemeManager.fgColor, 1.5)
                                font.bold: isToday
                                font.pixelSize: 12
                                font.family: "Roboto"
                            }
                        }
                    }
                }
            }
        }
    }
} 