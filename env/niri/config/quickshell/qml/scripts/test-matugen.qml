import QtQuick
import Quickshell.Io

// Simple test script for matugen integration
// Run with: quickshell scripts/test-matugen.qml

Item {
    FileView {
        id: matugenFile
        path: "Data/colors.css"
        blockWrites: true
        
        onLoaded: {
            console.log("✓ Matugen colors.css found!")
            console.log("File size:", text().length, "bytes")
            
            const lines = text().split('\n')
            const colors = {}
            let colorCount = 0
            
            // Parse colors
            for (const line of lines) {
                const match = line.match(/@define-color\s+(\w+)\s+(#[0-9a-fA-F]{6});/)
                if (match) {
                    colors[match[1]] = match[2]
                    colorCount++
                }
            }
            
            console.log("✓ Found", colorCount, "color definitions")
            console.log("\nMaterial You colors detected:")
            
            // Check for key Material You colors
            const keyColors = [
                "background", "surface", "primary", "secondary", "tertiary",
                "on_background", "on_surface", "on_primary", "on_secondary", "on_tertiary",
                "surface_container", "surface_tint", "error", "outline"
            ]
            
            for (const colorName of keyColors) {
                if (colors[colorName]) {
                    console.log(`  ${colorName}: ${colors[colorName]}`)
                }
            }
            
            if (colorCount > 10) {
                console.log("\n✓ Matugen integration should work perfectly!")
                console.log("✓ Switch to 'Matugen' theme in your quickshell appearance settings")
            } else {
                console.log("\n⚠ Limited color palette detected")
                console.log("⚠ Make sure you've run matugen with a wallpaper or image")
            }
            
            Qt.exit(0)
        }
        
        onTextChanged: {
            console.log("Matugen colors updated!")
        }
    }
    
    Timer {
        interval: 2000
        running: true
        onTriggered: {
            if (!matugenFile.loaded) {
                console.log("✗ Matugen colors.css not found at Data/colors.css")
                console.log("✗ Please copy your matugen colors.css to Data/colors.css")
                console.log("    cp ~/.cache/matugen/colors.css Data/colors.css")
                console.log("✗ Or generate matugen colors directly to this location")
                Qt.exit(1)
            }
        }
    }
    
    Component.onCompleted: {
        console.log("Testing matugen integration...")
        console.log("Looking for Data/colors.css...")
    }
} 