pragma Singleton
import QtQuick

QtObject {
    readonly property var dark: ({
        name: "Catppuccin Mocha",
        type: "dark",
        base00: "#1e1e2e",    // Base
        base01: "#181825",    // Mantle
        base02: "#313244",    // Surface0
        base03: "#45475a",    // Surface1
        base04: "#585b70",    // Surface2
        base05: "#cdd6f4",    // Text
        base06: "#f5e0dc",    // Rosewater
        base07: "#b4befe",    // Lavender
        base08: "#f38ba8",    // Red
        base09: "#fab387",    // Peach
        base0A: "#f9e2af",    // Yellow
        base0B: "#a6e3a1",    // Green
        base0C: "#94e2d5",    // Teal
        base0D: "#89b4fa",    // Blue
        base0E: "#cba6f7",    // Mauve
        base0F: "#f2cdcd"     // Flamingo
    })

    readonly property var light: ({
        name: "Catppuccin Latte", 
        type: "light",
        base00: "#eff1f5",    // Base
        base01: "#e6e9ef",    // Mantle
        base02: "#ccd0da",    // Surface0
        base03: "#bcc0cc",    // Surface1
        base04: "#acb0be",    // Surface2
        base05: "#4c4f69",    // Text
        base06: "#dc8a78",    // Rosewater
        base07: "#7287fd",    // Lavender
        base08: "#d20f39",    // Red
        base09: "#fe640b",    // Peach
        base0A: "#df8e1d",    // Yellow
        base0B: "#40a02b",    // Green
        base0C: "#179299",    // Teal
        base0D: "#1e66f5",    // Blue
        base0E: "#8839ef",    // Mauve
        base0F: "#dd7878"     // Flamingo
    })
} 