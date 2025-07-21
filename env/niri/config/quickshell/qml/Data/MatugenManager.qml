pragma Singleton
import QtQuick

QtObject {
    property var service: null
    
    // Expose current colors from the service
    readonly property color primary: service?.colors?.raw?.primary || "#7ed7b8"
    readonly property color on_primary: service?.colors?.raw?.on_primary || "#00382a"
    readonly property color primary_container: service?.colors?.raw?.primary_container || "#454b03"
    readonly property color on_primary_container: service?.colors?.raw?.on_primary_container || "#e2e993"
    readonly property color secondary: service?.colors?.raw?.secondary || "#c8c9a6"
    readonly property color surface_bright: service?.colors?.raw?.surface_bright || "#373b30"
    readonly property bool hasColors: service?.isLoaded || false
    
    // Expose all raw Material 3 colors for complete access
    readonly property var rawColors: service?.colors?.raw || ({})
    
    function setService(matugenService) {
        service = matugenService
        console.log("MatugenManager: Service registered")
    }
    
    function reloadColors() {
        if (service && service.reloadColors) {
            console.log("MatugenManager: Triggering color reload")
            service.reloadColors()
            return true
        } else {
            console.warn("MatugenManager: No service available for reload")
            return false
        }
    }
    
    function isAvailable() {
        return service !== null
    }
} 