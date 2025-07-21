pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: settings

    // Prevent auto-saving during initial load
    property bool isLoading: true

    // Settings persistence with atomic writes
    FileView {
        id: settingsFile
        path: "settings.json"
        blockWrites: true
        atomicWrites: true
        watchChanges: false

        onLoaded: {
            settings.isLoading = true  // Disable auto-save during loading
            try {
                var content = JSON.parse(text())
                if (content) {
                    // Load with fallback defaults
                    settings.isDarkTheme = content.isDarkTheme ?? true
                    settings.currentTheme = content.currentTheme ?? (content.isDarkTheme !== false ? "oxocarbon_dark" : "oxocarbon_light")
                    settings.useCustomAccent = content.useCustomAccent ?? false
                    settings.avatarSource = content.avatarSource ?? "file:///home/wick3dr0se/.config/quickshell/qml/Assets/UserProfile.png"
                    settings.weatherLocation = content.weatherLocation ?? "Asheville"
                    settings.useFahrenheit = content.useFahrenheit ?? false
                    settings.displayTime = content.displayTime ?? 6000
                    settings.videoPath = content.videoPath ?? "~/Videos/"
                    settings.wallpaperDirectory = content.wallpaperDirectory ?? "/home/wick3dr0se/.walls"
                    settings.lastWallpaperPath = content.lastWallpaperPath ?? "/home/wick3dr0se/.walls/leaves.png"
                    settings.customDarkAccent = content.customDarkAccent ?? "#be95ff"
                    settings.customLightAccent = content.customLightAccent ?? "#8a3ffc"
                    settings.autoSwitchPlayer = content.autoSwitchPlayer ?? true
                    settings.alwaysShowPlayerDropdown = content.alwaysShowPlayerDropdown ?? true
                    settings.historyLimit = content.historyLimit ?? 25
                    settings.nightLightEnabled = content.nightLightEnabled ?? false
                    settings.nightLightWarmth = content.nightLightWarmth ?? 0.4
                    settings.nightLightAuto = content.nightLightAuto ?? false
                    settings.nightLightStartHour = content.nightLightStartHour ?? 20
                    settings.nightLightEndHour = content.nightLightEndHour ?? 6
                    settings.nightLightManualOverride = content.nightLightManualOverride ?? false
                    settings.nightLightManuallyEnabled = content.nightLightManuallyEnabled ?? false
                    settings.ignoredApps = content.ignoredApps ?? []
                    settings.workspaceBurstEnabled = content.workspaceBurstEnabled ?? true
                    settings.workspaceGlowEnabled = content.workspaceGlowEnabled ?? true
                }
            } catch (e) {
                console.log("Error parsing user settings:", e)
            }
            // Re-enable auto-save after loading is complete
            settings.isLoading = false
        }
    }

    // User-configurable settings
    property string avatarSource: "file:///home/wick3dr0se/.config/quickshell/qml/Assets/UserProfile.png"
    property bool isDarkTheme: true  // Keep for backwards compatibility
    property string currentTheme: "oxocarbon_dark"  // New theme system
    property bool useCustomAccent: false  // Whether to use custom accent colors
    property string weatherLocation: "Asheville"
    property bool useFahrenheit: true  // Temperature unit setting
    property int displayTime: 6000  // Notification display time in ms
    property var ignoredApps: []  // Apps to ignore notifications from (case-insensitive)
    property int historyLimit: 25  // Notification history limit
    property string videoPath: "~/Videos/"
    property string wallpaperDirectory: "/home/wick3dr0se/.walls"
    property string lastWallpaperPath: "/home/wick3dr0se/.walls/leaves.png"
    property string customDarkAccent: "#be95ff"
    property string customLightAccent: "#8a3ffc"
    
    // Music Player settings
    property bool autoSwitchPlayer: true
    property bool alwaysShowPlayerDropdown: true
    
    // Night Light settings
    property bool nightLightEnabled: false
    property real nightLightWarmth: 0.4
    property bool nightLightAuto: false
    property int nightLightStartHour: 20  // 8 PM
    property int nightLightEndHour: 6     // 6 AM
    property bool nightLightManualOverride: false  // Track manual user actions
    property bool nightLightManuallyEnabled: false  // Track if user manually enabled it

    // Animation settings
    property bool workspaceBurstEnabled: true
    property bool workspaceGlowEnabled: true

    // UI constants
    readonly property real borderWidth: 9
    readonly property real cornerRadius: 20

    signal settingsChanged()

    // Helper functions for managing ignored apps
    function addIgnoredApp(appName) {
        if (appName && appName.trim() !== "") {
            var trimmedName = appName.trim()
            // Case-insensitive check for existing apps
            var exists = false
            for (var i = 0; i < ignoredApps.length; i++) {
                if (ignoredApps[i].toLowerCase() === trimmedName.toLowerCase()) {
                    exists = true
                    break
                }
            }
            if (!exists) {
                var newApps = ignoredApps.slice() // Create a copy
                newApps.push(trimmedName)
                ignoredApps = newApps
                console.log("Added ignored app:", trimmedName, "Current list:", ignoredApps)
                // Force save immediately (only if not loading)
                if (!isLoading) {
                    saveSettings()
                }
                return true
            }
        }
        return false
    }
    
    function removeIgnoredApp(appName) {
        var index = ignoredApps.indexOf(appName)
        if (index > -1) {
            var newApps = ignoredApps.slice() // Create a copy
            newApps.splice(index, 1)
            ignoredApps = newApps
            console.log("Removed ignored app:", appName, "Current list:", ignoredApps)
            // Force save immediately (only if not loading)
            if (!isLoading) {
                saveSettings()
            }
            return true
        }
        return false
    }

    function saveSettings() {
        try {
            var content = {
                isDarkTheme: settings.isDarkTheme,
                currentTheme: settings.currentTheme,
                useCustomAccent: settings.useCustomAccent,
                avatarSource: settings.avatarSource,
                weatherLocation: settings.weatherLocation,
                useFahrenheit: settings.useFahrenheit,
                displayTime: settings.displayTime,
                videoPath: settings.videoPath,
                wallpaperDirectory: settings.wallpaperDirectory,
                lastWallpaperPath: settings.lastWallpaperPath,
                customDarkAccent: settings.customDarkAccent,
                customLightAccent: settings.customLightAccent,
                autoSwitchPlayer: settings.autoSwitchPlayer,
                alwaysShowPlayerDropdown: settings.alwaysShowPlayerDropdown,
                historyLimit: settings.historyLimit,
                nightLightEnabled: settings.nightLightEnabled,
                nightLightWarmth: settings.nightLightWarmth,
                nightLightAuto: settings.nightLightAuto,
                nightLightStartHour: settings.nightLightStartHour,
                nightLightEndHour: settings.nightLightEndHour,
                nightLightManualOverride: settings.nightLightManualOverride,
                nightLightManuallyEnabled: settings.nightLightManuallyEnabled,
                ignoredApps: settings.ignoredApps,
                workspaceBurstEnabled: settings.workspaceBurstEnabled,
                workspaceGlowEnabled: settings.workspaceGlowEnabled
            }
            var jsonContent = JSON.stringify(content, null, 4)
            settingsFile.setText(jsonContent)
        } catch (e) {
            console.log("Error saving user settings:", e)
        }
    }

    // Auto-save watchers (only save when not loading)
    onIsDarkThemeChanged: {
        if (!isLoading) {
        settingsChanged()
        saveSettings()
        }
    }
    onCurrentThemeChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onUseCustomAccentChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onAvatarSourceChanged: {
        if (!isLoading) {
        settingsChanged()
        saveSettings()
        }
    }
    onWeatherLocationChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onUseFahrenheitChanged: {
        if (!isLoading) {
        settingsChanged()
        saveSettings()
        }
    }
    onDisplayTimeChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onHistoryLimitChanged: {
        if (!isLoading) {
        settingsChanged()
        saveSettings()
        }
    }
    onVideoPathChanged: {
        if (!isLoading) {
        settingsChanged()
        saveSettings()
        }
    }
    onWallpaperDirectoryChanged: {
        if (!isLoading) {
        settingsChanged()
        saveSettings()
        }
    }
    onLastWallpaperPathChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onCustomDarkAccentChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onCustomLightAccentChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onAutoSwitchPlayerChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onAlwaysShowPlayerDropdownChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onNightLightEnabledChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onNightLightWarmthChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onNightLightAutoChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onNightLightStartHourChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onNightLightEndHourChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onNightLightManualOverrideChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onNightLightManuallyEnabledChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onIgnoredAppsChanged: {
        if (!isLoading) {
        settingsChanged()
        saveSettings()
        }
    }
    onWorkspaceBurstEnabledChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }
    onWorkspaceGlowEnabledChanged: {
        if (!isLoading) {
            settingsChanged()
            saveSettings()
        }
    }

    Component.onCompleted: {
        settingsFile.reload()
    }
}
