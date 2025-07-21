import QtQuick
import Quickshell.Io
import "root:/Data" as Data

// Matugen color integration service
Item {
    id: service
    
    property var shell
    property var colors: ({})
    property bool isLoaded: false
    property int colorVersion: 0  // Increments every time colors update to force QML re-evaluation
    
    // Signals to notify when colors change
    signal matugenColorsUpdated()
    signal matugenColorsLoaded()
    
    // File watcher for the matugen quickshell-colors.qml
    FileView {
        id: matugenFile
        path: "/home/wick3dr0se/.config/quickshell/qml/Data/quickshell-colors.qml"
        blockWrites: true
        
        onLoaded: {
            parseColors(text())
        }
        
        onTextChanged: {
            parseColors(text())
        }
    }
    
    // Parse QML color definitions and map them to base16 colors
    function parseColors(qmlText) {
        if (!qmlText) {
            console.warn("MatugenService: No QML content to parse")
            return
        }
        
        const lines = qmlText.split('\n')
        const parsedColors = {}
        
        // Extract readonly property color definitions
        for (const line of lines) {
            const match = line.match(/readonly\s+property\s+color\s+(\w+):\s*"(#[0-9a-fA-F]{6})"/)
            if (match) {
                const colorName = match[1]
                const colorValue = match[2]
                parsedColors[colorName] = colorValue
            }
        }
        
        // Detect if this is a light or dark theme based on surface luminance
        const surfaceColor = parsedColors.surface || "#000000"
        const isLightTheme = getLuminance(surfaceColor) > 0.5
        
        console.log(`MatugenService: Detected ${isLightTheme ? 'light' : 'dark'} theme from surface color: ${surfaceColor}`)
        
        // Use Material Design 3 colors directly with better contrast
        const baseMapping = {
            base00: parsedColors.surface || (isLightTheme ? "#ffffff" : "#000000"),                              // Background
            base01: parsedColors.surface_container_low || (isLightTheme ? "#f8f9fa" : "#1a1a1a"),              // Panel bg
            base02: parsedColors.surface_container || (isLightTheme ? "#e9ecef" : "#2a2a2a"),                  // Selection
            base03: parsedColors.surface_container_high || (isLightTheme ? "#dee2e6" : "#3a3a3a"),             // Border/separator
            base04: parsedColors.on_surface_variant || (isLightTheme ? "#6c757d" : "#adb5bd"),                 // Secondary text (better contrast)
            base05: parsedColors.on_surface || (isLightTheme ? "#212529" : "#f8f9fa"),                         // Primary text (high contrast)
            base06: parsedColors.on_background || (isLightTheme ? "#000000" : "#ffffff"),                      // Bright text
            base07: isLightTheme ? parsedColors.surface_container_lowest || "#ffffff" : parsedColors.surface_bright || "#ffffff", // Brightest
            base08: isLightTheme ? parsedColors.on_error || "#dc3545" : parsedColors.error || "#ff6b6b",       // Error (theme appropriate)
            base09: parsedColors.tertiary || (isLightTheme ? "#6f42c1" : "#a855f7"),                           // Purple
            base0A: parsedColors.primary_fixed || (isLightTheme ? "#fd7e14" : "#fbbf24"),                      // Orange/Yellow
            base0B: parsedColors.secondary || (isLightTheme ? "#198754" : "#10b981"),                          // Green
            base0C: parsedColors.surface_tint || (isLightTheme ? "#0dcaf0" : "#06b6d4"),                       // Cyan
            base0D: parsedColors.primary_container || (isLightTheme ? "#0d6efd" : "#3b82f6"),                  // Blue
            base0E: parsedColors.primary || (isLightTheme ? "#6610f2" : parsedColors.secondary || "#8b5cf6"),  // Accent - use primary for light, secondary for dark
            base0F: parsedColors.scrim || "#000000"                                                            // Special/black
        }
        
        // Create the theme object
        const theme = Object.assign({
            name: isLightTheme ? "Matugen Light" : "Matugen Dark",
            type: isLightTheme ? "light" : "dark"
        }, baseMapping)
        
        // Store colors in the appropriate theme slot
        colors = {
            raw: parsedColors,
            [isLightTheme ? 'light' : 'dark']: theme,
            // Keep the other theme as null or use fallback
            [isLightTheme ? 'dark' : 'light']: null
        }
        
        isLoaded = true
        colorVersion++  // Increment version to force QML property updates
        
        console.log("MatugenService: Colors loaded successfully from QML (version " + colorVersion + ")")
        console.log("Available colors:", Object.keys(parsedColors).join(", "))
        
        // Emit signals to notify theme system
        matugenColorsUpdated()
        matugenColorsLoaded()
    }
    
    // Calculate luminance of a hex color
    function getLuminance(hexColor) {
        // Remove # if present
        const hex = hexColor.replace('#', '')
        
        // Convert to RGB
        const r = parseInt(hex.substr(0, 2), 16) / 255
        const g = parseInt(hex.substr(2, 2), 16) / 255
        const b = parseInt(hex.substr(4, 2), 16) / 255
        
        // Calculate relative luminance
        const rs = r <= 0.03928 ? r / 12.92 : Math.pow((r + 0.055) / 1.055, 2.4)
        const gs = g <= 0.03928 ? g / 12.92 : Math.pow((g + 0.055) / 1.055, 2.4)
        const bs = b <= 0.03928 ? b / 12.92 : Math.pow((b + 0.055) / 1.055, 2.4)
        
        return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs
    }
    
    // Reload colors from file
    function reloadColors() {
        matugenFile.reload()
    }
    
    // Get specific color by name
    function getColor(colorName) {
        return colors.raw ? colors.raw[colorName] : null
    }
    
    // Check if matugen colors are available
    function isAvailable() {
        return isLoaded && colors.raw && Object.keys(colors.raw).length > 0
    }
    
    Component.onCompleted: {
        console.log("MatugenService: Initialized, watching quickshell-colors.qml")
    }
} 
