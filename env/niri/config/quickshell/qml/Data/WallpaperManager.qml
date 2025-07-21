pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "." as Data

// Wallpaper manager with auto-scan
Item {
    id: manager

    property string wallpaperDirectory: Data.Settings.wallpaperDirectory
    property string currentWallpaper: Data.Settings.lastWallpaperPath
    property var wallpaperList: []

    // Watch for wallpaper directory changes and refresh
    Connections {
        target: Data.Settings
        function onWallpaperDirectoryChanged() {
            console.log("Wallpaper directory changed to:", Data.Settings.wallpaperDirectory)
            wallpaperDirectory = Data.Settings.wallpaperDirectory
            wallpaperList = []  // Clear current list
            loadWallpapers()    // Scan new directory
        }
    }

    // Auto-refresh (5 min)
    Timer {
        id: refreshTimer
        interval: 300000
        running: false
        repeat: true
        onTriggered: loadWallpapers()
    }

    // Scan directory for wallpapers
    Process {
        id: findProcessInternal
        property var callback
        property var tempList: []
        running: false
        command: ["find", manager.wallpaperDirectory, "-type", "f", "-name", "*.png", "-o", "-name", "*.jpg", "-o", "-name", "*.jpeg"]
        // Note: WebP excluded as Qt WebP support requires additional plugins not always available

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line.trim()) {
                    findProcessInternal.tempList.push(line.trim())
                }
            }
        }

        onExited: {
            console.log("Found wallpapers:", manager.wallpaperList)

            var newList = findProcessInternal.tempList.slice()
            manager.wallpaperList = newList
            findProcessInternal.tempList = []
            
            // Set first wallpaper if none selected
            if (!currentWallpaper && wallpaperList.length > 0) {
                setWallpaper(wallpaperList[0])
            }
            
            // Start refresh timer after first successful scan
            if (!refreshTimer.running) {
                refreshTimer.running = true
            }
            
            if (callback) callback()
        }
    }

    function loadWallpapers(cb) {
        console.log("Wallpapers loaded")
        findProcessInternal.callback = cb
        findProcessInternal.tempList = []
        findProcessInternal.running = true
    }

    function setWallpaper(path) {
        currentWallpaper = path
        Data.Settings.lastWallpaperPath = path
        
        // Detect current theme mode for matugen
        const currentTheme = Data.Settings.currentTheme || "oxocarbon_dark"
        const mode = currentTheme.includes("_light") ? "light" : "dark"
        
        // Generate matugen colors from the new wallpaper with appropriate mode
        generateMatugenColors(path, mode)
        
        // Trigger update across all wallpaper components
        currentWallpaperChanged()
    }
    
    // Process for running matugen
    Process {
        id: matugenProcess
        running: false
        
        onExited: {
            if (exitCode === 0) {
                console.log("✓ Matugen colors generated successfully")
                
                // Trigger MatugenService reload through the manager
                Qt.callLater(function() {
                    if (Data.MatugenManager.reloadColors()) {
                        console.log("🔄 MatugenService reload triggered successfully")
                    } else {
                        console.warn("⚠️  Could not trigger MatugenService reload")
                    }
                })
            } else {
                console.warn("✗ Matugen failed with exit code:", exitCode)
            }
            running = false
        }
        
        onStarted: {
            console.log("🎨 Generating matugen colors for wallpaper...")
        }
    }
    
    // Generate colors using matugen
    function generateMatugenColors(wallpaperPath, mode) {
        if (!wallpaperPath) return
        
        // Default to dark mode if not specified
        const themeMode = mode || "dark"
        const modeFlag = themeMode === "light" ? "-m light" : ""
        
        // Run matugen to generate colors for quickshell
        matugenProcess.command = [
            "sh", "-c",
            `matugen image "${wallpaperPath}" ${modeFlag} && echo "Matugen completed for ${themeMode} mode"`
        ]
        matugenProcess.running = true
    }

    // Regenerate colors for current wallpaper with different mode
    function regenerateColorsForMode(mode) {
        if (currentWallpaper) {
            console.log(`🎨 Regenerating matugen colors for ${mode} mode...`)
            generateMatugenColors(currentWallpaper, mode)
        } else {
            console.warn("No current wallpaper set, cannot regenerate colors")
        }
    }

    // Ensure wallpapers are loaded before executing callback
    function ensureWallpapersLoaded(callback) {
        if (wallpaperList.length === 0) {
            loadWallpapers(callback)
        } else if (callback) {
            callback()
        }
    }

    Component.onCompleted: {
        if (Data.Settings.lastWallpaperPath) {
            currentWallpaper = Data.Settings.lastWallpaperPath
        }
    }

    Component.onDestruction: {
        if (findProcessInternal.running) {
            findProcessInternal.running = false
        }
        if (refreshTimer.running) {
            refreshTimer.running = false
        }
    }
} 
