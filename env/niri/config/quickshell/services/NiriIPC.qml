pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property int focusedWindowIndex: -1
    property string focusedWindowTitle: "null"
    property bool inOverview: false
    property var windows: []
    property var workspaces: []
    
    function parseWindows(data) {
        const list = data.map(win => ({
            id: win.id,
            title: win.title || "",
            appId: win.app_id || "",
            workspaceId: win.workspace_id,
            isFocused: win.is_focused
        }));
        list.sort((a, b) => a.id - b.id);
        return list;
    }
    
    function parseWorkspaces(data) {
        const list = data.map(ws => ({
            id: ws.id,
            idx: ws.idx,
            name: ws.name || "",
            output: ws.output || "",
            isFocused: ws.is_focused,
            isActive: ws.is_active,
            isUrgent: ws.is_urgent,
            activeWindowId: ws.active_window_id
        }));
        list.sort((a, b) => a.output.localeCompare(b.output) || a.id - b.id);
        return list;
    }
    
    function updateFocusedWindowTitle() {
        let win = windows[focusedWindowIndex];
        focusedWindowTitle = win ? (win.title || win.appId || "(untitled)") : "(no focus)";
    }
    
    function refreshWindows() {
        windowsProcess.running = true;
    }
    
    Component.onCompleted: {
        // start both processes to get initial state
        windowsProcess.running = true;
        workspaceProcess.running = true;
        eventStream.running = true;
        refreshTimer.start();
    }
    
    onFocusedWindowIndexChanged: updateFocusedWindowTitle()
    onWindowsChanged: updateFocusedWindowTitle()
    onWorkspacesChanged: workspaceProcess.running = true
    
    // periodic refresh timer as fallback for title changes
    Timer {
        id: refreshTimer
        interval: 2000
        repeat: true
        onTriggered: {
            if (root.focusedWindowIndex >= 0) {
                refreshWindows();
            }
        }
    }
    
    // get initial windows list
    Process {
        id: windowsProcess
        command: ["niri", "msg", "--json", "windows"]
        running: false
        stdout: SplitParser {
            onRead: function (line) {
                try {
                    root.windows = parseWindows(JSON.parse(line));
                    root.focusedWindowIndex = root.windows.findIndex(w => w.isFocused);
                } catch (e) {
                    console.error("Failed to parse windows:", e, line);
                }
            }
        }
    }
    
    Process {
        id: workspaceProcess
        command: ["niri", "msg", "--json", "workspaces"]
        running: false
        stdout: SplitParser {
            onRead: function (line) {
                try {
                    root.workspaces = parseWorkspaces(JSON.parse(line));
                } catch (e) {
                    console.error("Failed to parse workspaces:", e, line);
                }
            }
        }
    }
    
    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: false
        stdout: SplitParser {
            onRead: function (line) {
                try {
                    const event = JSON.parse(line.trim());
                    
                    if (event.WorkspacesChanged || event.WorkspaceActivated) {
                        workspaceProcess.running = true;
                    } else if (event.WindowsChanged) {
                        try {
                            root.windows = parseWindows(event.WindowsChanged.windows);
                            root.focusedWindowIndex = root.windows.findIndex(w => w.isFocused);
                        } catch (e) {
                            console.error("Error parsing windows:", e);
                        }
                    } else if (event.WindowFocusChanged) {
                        const id = event.WindowFocusChanged.id;
                        if (id) {
                            // find window in current list
                            const newIndex = root.windows.findIndex(w => w.id === id);
                            if (newIndex !== -1) {
                                // update focus state in windows array
                                root.windows = root.windows.map(w => {
                                    return {
                                        id: w.id,
                                        title: w.title,
                                        appId: w.appId,
                                        workspaceId: w.workspaceId,
                                        isFocused: w.id === id
                                    };
                                });
                                root.focusedWindowIndex = newIndex;
                            } else {
                                // window not in current list, refresh windows
                                refreshWindows();
                            }
                        } else {
                            // no window focused
                            root.windows = root.windows.map(w => {
                                return {
                                    id: w.id,
                                    title: w.title,
                                    appId: w.appId,
                                    workspaceId: w.workspaceId,
                                    isFocused: false
                                };
                            });
                            root.focusedWindowIndex = -1;
                        }
                    } else if (event.WindowOpenOrChanged) {
                        // window properties (including title) changed                        
                        // check if this is the focused window that changed
                        const changedWindow = event.WindowOpenOrChanged.window;
                        if (changedWindow && root.focusedWindowIndex >= 0) {
                            const focusedWindow = root.windows[root.focusedWindowIndex];
                            if (focusedWindow && focusedWindow.id === changedWindow.id) {
                                // the focused window's properties changed, update immediately
                                focusedWindow.title = changedWindow.title || "";
                                focusedWindow.appId = changedWindow.app_id || "";
                                root.focusedWindowTitle = focusedWindow.title || focusedWindow.appId || "(Unnamed window)";
                            }
                        }
                        
                        // refresh the full window list to keep everything in sync
                        refreshWindows();
                    } else if (event.OverviewOpenedOrClosed) {
                        root.inOverview = !!event.OverviewOpenedOrClosed.is_open;
                    }
                } catch (e) {
                    console.error("Event parse error:", e, line);
                }
            }
        }
    }
}
