import QtQuick
import "../Services" as Services
import "../Data" as Data

// Test matugen integration with full shell context
Item {
    Services.MatugenService {
        id: matugenService
        
        Component.onCompleted: {
            console.log("MatugenService test initialized")
            
            // Connect to the matugen theme
            if (Data.ThemeManager.matugen) {
                Data.ThemeManager.matugen.matugenService = matugenService
                console.log("Connected service to theme")
            }
        }
        
        onMatugenColorsLoaded: {
            console.log("✓ Colors loaded signal received")
            console.log("✓ Service reports available:", isAvailable())
            console.log("✓ Theme reports active:", Data.ThemeManager.matugen.isMatugenActive())
            
            if (Data.ThemeManager.matugen.dark) {
                console.log("✓ Dark theme background:", Data.ThemeManager.matugen.dark.base00)
                console.log("✓ Dark theme primary:", Data.ThemeManager.matugen.dark.base0D)
            }
            
            Qt.exit(0)
        }
    }
    
    Timer {
        interval: 3000
        running: true
        onTriggered: {
            console.log("✗ Timeout - colors didn't load")
            Qt.exit(1)
        }
    }
    
    Component.onCompleted: {
        console.log("Testing matugen integration in shell context...")
    }
} 