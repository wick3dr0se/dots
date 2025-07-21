import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/Data" as Data

// Weather display widget
Rectangle {
    id: root
    required property var shell
    color: Qt.darker(Data.ThemeManager.bgColor, 1.15)
    radius: 20

    property bool containsMouse: weatherMouseArea.containsMouse || (forecastPopup.visible && forecastPopup.containsMouse)
    property bool menuJustOpened: false

    signal entered()
    signal exited()

    // Hover state management for parent components
    onContainsMouseChanged: {
        if (containsMouse) {
            entered()
        } else if (!menuJustOpened && !forecastPopup.visible) {
            exited()
        }
    }

    // Maps WMO weather condition codes and text descriptions to Material Design icons
    function getWeatherIcon(condition) {
        if (!condition) return "light_mode"

        const c = condition.toString()

        // WMO weather interpretation codes to Material Design icons
        const iconMap = {
            "0": "light_mode",     // Clear sky
            "1": "light_mode",     // Mainly clear
            "2": "cloud",          // Partly cloudy
            "3": "cloud",          // Overcast
            "45": "foggy",         // Fog
            "48": "foggy",         // Depositing rime fog
            "51": "water_drop",    // Light drizzle
            "53": "water_drop",    // Moderate drizzle
            "55": "water_drop",    // Dense drizzle
            "61": "water_drop",    // Slight rain
            "63": "water_drop",    // Moderate rain
            "65": "water_drop",    // Heavy rain
            "71": "ac_unit",       // Slight snow
            "73": "ac_unit",       // Moderate snow
            "75": "ac_unit",       // Heavy snow
            "80": "water_drop",    // Slight rain showers
            "81": "water_drop",    // Moderate rain showers
            "82": "water_drop",    // Violent rain showers
            "95": "thunderstorm",  // Thunderstorm
            "96": "thunderstorm",  // Thunderstorm with light hail
            "99": "thunderstorm"   // Thunderstorm with heavy hail
        }

        if (iconMap[c]) return iconMap[c]

        // Fallback text matching for non-WMO weather APIs
        const textMap = {
            "clear sky": "light_mode",
            "mainly clear": "light_mode",
            "partly cloudy": "cloud",
            "overcast": "cloud",
            "fog": "foggy",
            "drizzle": "water_drop",
            "rain": "water_drop",
            "snow": "ac_unit",
            "thunderstorm": "thunderstorm"
        }

        const lower = condition.toLowerCase()
        for (let key in textMap) {
            if (lower.includes(key)) return textMap[key]
        }

        return "help"  // Unknown condition fallback
    }

    // Hover trigger for forecast popup
    MouseArea {
        id: weatherMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            menuJustOpened = true
            forecastPopup.open()
            Qt.callLater(() => menuJustOpened = false)
        }
        onExited: {
            if (!forecastPopup.containsMouse && !menuJustOpened) {
                forecastPopup.close()
            }
        }
    }

    // Compact weather display (icon and temperature)
    RowLayout {
        id: weatherLayout
        anchors.centerIn: parent
        spacing: 8

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            // Weather condition icon
            Label {
                text: {
                    if (shell.weatherLoading) return "refresh"
                    if (!shell.weatherData) return "help"
                    return root.getWeatherIcon(shell.weatherData.currentCondition)
                }
                font.pixelSize: 28
                font.family: "Material Symbols Outlined"
                color: Data.ThemeManager.accentColor
                Layout.alignment: Qt.AlignHCenter
            }

            // Current temperature
            Label {
                text: {
                    if (shell.weatherLoading) return "Loading..."
                    if (!shell.weatherData) return "No weather data"
                    return shell.weatherData.currentTemp
                }
                color: Data.ThemeManager.fgColor
                font.family: "Roboto"
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

                // Forecast popup
    Popup {
        id: forecastPopup
        y: parent.height + 28
        x: Math.min(0, parent.width - width)
        width: 300
        height: 226
        padding: 12
        background: Rectangle {
            color: Qt.darker(Data.ThemeManager.bgColor, 1.15)
            radius: 20
            border.width: 1
            border.color: Qt.lighter(Data.ThemeManager.bgColor, 1.3)
        }

        property bool containsMouse: forecastMouseArea.containsMouse

        onVisibleChanged: {
            if (visible) {
                entered()
            } else if (!weatherMouseArea.containsMouse && !menuJustOpened) {
                exited()
            }
        }

        // Hover area for popup persistence
        MouseArea {
            id: forecastMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                if (!weatherMouseArea.containsMouse && !menuJustOpened) {
                    forecastPopup.close()
                }
            }
        }

        ColumnLayout {
            id: forecastColumn
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            // Current weather detailed view
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Large weather icon
                Label {
                    text: shell.weatherData ? root.getWeatherIcon(shell.weatherData.currentCondition) : ""
                    font.pixelSize: 48
                    font.family: "Material Symbols Outlined"
                    color: Data.ThemeManager.accentColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Weather condition description
                    Label {
                        text: shell.weatherData ? shell.weatherData.currentCondition : ""
                        color: Data.ThemeManager.fgColor
                        font.family: "Roboto"
                        font.pixelSize: 14
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    // Weather metrics: temperature, wind, direction
                    RowLayout {
                        spacing: 8
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                        // Temperature metric
                        RowLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter
                            Label {
                                text: "thermostat"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 12
                                color: Data.ThemeManager.accentColor
                            }
                            Label {
                                text: shell.weatherData ? shell.weatherData.currentTemp : ""
                                color: Data.ThemeManager.fgColor
                                font.family: "Roboto"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            width: 1
                            height: 12
                            color: Qt.lighter(Data.ThemeManager.bgColor, 1.3)
                        }

                        // Wind speed metric
                        RowLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter
                            Label {
                                text: "air"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 12
                                color: Data.ThemeManager.accentColor
                            }
                            Label {
                                text: {
                                    if (!shell.weatherData || !shell.weatherData.details) return ""
                                    const windInfo = shell.weatherData.details.find(d => d.startsWith("Wind:"))
                                    return windInfo ? windInfo.split(": ")[1] : ""
                                }
                                color: Data.ThemeManager.fgColor
                                font.family: "Roboto"
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            width: 1
                            height: 12
                            color: Qt.lighter(Data.ThemeManager.bgColor, 1.3)
                        }

                        // Wind direction metric
                        RowLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter
                            Label {
                                text: "explore"
                                font.family: "Material Symbols Outlined"
                                font.pixelSize: 12
                                color: Data.ThemeManager.accentColor
                            }
                            Label {
                                text: {
                                    if (!shell.weatherData || !shell.weatherData.details) return ""
                                    const dirInfo = shell.weatherData.details.find(d => d.startsWith("Direction:"))
                                    return dirInfo ? dirInfo.split(": ")[1] : ""
                                }
                                color: Data.ThemeManager.fgColor
                                font.family: "Roboto"
                                font.pixelSize: 12
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Section separator
            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: Qt.lighter(Data.ThemeManager.bgColor, 1.3)
            }

            Label {
                text: "3-Day Forecast"
                color: Data.ThemeManager.accentColor
                font.family: "Roboto"
                font.pixelSize: 12
                font.bold: true
            }

            // Three-column forecast cards
            Row {
                spacing: 8
                Layout.fillWidth: true

                Repeater {
                    model: shell.weatherData ? shell.weatherData.forecast : []
                    delegate: Column {
                        width: (parent.width - 16) / 3
                        spacing: 2

                        // Day name
                        Label {
                            text: modelData.dayName
                            color: Data.ThemeManager.fgColor
                            font.family: "Roboto"
                            font.pixelSize: 10
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Weather icon
                        Label {
                            text: root.getWeatherIcon(modelData.condition)
                            font.pixelSize: 16
                            font.family: "Material Symbols Outlined"
                            color: Data.ThemeManager.accentColor
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Temperature range
                        Label {
                            text: modelData.minTemp + "° - " + modelData.maxTemp + "°"
                            color: Data.ThemeManager.fgColor
                            font.family: "Roboto"
                            font.pixelSize: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
