pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool niriAvailable: false
    property ListModel workspaces: ListModel {
    }

    function switchToWorkspace(workspaceId) {
        if (!niriAvailable) {} else {
            console.warn("Niri is not available for workspace switching");
            return;
        }

        try {
            Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", workspaceId.toString()]);
        } catch (e) {
            console.error("Error switching Niri workspace:", e);
        }
    }
    function updateNiriWorkspaces() {
        const niriWorkspaces = NiriIPC.workspaces || [];

        workspaces.clear();
        for (let i = 0; i < niriWorkspaces.length; i++) {
            const ws = niriWorkspaces[i];
            workspaces.append({
                id: ws.id,
                idx: ws.idx || (i + 1),
                name: ws.name || "",
                output: ws.output || "",
                isFocused: ws.isFocused === true || ws.is_focused === true,
                isActive: ws.isActive === true || ws.is_active === true,
                isUrgent: ws.isUrgent === true || ws.is_urgent === true
            });
        }
        workspacesChanged();
    }

    Component.onCompleted: {
        if (typeof NiriIPC !== "undefined") {
            console.log("Detected Niri IPC service");
            niriAvailable = true;
            updateNiriWorkspaces();
        } else {
            console.warn("Niri IPC service not available");
        }
    }

    Connections {
        function onWorkspacesChanged() {
            updateNiriWorkspaces();
        }

        target: NiriIPC
    }
}
