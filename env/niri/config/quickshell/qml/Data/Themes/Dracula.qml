pragma Singleton
import QtQuick

QtObject {
    readonly property var dark: ({
        name: "Dracula",
        type: "dark",
        base00: "#282a36",    // Background
        base01: "#44475a",    // Current line
        base02: "#565761",    // Selection
        base03: "#6272a4",    // Comment
        base04: "#6272a4",    // Dark foreground
        base05: "#f8f8f2",    // Foreground
        base06: "#f8f8f2",    // Light foreground
        base07: "#ffffff",    // Light background
        base08: "#ff5555",    // Red
        base09: "#ffb86c",    // Orange
        base0A: "#f1fa8c",    // Yellow
        base0B: "#50fa7b",    // Green
        base0C: "#8be9fd",    // Cyan
        base0D: "#bd93f9",    // Blue
        base0E: "#ff79c6",    // Magenta
        base0F: "#ffb86c"     // Orange
    })

    readonly property var light: ({
        name: "Dracula Light",
        type: "light",
        base00: "#f8f8f2",    // Light background
        base01: "#ffffff",    // Lighter background
        base02: "#e5e5e5",    // Selection
        base03: "#bfbfbf",    // Comment
        base04: "#6272a4",    // Dark foreground
        base05: "#282a36",    // Dark text
        base06: "#21222c",    // Darker text
        base07: "#191a21",    // Darkest
        base08: "#e74c3c",    // Red (adjusted for light)
        base09: "#f39c12",    // Orange
        base0A: "#f1c40f",    // Yellow
        base0B: "#27ae60",    // Green  
        base0C: "#17a2b8",    // Cyan
        base0D: "#6c7ce0",    // Blue
        base0E: "#e91e63",    // Magenta
        base0F: "#f39c12"     // Orange
    })
} 