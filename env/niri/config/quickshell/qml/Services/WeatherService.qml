import QtQuick
import "root:/Data" as Data

// Weather service using Open-Meteo API
Item {
    id: service
    
    property var shell
    
    property string city: Data.Settings.weatherLocation
    property bool isAmerican: Data.Settings.useFahrenheit
    property int updateInterval: 3600  // 1 hour to reduce API calls
    property string weatherDescription: ""
    property var weather: null

    property Timer retryTimer: Timer {
        interval: 30000
        repeat: false
        running: false
        onTriggered: getGeocoding()
    }

    Timer {
        interval: service.updateInterval * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: getGeocoding()
    }

    // Watch for settings changes and refresh weather data
    Connections {
        target: Data.Settings
        function onWeatherLocationChanged() {
            console.log("Weather location changed to:", Data.Settings.weatherLocation)
            retryTimer.stop()
            getGeocoding()
        }
        
        function onUseFahrenheitChanged() {
            console.log("Temperature unit changed to:", Data.Settings.useFahrenheit ? "Fahrenheit" : "Celsius")
            retryTimer.stop()
            getGeocoding()
        }
    }

    // WMO weather code descriptions (Open-Meteo standard)
    property var weatherConsts: {
        "omapiCodeDesc": {
            0: "Clear sky",
            1: "Mainly clear", 
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog", 
            48: "Depositing rime fog",
            51: "Light drizzle",
            53: "Moderate drizzle",
            55: "Dense drizzle",
            56: "Light freezing drizzle",
            57: "Dense freezing drizzle",
            61: "Slight rain",
            63: "Moderate rain",
            65: "Heavy rain",
            66: "Light freezing rain",
            67: "Heavy freezing rain",
            71: "Slight snow fall",
            73: "Moderate snow fall",
            75: "Heavy snow fall",
            77: "Snow grains",
            80: "Slight rain showers",
            81: "Moderate rain showers",
            82: "Violent rain showers",
            85: "Slight snow showers",
            86: "Heavy snow showers",
            95: "Thunderstorm",
            96: "Thunderstorm with slight hail",
            99: "Thunderstorm with heavy hail"
        }
    }

    function getTemp(temp, tempUnit) {
        return temp + tempUnit;
    }

    function updateWeather() {
        if (!weather || !weather.current || !weather.current_units) {
            console.warn("Weather data incomplete, skipping update");
            return;
        }
        
        const weatherCode = weather.current.weather_code;
        const temp = getTemp(Math.round(weather.current.temperature_2m || 0), weather.current_units.temperature_2m || "°C");
        
        // Build 3-day forecast
        const forecast = [];
        const today = new Date();
        
        if (weather.daily && weather.daily.time && weather.daily.weather_code && weather.daily.temperature_2m_min && weather.daily.temperature_2m_max) {
            for (let i = 0; i < Math.min(3, weather.daily.time.length); i++) {
                let dayName;
                if (i === 0) {
                    dayName = "Today";
                } else if (i === 1) {
                    dayName = "Tomorrow";  
                } else {
                    const futureDate = new Date(today);
                    futureDate.setDate(today.getDate() + i);
                    dayName = Qt.formatDate(futureDate, "ddd MMM d");
                }
                
                const dailyWeatherCode = weather.daily.weather_code[i];
                const condition = weatherConsts.omapiCodeDesc[dailyWeatherCode] || "Unknown";
                
                forecast.push({
                    dayName: dayName,
                    condition: condition,
                    minTemp: Math.round(weather.daily.temperature_2m_min[i]),
                    maxTemp: Math.round(weather.daily.temperature_2m_max[i])
                });
            }
        }
        
        // Update shell weather data in expected format
        shell.weatherData = {
            location: city,
            currentTemp: temp,
            currentCondition: weatherConsts.omapiCodeDesc[weatherCode] || "Unknown",
            details: [
                "Wind: " + Math.round(weather.current.wind_speed_10m || 0) + " km/h"
            ],
            forecast: forecast
        }
        
        weatherDescription = weatherConsts.omapiCodeDesc[weatherCode] || "Unknown";
        shell.weatherLoading = false;
    }

    // XHR pool to prevent memory leaks
    property var activeXHRs: []
    
    function cleanupXHR(xhr) {
        if (xhr) {
            xhr.abort();
            xhr.onreadystatechange = null;
            xhr.onerror = null;
            
            const index = activeXHRs.indexOf(xhr);
            if (index > -1) {
                activeXHRs.splice(index, 1);
            }
        }
    }

    function getGeocoding() {
        if (!city || city.trim() === "") {
            console.warn("Weather location is empty, skipping weather request");
            shell.weatherLoading = false;
            return;
        }
        
        shell.weatherLoading = true;
        const xhr = new XMLHttpRequest();
        activeXHRs.push(xhr);
        
        xhr.open("GET", `https://geocoding-api.open-meteo.com/v1/search?name=${city}&count=1&language=en&format=json`);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        const geocoding = JSON.parse(xhr.responseText);
                        if (geocoding.results && geocoding.results.length > 0) {
                            const lat = geocoding.results[0].latitude;
                            const lng = geocoding.results[0].longitude;
                            getWeather(lat, lng);
                        } else {
                            console.warn("No geocoding results found for location:", city);
                            retryTimer.running = true;
                            shell.weatherLoading = false;
                        }
                    } catch (e) {
                        console.error("Failed to parse geocoding response:", e);
                        retryTimer.running = true;
                        shell.weatherLoading = false;
                    }
                } else if (xhr.status === 0) {
                    // Silent handling of network issues
                    if (!retryTimer.running) {
                        console.warn("Weather service: Network unavailable, will retry automatically");
                    }
                    retryTimer.running = true;
                    shell.weatherLoading = false;
                } else {
                    console.error("Geocoding request failed with status:", xhr.status);
                    retryTimer.running = true;
                    shell.weatherLoading = false;
                }
                cleanupXHR(xhr);
            }
        };
        xhr.onerror = function () {
            console.error("Geocoding request failed with network error");
            retryTimer.running = true;
            shell.weatherLoading = false;
            cleanupXHR(xhr);
        };
        xhr.send();
    }

    function getWeather(lat, lng) {
        const xhr = new XMLHttpRequest();
        activeXHRs.push(xhr);
        
        xhr.open("GET", `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lng}&current=temperature_2m,is_day,weather_code,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,weather_code&forecast_days=3&temperature_unit=` + (isAmerican ? "fahrenheit" : "celsius"));
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        weather = JSON.parse(xhr.responseText);
                        updateWeather();
                    } catch (e) {
                        console.error("Failed to parse weather response:", e);
                        retryTimer.running = true;
                        shell.weatherLoading = false;
                    }
                } else if (xhr.status === 0) {
                    // Silent handling of network issues
                    if (!retryTimer.running) {
                        console.warn("Weather service: Network unavailable for weather data");
                    }
                    retryTimer.running = true;
                    shell.weatherLoading = false;
                } else {
                    console.error("Weather request failed with status:", xhr.status);
                    retryTimer.running = true;
                    shell.weatherLoading = false;
                }
                cleanupXHR(xhr);
            }
        };
        xhr.onerror = function () {
            console.error("Weather request failed with network error");
            retryTimer.running = true;
            shell.weatherLoading = false;
            cleanupXHR(xhr);
        };
        xhr.send();
    }

    function loadWeather() {
        getGeocoding();
    }

    Component.onCompleted: getGeocoding()
    
    Component.onDestruction: {
        // Cleanup all active XHR requests
        for (let i = 0; i < activeXHRs.length; i++) {
            if (activeXHRs[i]) {
                activeXHRs[i].abort();
                activeXHRs[i].onreadystatechange = null;
                activeXHRs[i].onerror = null;
            }
        }
        activeXHRs = [];
        weather = null;
        shell.weatherData = null;
        weatherDescription = "";
    }
}
