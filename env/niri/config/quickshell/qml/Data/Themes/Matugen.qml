pragma Singleton
import QtQuick

QtObject {
    // Reference to the MatugenService
    property var matugenService: null
    
    // Debug helper to check service status
    function debugServiceStatus() {
        console.log("🔍 Debug: matugenService =", matugenService)
        console.log("🔍 Debug: matugenService.isLoaded =", matugenService ? matugenService.isLoaded : "N/A")
        console.log("🔍 Debug: matugenService.colorVersion =", matugenService ? matugenService.colorVersion : "N/A")
        console.log("🔍 Debug: condition result =", (matugenService && matugenService.isLoaded && matugenService.colorVersion >= 0))
        if (matugenService && matugenService.colors) {
            console.log("🔍 Debug: service.colors.dark =", JSON.stringify(matugenService.colors.dark))
        }
    }
    
    // Map matugen colors to base16 scheme - using the service when available
    // The colorVersion dependency forces re-evaluation when colors update
    readonly property var dark: {
        debugServiceStatus()
        if (matugenService && matugenService.isLoaded && matugenService.colorVersion >= 0) {
            // Use service colors if available, or generate fallback if we have light colors
            return matugenService.colors.dark || {
                name: "Matugen Dark (Generated from Light)",
                type: "dark",
                // If we only have light colors, create dark fallback
                base00: "#141311",
                base01: "#1c1c19", 
                base02: "#20201d",
                base03: "#2a2a27",
                base04: "#c9c7ba",
                base05: "#e5e2de",
                base06: "#31302e",
                base07: "#e5e2de",
                base08: "#ffb4ab",
                base09: "#b5ccb9",
                base0A: "#e4e5c1",
                base0B: "#c8c7b7",
                base0C: "#c8c9a6",
                base0D: "#c8c9a6",
                base0E: "#47483b",
                base0F: "#000000"
            }
        } else {
            return {
                name: "Matugen Dark", 
                type: "dark",
                // Updated fallback colors to match current quickshell-colors.qml
                base00: "#141311",
                base01: "#1c1c19",
                base02: "#20201d",
                base03: "#2a2a27",
                base04: "#c9c7ba",
                base05: "#e5e2de",
                base06: "#31302e",
                base07: "#e5e2de",
                base08: "#ffb4ab",
                base09: "#b5ccb9",
                base0A: "#e4e5c1",
                base0B: "#c8c7b7",
                base0C: "#c8c9a6",
                base0D: "#c8c9a6",
                base0E: "#47483b",
                base0F: "#000000"
            }
        }
    }
    
    readonly property var light: {
        if (matugenService && matugenService.isLoaded && matugenService.colorVersion >= 0) {
            // Use service colors if available, or generate fallback if we have dark colors
            return matugenService.colors.light || {
                name: "Matugen Light (Generated from Dark)",
                type: "light",
                // If we only have dark colors, create light fallback
                base00: "#ffffff",
                base01: "#f5f5f5",
                base02: "#e8e8e8",
                base03: "#d0d0d0",
                base04: "#666666",
                base05: "#1a1a1a",
                base06: "#000000",
                base07: "#ffffff",
                base08: "#d32f2f",
                base09: "#7b1fa2",
                base0A: "#f57c00",
                base0B: "#388e3c",
                base0C: "#0097a7",
                base0D: "#1976d2",
                base0E: "#5e35b1",
                base0F: "#000000"
            }
        } else {
            return {
                name: "Matugen Light",
                type: "light", 
                // Updated fallback colors based on current colors
                base00: "#ffffff",
                base01: "#f5f5f5",
                base02: "#e8e8e8",
                base03: "#d0d0d0",
                base04: "#666666",
                base05: "#1a1a1a",
                base06: "#000000",
                base07: "#ffffff",
                base08: "#d32f2f",
                base09: "#7b1fa2",
                base0A: "#f57c00",
                base0B: "#388e3c",
                base0C: "#0097a7",
                base0D: "#1976d2",
                base0E: "#5e35b1",
                base0F: "#000000"
            }
        }
    }
    
    // Direct access to primary colors for accent updates
    readonly property color primary: (matugenService && matugenService.getColor && matugenService.colorVersion >= 0) ? 
        matugenService.getColor("primary") || "#c8c9a6" : "#c8c9a6"
    readonly property color on_primary: (matugenService && matugenService.getColor && matugenService.colorVersion >= 0) ? 
        matugenService.getColor("on_primary") || "#303219" : "#303219"
    
    // Function to set the service reference
    function setMatugenService(service) {
        matugenService = service
        console.log("🔌 MatugenService connected to theme:", service)
        
        // Connect to service signals for automatic updates
        if (service) {
            service.matugenColorsUpdated.connect(function() {
                console.log("🎨 Matugen colors updated in theme (version " + service.colorVersion + ")")
                debugServiceStatus()
            })
        }
    }
    
    Component.onCompleted: {
        console.log("Matugen theme loaded, waiting for MatugenService connection")
    }
} 