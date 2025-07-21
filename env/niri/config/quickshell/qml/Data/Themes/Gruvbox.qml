pragma Singleton
import QtQuick

QtObject {
    readonly property var dark: ({
        name: "Gruvbox Dark",
        type: "dark",
        base00: "#282828",    // Dark background
        base01: "#3c3836",    // Dark1
        base02: "#504945",    // Dark2
        base03: "#665c54",    // Dark3
        base04: "#bdae93",    // Light4
        base05: "#d5c4a1",    // Light3
        base06: "#ebdbb2",    // Light2
        base07: "#fbf1c7",    // Light1
        base08: "#fb4934",    // Red
        base09: "#fe8019",    // Orange
        base0A: "#fabd2f",    // Yellow
        base0B: "#b8bb26",    // Green
        base0C: "#8ec07c",    // Cyan
        base0D: "#83a598",    // Blue
        base0E: "#d3869b",    // Purple
        base0F: "#d65d0e"     // Brown
    })

    readonly property var light: ({
        name: "Gruvbox Light",
        type: "light",
        base00: "#fbf1c7",    // Light background
        base01: "#ebdbb2",    // Light1
        base02: "#d5c4a1",    // Light2
        base03: "#bdae93",    // Light3
        base04: "#665c54",    // Dark3
        base05: "#504945",    // Dark2
        base06: "#3c3836",    // Dark1
        base07: "#282828",    // Dark background
        base08: "#cc241d",    // Red
        base09: "#d65d0e",    // Orange
        base0A: "#d79921",    // Yellow
        base0B: "#98971a",    // Green
        base0C: "#689d6a",    // Cyan
        base0D: "#458588",    // Blue
        base0E: "#b16286",    // Purple
        base0F: "#d65d0e"     // Brown
    })
} 