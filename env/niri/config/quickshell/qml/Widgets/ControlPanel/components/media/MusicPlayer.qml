import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import "root:/Data" as Data

// Music player with MPRIS integration
Rectangle {
    id: musicPlayer
    
    property var shell
    property var currentPlayer: null
    property real currentPosition: 0
    property int selectedPlayerIndex: 0
    
    color: "transparent"
    
    // Get all available players
    function getAvailablePlayers() {
        if (!Mpris.players || !Mpris.players.values) {
            return []
        }
        
        let allPlayers = Mpris.players.values
        let controllablePlayers = []
        
        for (let i = 0; i < allPlayers.length; i++) {
            let player = allPlayers[i]
            if (player && player.canControl) {
                controllablePlayers.push(player)
            }
        }
        
        return controllablePlayers
    }
    
    // Find the active player (either selected or first available)
    function findActivePlayer() {
        let availablePlayers = getAvailablePlayers()
        if (availablePlayers.length === 0) {
            return null
        }
        
        // Auto-switch to playing player if enabled
        if (Data.Settings.autoSwitchPlayer) {
            for (let i = 0; i < availablePlayers.length; i++) {
                if (availablePlayers[i].isPlaying) {
                    selectedPlayerIndex = i
                    return availablePlayers[i]
                }
            }
        }
        
        // Use selected player if valid, otherwise use first available
        if (selectedPlayerIndex < availablePlayers.length) {
            return availablePlayers[selectedPlayerIndex]
        } else {
            selectedPlayerIndex = 0
            return availablePlayers[0]
        }
    }
    
    // Update current player
    function updateCurrentPlayer() {
        let newPlayer = findActivePlayer()
        if (newPlayer !== currentPlayer) {
            currentPlayer = newPlayer
            currentPosition = currentPlayer ? currentPlayer.position : 0
        }
    }
    
    // Timer to update progress bar position
    Timer {
        id: positionTimer
        interval: 1000
        running: currentPlayer && currentPlayer.isPlaying
        repeat: true
        onTriggered: {
            if (currentPlayer) {
                currentPosition = currentPlayer.position
            }
        }
    }
    
    // Timer to check for auto-switching to playing players
    Timer {
        id: autoSwitchTimer
        interval: 2000  // Check every 2 seconds
        running: Data.Settings.autoSwitchPlayer
        repeat: true
        onTriggered: {
            if (Data.Settings.autoSwitchPlayer) {
                let availablePlayers = getAvailablePlayers()
                for (let i = 0; i < availablePlayers.length; i++) {
                    if (availablePlayers[i].isPlaying && selectedPlayerIndex !== i) {
                        selectedPlayerIndex = i
                        updateCurrentPlayer()
                        updatePlayerList()
                        break
                    }
                }
            }
        }
    }
    
        // Update player list for dropdown
    function updatePlayerList() {
        if (!playerComboBox) return
        
        let availablePlayers = getAvailablePlayers()
        let playerNames = availablePlayers.map(player => player.identity || "Unknown Player")
        
        playerComboBox.model = playerNames
        
        if (selectedPlayerIndex >= playerNames.length) {
            selectedPlayerIndex = 0
        }
        
        playerComboBox.currentIndex = selectedPlayerIndex
    }
    
    // Monitor for player changes
    Connections {
        target: Mpris.players
        function onValuesChanged() {
            updatePlayerList()
            updateCurrentPlayer()
        }
        function onRowsInserted() {
            updatePlayerList()
            updateCurrentPlayer()
        }
        function onRowsRemoved() {
            updatePlayerList()
            updateCurrentPlayer()
        }
        function onObjectInsertedPost() {
            updatePlayerList()
            updateCurrentPlayer()
        }
        function onObjectRemovedPost() {
            updatePlayerList()
            updateCurrentPlayer()
        }
    }
    
    // Monitor for settings changes
    Connections {
        target: Data.Settings
        function onAutoSwitchPlayerChanged() {
            console.log("Auto-switch player setting changed to:", Data.Settings.autoSwitchPlayer)
            updateCurrentPlayer()
        }
        function onAlwaysShowPlayerDropdownChanged() {
            console.log("Always show dropdown setting changed to:", Data.Settings.alwaysShowPlayerDropdown)
            // Dropdown visibility is automatically handled by the binding
        }
    }
    
    Component.onCompleted: {
        updatePlayerList()
        updateCurrentPlayer()
    }
    
    Column {
        anchors.fill: parent
        spacing: 10
        
        // No music player available state
        Item {
            width: parent.width
            height: parent.height
            visible: !currentPlayer
            
            Column {
                anchors.centerIn: parent
                spacing: 16
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "music_note"
                    font.family: "Material Symbols Outlined"
                    font.pixelSize: 48
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: getAvailablePlayers().length > 0 ? "No controllable player selected" : "No music player detected"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                    font.family: "Roboto"
                    font.pixelSize: 14
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: getAvailablePlayers().length > 0 ? "Select a player from the dropdown above" : "Start a music player to see controls"
                    color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.4)
                    font.family: "Roboto"
                    font.pixelSize: 12
                }
            }
        }
        
        // Music player controls
        Column {
            width: parent.width
            spacing: 12
            visible: currentPlayer
            
            // Player info and artwork
            Rectangle {
                width: parent.width
                height: 130
                radius: 20
                color: Qt.darker(Data.ThemeManager.bgColor, 1.1)
                border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2)
                border.width: 1
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16
                    
                    // Album artwork
                    Rectangle {
                        id: albumArtwork
                        width: 90
                        height: 90
                        radius: 20
                        color: Qt.darker(Data.ThemeManager.bgColor, 1.3)
                        border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                        border.width: 1
                        
                        Image {
                            id: albumArt
                            anchors.fill: parent
                            anchors.margins: 2
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            source: currentPlayer ? (currentPlayer.trackArtUrl || "") : ""
                            visible: source.toString() !== ""
                            
                            // Rounded corners using layer
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                cached: true  // Cache to reduce ShaderEffect issues
                                maskSource: Rectangle {
                                    width: albumArt.width
                                    height: albumArt.height
                                    radius: 20
                                    visible: false
                                }
                            }
                        }
                        
                        // Fallback music icon
                        Text {
                            anchors.centerIn: parent
                            text: "album"
                            font.family: "Material Symbols Outlined"
                            font.pixelSize: 32
                            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.4)
                            visible: !albumArt.visible
                        }
                    }
                    
                    // Track info
                    Column {
                        width: parent.width - albumArtwork.width - parent.spacing
                        height: parent.height
                        spacing: 4
                        
                        Text {
                            width: parent.width
                            text: currentPlayer ? (currentPlayer.trackTitle || "Unknown Track") : ""
                            color: Data.ThemeManager.fgColor
                            font.family: "Roboto"
                            font.pixelSize: 18
                            font.bold: true
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                        }
                        
                        Text {
                            width: parent.width
                            text: currentPlayer ? (currentPlayer.trackArtist || "Unknown Artist") : ""
                            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.8)
                            font.family: "Roboto"
                            font.pixelSize: 18
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            width: parent.width
                            text: currentPlayer ? (currentPlayer.trackAlbum || "Unknown Album") : ""
                            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                            font.family: "Roboto"
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }
                    }
                }
            }
            
            // Interactive progress bar with seek functionality
            Rectangle {
                id: progressBarBackground
                width: parent.width
                height: 8
                radius: 20
                color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.15)
                
                property real progressRatio: currentPlayer && currentPlayer.length > 0 ? 
                                           (currentPosition / currentPlayer.length) : 0
                
                Rectangle {
                    id: progressFill
                    width: progressBarBackground.progressRatio * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Data.ThemeManager.accentColor
                    
                    Behavior on width {
                        NumberAnimation { duration: 200 }
                    }
                }
                
                // Interactive progress handle (circle)
                Rectangle {
                    id: progressHandle
                    width: 16
                    height: 16
                    radius: 8
                    color: Data.ThemeManager.accentColor
                    border.color: Qt.lighter(Data.ThemeManager.accentColor, 1.3)
                    border.width: 1
                    
                    x: Math.max(0, Math.min(parent.width - width, progressFill.width - width/2))
                    anchors.verticalCenter: parent.verticalCenter
                    
                    visible: currentPlayer && currentPlayer.length > 0
                    scale: progressMouseArea.containsMouse || progressMouseArea.pressed ? 1.2 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }
                
                // Mouse area for seeking
                MouseArea {
                    id: progressMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: currentPlayer && currentPlayer.length > 0 && currentPlayer.canSeek
                    
                    onClicked: function(mouse) {
                        if (currentPlayer && currentPlayer.length > 0) {
                            let ratio = mouse.x / width
                            let seekPosition = ratio * currentPlayer.length
                            currentPlayer.position = seekPosition
                            currentPosition = seekPosition
                        }
                    }
                    
                    onPositionChanged: function(mouse) {
                        if (pressed && currentPlayer && currentPlayer.length > 0) {
                            let ratio = Math.max(0, Math.min(1, mouse.x / width))
                            let seekPosition = ratio * currentPlayer.length
                            currentPlayer.position = seekPosition
                            currentPosition = seekPosition
                        }
                    }
                }
            }
            
            // Player selection dropdown (conditional visibility)
            Rectangle {
                width: parent.width
                height: 38
                radius: 20
                color: Qt.darker(Data.ThemeManager.bgColor, 1.1)
                border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2)
                border.width: 1
                visible: {
                    let playerCount = getAvailablePlayers().length
                    let alwaysShow = Data.Settings.alwaysShowPlayerDropdown
                    let shouldShow = alwaysShow || playerCount > 1
                    return shouldShow
                }
                
                                Row {
                    anchors.fill: parent
                    anchors.margins: 6
                    anchors.leftMargin: 12
                    spacing: 8
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Player:"
                        color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.7)
                        font.family: "Roboto"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    
                    ComboBox {
                        id: playerComboBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - parent.children[0].width - parent.spacing
                        height: 26
                        model: []
                        
                        onActivated: function(index) {
                            selectedPlayerIndex = index
                            updateCurrentPlayer()
                        }
                        
                        background: Rectangle {
                            color: Qt.darker(Data.ThemeManager.bgColor, 1.3)
                            border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2)
                            border.width: 1
                            radius: 20
                        }
                        
                        contentItem: Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 22
                            anchors.verticalCenter: parent.verticalCenter
                            text: playerComboBox.currentText || "No players"
                            color: Data.ThemeManager.fgColor
                            font.family: "Roboto"
                            font.pixelSize: 12
                            font.bold: true
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        indicator: Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                            text: "expand_more"
                            font.family: "Material Symbols Outlined" 
                            font.pixelSize: 12
                            color: Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)
                        }
                        
                        popup: Popup {
                            y: playerComboBox.height + 2
                            width: playerComboBox.width
                            implicitHeight: contentItem.implicitHeight + 4
                            
                            background: Rectangle {
                                color: Qt.darker(Data.ThemeManager.bgColor, 1.2)
                                border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                                border.width: 1
                                radius: 20
                            }
                            
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: playerComboBox.popup.visible ? playerComboBox.delegateModel : null
                                currentIndex: playerComboBox.highlightedIndex
                                
                                ScrollIndicator.vertical: ScrollIndicator { }
                            }
                        }
                        
                        delegate: ItemDelegate {
                            width: playerComboBox.width
                            height: 28
                            
                            background: Rectangle {
                                color: parent.hovered ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.15) : "transparent"
                                radius: 20
                            }
                            
                            contentItem: Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData || ""
                                color: Data.ThemeManager.fgColor
                                font.family: "Roboto"
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
            
            // Media controls
            Row {
                width: parent.width
                height: 35
                spacing: 6
                
                // Previous button
                Rectangle {
                    width: (parent.width - parent.spacing * 4) * 0.2
                    height: parent.height
                    radius: height / 2
                    color: previousButton.containsMouse ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : Qt.darker(Data.ThemeManager.bgColor, 1.1)
                    border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                    border.width: 1
                    
                    MouseArea {
                        id: previousButton
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: currentPlayer && currentPlayer.canGoPrevious
                        onClicked: if (currentPlayer) currentPlayer.previous()
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "skip_previous"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 18
                        color: previousButton.enabled ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                    }
                }
                
                // Play/Pause button
                Rectangle {
                    width: (parent.width - parent.spacing * 4) * 0.3
                    height: parent.height
                    radius: height / 2
                    color: playButton.containsMouse ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : Qt.darker(Data.ThemeManager.bgColor, 1.1)
                    border.color: Data.ThemeManager.accentColor
                    border.width: 2
                    
                    MouseArea {
                        id: playButton
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: currentPlayer && (currentPlayer.canPlay || currentPlayer.canPause)
                        onClicked: {
                            if (currentPlayer) {
                                if (currentPlayer.isPlaying) {
                                    currentPlayer.pause()
                                } else {
                                    currentPlayer.play()
                                }
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: currentPlayer && currentPlayer.isPlaying ? "pause" : "play_arrow"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 20
                        color: playButton.enabled ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                    }
                }
                
                // Next button
                Rectangle {
                    width: (parent.width - parent.spacing * 4) * 0.2
                    height: parent.height
                    radius: height / 2
                    color: nextButton.containsMouse ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : Qt.darker(Data.ThemeManager.bgColor, 1.1)
                    border.color: Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                    border.width: 1
                    
                    MouseArea {
                        id: nextButton
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: currentPlayer && currentPlayer.canGoNext
                        onClicked: if (currentPlayer) currentPlayer.next()
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "skip_next"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 18
                        color: nextButton.enabled ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                    }
                }
                
                // Shuffle button
                Rectangle {
                    width: (parent.width - parent.spacing * 4) * 0.15
                    height: parent.height
                    radius: height / 2
                    color: shuffleButton.containsMouse ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : Qt.darker(Data.ThemeManager.bgColor, 1.1)
                    border.color: currentPlayer && currentPlayer.shuffle ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                    border.width: 1
                    
                    MouseArea {
                        id: shuffleButton
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: currentPlayer && currentPlayer.canControl && currentPlayer.shuffleSupported
                        onClicked: {
                            if (currentPlayer && currentPlayer.shuffleSupported) {
                                currentPlayer.shuffle = !currentPlayer.shuffle
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "shuffle"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 12
                        color: shuffleButton.enabled ? 
                               (currentPlayer && currentPlayer.shuffle ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.6)) : 
                               Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                    }
                }
                
                // Repeat button  
                Rectangle {
                    width: (parent.width - parent.spacing * 4) * 0.15
                    height: parent.height
                    radius: height / 2
                    color: repeatButton.containsMouse ? Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.2) : Qt.darker(Data.ThemeManager.bgColor, 1.1)
                    border.color: currentPlayer && currentPlayer.loopState !== MprisLoopState.None ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.accentColor.r, Data.ThemeManager.accentColor.g, Data.ThemeManager.accentColor.b, 0.3)
                    border.width: 1
                    
                    MouseArea {
                        id: repeatButton
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: currentPlayer && currentPlayer.canControl && currentPlayer.loopSupported
                        onClicked: {
                            if (currentPlayer && currentPlayer.loopSupported) {
                                if (currentPlayer.loopState === MprisLoopState.None) {
                                    currentPlayer.loopState = MprisLoopState.Track
                                } else if (currentPlayer.loopState === MprisLoopState.Track) {
                                    currentPlayer.loopState = MprisLoopState.Playlist
                                } else {
                                    currentPlayer.loopState = MprisLoopState.None
                                }
                            }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: currentPlayer && currentPlayer.loopState === MprisLoopState.Track ? "repeat_one" : "repeat"
                        font.family: "Material Symbols Outlined"
                        font.pixelSize: 12
                        color: repeatButton.enabled ? 
                               (currentPlayer && currentPlayer.loopState !== MprisLoopState.None ? Data.ThemeManager.accentColor : Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)) : 
                               Qt.rgba(Data.ThemeManager.fgColor.r, Data.ThemeManager.fgColor.g, Data.ThemeManager.fgColor.b, 0.3)
                    }
                }
            }
        }
    }
    
}