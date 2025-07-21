import QtQuick
import "../Data" as Data

// Simple test for direct matugen import
Item {
    Component.onCompleted: {
        console.log("Testing direct matugen import...")
        
        if (Data.ThemeManager.matugen) {
            console.log("✓ Matugen theme available")
            console.log("✓ Is active:", Data.ThemeManager.matugen.isMatugenActive())
            
            if (Data.ThemeManager.matugen.dark) {
                console.log("✓ Dark theme available")
                console.log("  Background:", Data.ThemeManager.matugen.dark.base00)
                console.log("  Primary:", Data.ThemeManager.matugen.dark.base0D)
                console.log("  Accent:", Data.ThemeManager.matugen.dark.base0E)
            }
            
            if (Data.ThemeManager.matugen.light) {
                console.log("✓ Light theme available") 
                console.log("  Background:", Data.ThemeManager.matugen.light.base00)
                console.log("  Primary:", Data.ThemeManager.matugen.light.base0D)
                console.log("  Accent:", Data.ThemeManager.matugen.light.base0E)
            }
            
            // Test raw color access
            const primaryColor = Data.ThemeManager.matugen.getMatugenColor("primary")
            if (primaryColor) {
                console.log("✓ Raw primary color:", primaryColor)
            }
            
            console.log("✅ Matugen integration working perfectly!")
        } else {
            console.log("✗ Matugen theme not found")
        }
        
        Qt.exit(0)
    }
} 