pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int focusedWindowIndex: -1
    property string focusedWindowTitle: "(No active window)"
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
        focusedWindowTitle = win ? (win.title || "(Unnamed window)") : "(No active window)";
    }

    Component.onCompleted: eventStream.running = true
    onFocusedWindowIndexChanged: updateFocusedWindowTitle()
    onWindowsChanged: updateFocusedWindowTitle()
    onWorkspacesChanged: workspaceProcess.running = true

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
                        root.focusedWindowIndex = id ? root.windows.findIndex(w => w.id === id) : -1;
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
