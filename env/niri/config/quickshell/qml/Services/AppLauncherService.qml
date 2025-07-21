import QtQuick
import Quickshell
import Quickshell.Io

// App launcher service - discovers and manages applications
Item {
    id: appService
    
    property var applications: []
    property bool isLoading: false
    
    // Categories for apps
    property var categories: {
        "AudioVideo": "🎵",
        "Audio": "🎵", 
        "Video": "🎬",
        "Development": "💻",
        "Education": "📚",
        "Game": "🎮",
        "Graphics": "🎨",
        "Network": "🌐",
        "Office": "📄",
        "Science": "🔬",
        "Settings": "⚙️",
        "System": "🔧",
        "Utility": "🛠️",
        "Other": "📦"
    }
    
    property string userName: ""
    property string homeDirectory: ""
    property bool userInfoLoaded: false
    property var currentApp: ({})
    property var pendingSearchPaths: []
    
    Component.onCompleted: {
        // First get user info, then load applications
        loadUserInfo()
    }
    
    function loadUserInfo() {
        userNameProcess.running = true
    }
    
    Process {
        id: userNameProcess
        command: ["whoami"]
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line.trim()) {
                    userName = line.trim()
                }
            }
        }
        
        onExited: {
            // Now get home directory
            homeDirProcess.running = true
        }
    }
    
    Process {
        id: homeDirProcess
        command: ["sh", "-c", "echo $HOME"]
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line.trim()) {
                    homeDirectory = line.trim()
                }
            }
        }
        
        onExited: {
            // Now we have user info, start loading applications
            userInfoLoaded = true
            loadApplications()
        }
    }
    
    function loadApplications() {
        if (!userInfoLoaded) {
            console.log("User info not loaded yet, skipping application scan")
            return
        }
        
        isLoading = true
        applications = []
        
        console.log("DEBUG: Starting application scan with user:", userName, "home:", homeDirectory)
        
        // Comprehensive search paths for maximum Linux compatibility
        appService.pendingSearchPaths = [
            // User-specific locations (highest priority)
            homeDirectory + "/.local/share/applications/",
            
            // Standard FreeDesktop.org locations
            "/usr/share/applications/",
            "/usr/local/share/applications/",
            
            // Flatpak locations
            "/var/lib/flatpak/exports/share/applications/",
            homeDirectory + "/.local/share/flatpak/exports/share/applications/",
            
            // Snap locations
            "/var/lib/snapd/desktop/applications/",
            "/snap/bin/",
            
            // AppImage locations (common user directories)
            homeDirectory + "/Applications/",
            homeDirectory + "/AppImages/",
            
            // Distribution-specific paths
            "/opt/*/share/applications/", // For manually installed software
            "/usr/share/applications/kde4/", // KDE4 legacy
            
            // NixOS-specific (will be ignored on non-NixOS systems)
            "/run/current-system/sw/share/applications/",
            "/etc/profiles/per-user/" + userName + "/share/applications/"
        ]
        
        console.log("DEBUG: Starting with essential paths:", JSON.stringify(appService.pendingSearchPaths))
        
        // Add XDG and home-manager paths
        getXdgDataDirs.running = true
    }
    
    Process {
        id: getXdgDataDirs
        command: ["sh", "-c", "echo $XDG_DATA_DIRS"]
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line.trim()) {
                    var xdgDirs = line.trim().split(":")
                    for (var i = 0; i < xdgDirs.length; i++) {
                        if (xdgDirs[i].trim()) {
                            var xdgPath = xdgDirs[i].trim() + "/applications/"
                            if (appService.pendingSearchPaths.indexOf(xdgPath) === -1) {
                                appService.pendingSearchPaths.push(xdgPath)
                                console.log("DEBUG: Added XDG path:", xdgPath)
                            }
                        }
                    }
                }
            }
        }
        
        onExited: {
            // Now add home-manager path
            getHomeManagerPaths.running = true
        }
    }

    Process {
        id: getHomeManagerPaths
        command: ["sh", "-c", "find /nix/store -maxdepth 1 -name '*home-manager-path*' -type d 2>/dev/null | head -1"]
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line.trim()) {
                    var homeManagerPath = line.trim() + "/share/applications/"
                    appService.pendingSearchPaths.push(homeManagerPath)
                    console.log("DEBUG: Added home-manager path:", homeManagerPath)
                }
            }
        }
        
        onExited: {
            // CRITICAL: Always ensure these essential directories are included
            var essentialPaths = [
                "/run/current-system/sw/share/applications/",
                "/usr/share/applications/",
                "/usr/local/share/applications/"
            ]
            
            for (var i = 0; i < essentialPaths.length; i++) {
                var path = essentialPaths[i]
                if (appService.pendingSearchPaths.indexOf(path) === -1) {
                    appService.pendingSearchPaths.push(path)
                    console.log("DEBUG: Added missing essential path:", path)
                }
            }
            
            // Start bulk parsing with all paths including XDG and home-manager
            startBulkParsing(appService.pendingSearchPaths)
        }
    }
    
    function startBulkParsing(searchPaths) {
        // BULLETPROOF: Ensure critical system directories are always included
        var criticalPaths = [
            "/run/current-system/sw/share/applications/",
            "/usr/share/applications/",
            "/usr/local/share/applications/"
        ]
        
        for (var i = 0; i < criticalPaths.length; i++) {
            var path = criticalPaths[i]
            if (searchPaths.indexOf(path) === -1) {
                searchPaths.push(path)
                console.log("DEBUG: BULLETPROOF: Added missing critical path:", path)
            }
        }
        
        console.log("DEBUG: Final directories to scan:", searchPaths.join(", "))
        
        // Single command to parse all .desktop files at once
        // Only parse fields from the main [Desktop Entry] section, ignore [Desktop Action] sections
        var cmd = 'for dir in ' + searchPaths.map(p => "'" + p + "'").join(" ") + '; do ' +
                  'if [ -d "$dir" ]; then ' +
                    'find "$dir" -name "*.desktop" 2>/dev/null | while read file; do ' +
                      'echo "===FILE:$file"; ' +
                      'sed -n \'/^\\[Desktop Entry\\]/,/^\\[.*\\]/{/^\\[Desktop Entry\\]/d; /^\\[.*\\]/q; /^Name=/p; /^Exec=/p; /^Icon=/p; /^Comment=/p; /^Categories=/p; /^Hidden=/p; /^NoDisplay=/p}\' "$file" 2>/dev/null || true; ' +
                    'done; ' +
                  'fi; ' +
                'done'
        
        bulkParseProcess.command = ["sh", "-c", cmd]
        bulkParseProcess.running = true
    }
    
    Process {
        id: bulkParseProcess
        running: false
        
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (line.startsWith("===FILE:")) {
                    // Start of new file
                    if (appService.currentApp.name && appService.currentApp.exec && !appService.currentApp.hidden && !appService.currentApp.noDisplay) {
                        applications.push(appService.currentApp)
                    }
                    appService.currentApp = {
                        name: "",
                        exec: "",
                        icon: "",
                        comment: "",
                        categories: [],
                        hidden: false,
                        noDisplay: false,
                        filePath: line.substring(8) // Remove "===FILE:" prefix
                    }
                } else if (line.startsWith("Name=")) {
                    appService.currentApp.name = line.substring(5)
                } else if (line.startsWith("Exec=")) {
                    appService.currentApp.exec = line.substring(5)
                } else if (line.startsWith("Icon=")) {
                    appService.currentApp.icon = line.substring(5)
                } else if (line.startsWith("Comment=")) {
                    appService.currentApp.comment = line.substring(8)
                } else if (line.startsWith("Categories=")) {
                    appService.currentApp.categories = line.substring(11).split(";").filter(cat => cat.length > 0)
                } else if (line === "Hidden=true") {
                    appService.currentApp.hidden = true
                } else if (line === "NoDisplay=true") {
                    appService.currentApp.noDisplay = true
                }
            }
        }
        
        onStarted: {
            appService.currentApp = {}
        }
        
        onExited: {
            // Process the last app
            if (appService.currentApp.name && appService.currentApp.exec && !appService.currentApp.hidden && !appService.currentApp.noDisplay) {
                applications.push(appService.currentApp)
            }
            
            console.log("DEBUG: Before deduplication: Found", applications.length, "applications")
            
            // Deduplicate applications - prefer user installations over system ones
            var uniqueApps = {}
            var finalApps = []
            
            for (var i = 0; i < applications.length; i++) {
                var app = applications[i]
                var key = app.name + "|" + app.exec.split(" ")[0] // Use name + base command as key
                
                if (!uniqueApps[key]) {
                    // First occurrence of this app
                    uniqueApps[key] = app
                    finalApps.push(app)
                } else {
                    // Duplicate found - check if this version should replace the existing one
                    var existing = uniqueApps[key]
                    var shouldReplace = false
                    
                    // Priority order (higher priority replaces lower):
                    // 1. User local applications (highest priority)
                    // 2. Home-manager applications 
                    // 3. User profile applications
                    // 4. System applications (lowest priority)
                    
                    if (app.filePath.includes("/.local/share/applications/")) {
                        shouldReplace = true // User local always wins
                    } else if (app.filePath.includes("home-manager-path") && 
                              !existing.filePath.includes("/.local/share/applications/")) {
                        shouldReplace = true // Home-manager beats system
                    } else if (app.filePath.includes("/home/") && 
                              !existing.filePath.includes("/.local/share/applications/") &&
                              !existing.filePath.includes("home-manager-path")) {
                        shouldReplace = true // User profile beats system
                    }
                    
                    if (shouldReplace) {
                        // Replace the existing app in finalApps array
                        for (var j = 0; j < finalApps.length; j++) {
                            if (finalApps[j] === existing) {
                                finalApps[j] = app
                                uniqueApps[key] = app
                                break
                            }
                        }
                    }
                    // If not replacing, just ignore the duplicate
                }
            }
            
            applications = finalApps
            console.log("DEBUG: After deduplication: Found", applications.length, "unique applications")
            
            isLoading = false
            applicationsChanged()
        }
    }
    

    
    function launchApplication(app) {
        if (!app || !app.exec) return
        
        // Clean up the exec command (remove field codes like %f, %F, %u, %U)
        var cleanExec = app.exec.replace(/%[fFuU]/g, "").trim()
        
        launchProcess.command = ["sh", "-c", cleanExec]
        launchProcess.running = true
        
        console.log("Launching:", app.name, "with command:", cleanExec)
    }
    
    Process {
        id: launchProcess
        running: false
        
        onExited: {
            if (exitCode !== 0) {
                console.log("Failed to launch application, exit code:", exitCode)
            }
        }
    }
    
    // Fuzzy search function
    function fuzzySearch(query, apps) {
        if (!query || query.length === 0) {
            return apps
        }
        
        query = query.toLowerCase()
        
        return apps.filter(app => {
            var searchText = (app.name + " " + app.comment).toLowerCase()
            
            // Simple fuzzy matching - check if all characters of query appear in order
            var queryIndex = 0
            for (var i = 0; i < searchText.length && queryIndex < query.length; i++) {
                if (searchText[i] === query[queryIndex]) {
                    queryIndex++
                }
            }
            
            return queryIndex === query.length
        }).sort((a, b) => {
            // Sort by relevance - exact matches first, then by name
            var aName = a.name.toLowerCase()
            var bName = b.name.toLowerCase()
            
            var aExact = aName.includes(query)
            var bExact = bName.includes(query)
            
            if (aExact && !bExact) return -1
            if (!aExact && bExact) return 1
            
            return aName.localeCompare(bName)
        })
    }
    
    function getCategoryIcon(app) {
        if (!app.categories || app.categories.length === 0) {
            return categories["Other"]
        }
        
        // Find the first matching category
        for (var i = 0; i < app.categories.length; i++) {
            var category = app.categories[i]
            if (categories[category]) {
                return categories[category]
            }
        }
        
        return categories["Other"]
    }
} 