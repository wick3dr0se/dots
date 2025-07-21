pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Themes" as Themes
import "_foot-theme.js" as FootTheme

Singleton {
    id: themeManager

    // Import all theme definitions
    property var oxocarbon: Themes.Oxocarbon
    property var dracula: Themes.Dracula
    property var gruvbox: Themes.Gruvbox
    property var catppuccin: Themes.Catppuccin
    property var matugen: Themes.Matugen

    // Available theme definitions
    readonly property var themes: ({
        "oxocarbon_dark": oxocarbon.dark,
        "oxocarbon_light": oxocarbon.light,
        "dracula_dark": dracula.dark,
        "dracula_light": dracula.light,
        "gruvbox_dark": gruvbox.dark,
        "gruvbox_light": gruvbox.light,
        "catppuccin_dark": catppuccin.dark,
        "catppuccin_light": catppuccin.light,
        "matugen_dark": matugen.dark,
        "matugen_light": matugen.light
    })

    // Current theme selection - defaults to oxocarbon_dark if not set
    readonly property string currentThemeId: Settings.currentTheme || "oxocarbon_dark"
    readonly property var currentTheme: themes[currentThemeId] || themes["oxocarbon_dark"]
    
    // Auto-update accents when Matugen colors change
    Connections {
        target: MatugenManager
        function onPrimaryChanged() {
            if (currentThemeId.startsWith("matugen_")) {
                updateMatugenAccents()
            }
        }
    }
    
    // Connect to MatugenService signals for automatic accent updates
    Connections {
        target: MatugenManager.service
        function onMatugenColorsUpdated() {
            if (currentThemeId.startsWith("matugen_")) {
                console.log("ThemeManager: Received matugen colors update signal")
                updateMatugenAccents()
            }
        }
    }
    
    // Initialize currentTheme in settings if not present
    Component.onCompleted: {
        if (!Settings.currentTheme) {
            console.log("Initializing currentTheme in settings")
            Settings.currentTheme = "oxocarbon_dark"
            Settings.saveSettings()
        }

        FootTheme.apply(currentTheme)
        
        // Matugen theme is now self-contained with service-based colors
        console.log("Matugen theme initialized with service-based colors")
        
        // Update accents if already using matugen theme
        if (currentThemeId.startsWith("matugen_")) {
            updateMatugenAccents()
        }
    }

    // Custom accent colors (can be changed by user)
    property string customDarkAccent: Settings.customDarkAccent || "#be95ff"
    property string customLightAccent: Settings.customLightAccent || "#8a3ffc"

    // Dynamic color properties based on current theme
    readonly property color base00: currentTheme.base00
    readonly property color base01: currentTheme.base01
    readonly property color base02: currentTheme.base02
    readonly property color base03: currentTheme.base03
    readonly property color base04: currentTheme.base04
    readonly property color base05: currentTheme.base05
    readonly property color base06: currentTheme.base06
    readonly property color base07: currentTheme.base07
    readonly property color base08: currentTheme.base08
    readonly property color base09: currentTheme.base09
    readonly property color base0A: currentTheme.base0A
    readonly property color base0B: currentTheme.base0B
    readonly property color base0C: currentTheme.base0C
    readonly property color base0D: currentTheme.base0D
    readonly property color base0E: Settings.useCustomAccent ? 
        (currentTheme.type === "dark" ? customDarkAccent : customLightAccent) : currentTheme.base0E
    readonly property color base0F: currentTheme.base0F

    // Common UI color mappings
    readonly property color bgColor: base00
    readonly property color bgLight: base01
    readonly property color bgLighter: base02
    readonly property color fgColor: base04
    readonly property color fgColorBright: base05
    readonly property color accentColor: base0E
    readonly property color accentColorBright: base0D
    readonly property color highlightBg: Qt.rgba(base0E.r, base0E.g, base0E.b, 0.15)
    readonly property color errorColor: base08
    readonly property color greenColor: base0B
    readonly property color redColor: base08

    // Alternative semantic aliases for convenience
    readonly property color background: base00
    readonly property color panelBackground: base01
    readonly property color selection: base02
    readonly property color border: base03
    readonly property color secondaryText: base04
    readonly property color primaryText: base05
    readonly property color brightText: base06
    readonly property color brightestText: base07
    readonly property color error: base08
    readonly property color warning: base09
    readonly property color highlight: base0A
    readonly property color success: base0B
    readonly property color info: base0C
    readonly property color primary: base0D
    readonly property color accent: base0E
    readonly property color special: base0F

    // UI styling constants
    readonly property real borderWidth: 9
    readonly property real cornerRadius: 20

    // Color utility functions
    function withOpacity(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity)
    }

    function withHighlight(color) {
        return Qt.rgba(color.r, color.g, color.b, 0.15)
    }

    // Theme management functions
    function setTheme(themeId) {
        if (themes[themeId]) {
            const previousThemeId = Settings.currentTheme
            Settings.currentTheme = themeId
            
            // Check if switching between matugen light/dark modes
            if (themeId.startsWith("matugen_") && previousThemeId && previousThemeId.startsWith("matugen_")) {
                const newMode = themeId.includes("_light") ? "light" : "dark"
                const oldMode = previousThemeId.includes("_light") ? "light" : "dark"
                
                if (newMode !== oldMode) {
                    console.log(`🎨 Switching matugen from ${oldMode} to ${newMode} mode`)
                    WallpaperManager.regenerateColorsForMode(newMode)
                }
            }
            
            // Auto-update accents for Matugen themes
            if (themeId.startsWith("matugen_")) {
                updateMatugenAccents()
            }
            
            Settings.saveSettings()
            FootTheme.apply(currentTheme)
            return true
        }
        return false
    }
    
    // Auto-update accent colors when using Matugen theme
    function updateMatugenAccents() {
        if (MatugenManager.isAvailable() && MatugenManager.hasColors) {
            // Get colors from the raw matugen palette
            const rawColors = MatugenManager.rawColors
            
            // Use primary for both dark and light themes - it's generated appropriately by matugen
            const accent = rawColors.primary
            
            // Debug log the colors we're using
            console.log("Raw colors available:", Object.keys(rawColors))
            console.log("Selected accent for both themes:", accent)
            
            // Update custom accents - use the same accent for both
            setCustomAccent(accent, accent)
            
            // Enable custom accents for Matugen theme
            Settings.useCustomAccent = true
            Settings.saveSettings()
            
            console.log("Auto-updated Matugen accents from service:", accent)
        } else {
            console.log("MatugenManager service not available or no colors loaded yet")
        }
    }

    function getThemeList() {
        return Object.keys(themes).map(function(key) {
            return {
                id: key,
                name: themes[key].name,
                type: themes[key].type
            }
        })
    }

    function getDarkThemes() {
        return getThemeList().filter(function(theme) {
            return theme.type === "dark"
        })
    }

    function getLightThemes() {
        return getThemeList().filter(function(theme) {
            return theme.type === "light"
        })
    }

    function setCustomAccent(darkColor, lightColor) {
        customDarkAccent = darkColor
        customLightAccent = lightColor
        Settings.customDarkAccent = darkColor
        Settings.customLightAccent = lightColor
        Settings.saveSettings()
    }

    function toggleCustomAccent() {
        Settings.useCustomAccent = !Settings.useCustomAccent
        Settings.saveSettings()
    }

    // Legacy function for backwards compatibility
    function toggleTheme() {
        // Switch between dark and light variants of current theme family
        var currentFamily = currentThemeId.replace(/_dark|_light/, "")
        var newThemeId = currentTheme.type === "dark" ? 
            currentFamily + "_light" : currentFamily + "_dark"
        
        // If the opposite variant doesn't exist, switch to oxocarbon
        if (!themes[newThemeId]) {
            newThemeId = currentTheme.type === "dark" ? "oxocarbon_light" : "oxocarbon_dark"
        }
        
        setTheme(newThemeId)
    }
}
