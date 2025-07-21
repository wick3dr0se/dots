pragma Singleton
import QtQuick

QtObject {
    readonly property var dark: ({
        name: "Oxocarbon Dark",
        type: "dark",
        base00: "#161616",    // OLED-friendly background
        base01: "#262626",    // Surface 1
        base02: "#393939",    // Surface 2 
        base03: "#525252",    // Surface 3
        base04: "#6f6f6f",    // Text secondary
        base05: "#c6c6c6",    // Text primary
        base06: "#e0e0e0",    // Text on color
        base07: "#f4f4f4",    // Text inverse
        base08: "#ff7eb6",    // Red (pink)
        base09: "#ee5396",    // Magenta
        base0A: "#42be65",    // Green
        base0B: "#be95ff",    // Purple
        base0C: "#3ddbd9",    // Cyan
        base0D: "#78a9ff",    // Blue
        base0E: "#be95ff",    // Purple (accent)
        base0F: "#08bdba"     // Teal
    })

    readonly property var light: ({
        name: "Oxocarbon Light",
        type: "light",
        base00: "#f4f4f4",    // Light background
        base01: "#ffffff",    // Surface 1
        base02: "#e0e0e0",    // Surface 2
        base03: "#c6c6c6",    // Surface 3
        base04: "#525252",    // Text secondary
        base05: "#262626",    // Text primary
        base06: "#161616",    // Text on color
        base07: "#000000",    // Text inverse
        base08: "#da1e28",    // Red
        base09: "#d12771",    // Magenta
        base0A: "#198038",    // Green
        base0B: "#8a3ffc",    // Purple
        base0C: "#007d79",    // Cyan
        base0D: "#0f62fe",    // Blue
        base0E: "#8a3ffc",    // Purple (accent)
        base0F: "#005d5d"     // Teal
    })
} 