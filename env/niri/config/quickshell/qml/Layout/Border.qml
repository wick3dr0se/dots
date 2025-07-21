import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import "root:/Data" as Data

// Screen border with shadow effects
Shape {
    id: borderShape

    // Border dimensions
    property real borderWidth: Data.Settings.borderWidth
    property real radius: Data.Settings.cornerRadius
    property real innerX: borderWidth
    property real innerY: borderWidth
    property real innerWidth: borderShape.width - (borderWidth * 2)
    property real innerHeight: borderShape.height - (borderWidth * 2)
    
    // Widget references for shadow positioning
    property var workspaceIndicator: null
    property var volumeOSD: null
    property var clockWidget: null
    
    // Initialization state to prevent ShaderEffect warnings
    property bool effectsReady: false
    
    // Burst effect properties - controlled by workspace indicator
    property real masterProgress: workspaceIndicator ? workspaceIndicator.masterProgress : 0.0
    property bool effectsActive: workspaceIndicator ? workspaceIndicator.effectsActive : false
    property color effectColor: workspaceIndicator ? workspaceIndicator.effectColor : Data.ThemeManager.accent
    
    // Delay graphics effects until component is fully loaded
    Timer {
        id: initTimer
        interval: 100
        running: true
        onTriggered: borderShape.effectsReady = true
    }
    
    // Burst effect overlays (DISABLED - using unified overlay)
    Item {
        id: burstEffects
        anchors.fill: parent
        visible: false  // Disabled in favor of unified overlay
        z: 5
    }
    
    // Individual widget shadows (positioned separately)
    
    // Workspace indicator shadow
    Shape {
        id: workspaceDropShadow
        visible: borderShape.workspaceIndicator !== null
        x: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.x : 0  // Exact match
        y: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.y : 0
        width: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.width : 0  // Exact match
        height: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.height : 0
        z: -1
        
        layer.enabled: borderShape.workspaceIndicator !== null
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 1
            verticalOffset: 1
            radius: 12 + (effectsActive && Data.Settings.workspaceGlowEnabled ? Math.sin(masterProgress * Math.PI) * 4 : 0)
            samples: 25
            color: {
                if (!effectsActive) return Qt.rgba(0, 0, 0, 0.4)
                if (!Data.Settings.workspaceGlowEnabled) return Qt.rgba(0, 0, 0, 0.4)
                // Use accent color directly with reduced intensity
                const intensity = Math.sin(masterProgress * Math.PI) * 0.4
                return Qt.rgba(
                    effectColor.r * intensity + 0.08,
                    effectColor.g * intensity + 0.08,
                    effectColor.b * intensity + 0.08,
                    0.4 + intensity * 0.2
                )
            }
            cached: true
            spread: 0.2 + (effectsActive && Data.Settings.workspaceGlowEnabled ? Math.sin(masterProgress * Math.PI) * 0.15 : 0)
        }
        
        ShapePath {
            strokeWidth: 0
            fillColor: "black"
            
            startX: 12
            startY: 0
            
            // Right side - standard rounded corners
            PathLine { x: workspaceDropShadow.width - 16; y: 0 }
            
            PathArc {
                x: workspaceDropShadow.width; y: 16
                radiusX: 16; radiusY: 16
                direction: PathArc.Clockwise
            }
            
            PathLine { x: workspaceDropShadow.width; y: workspaceDropShadow.height - 16 }
            
            PathArc {
                x: workspaceDropShadow.width - 16; y: workspaceDropShadow.height
                radiusX: 16; radiusY: 16
                direction: PathArc.Clockwise
            }
            
            PathLine { x: 12; y: workspaceDropShadow.height }
            
            // Left side - concave curves for border integration
            PathLine { x: 0; y: workspaceDropShadow.height - 12 }
            PathArc {
                x: 12; y: workspaceDropShadow.height - 24
                radiusX: 12; radiusY: 12
                direction: PathArc.Clockwise
            }
            
            PathLine { x: 12; y: 24 }
            
            PathArc {
                x: 0; y: 12
                radiusX: 12; radiusY: 12
                direction: PathArc.Clockwise
            }
            PathLine { x: 12; y: 0 }
        }
    }
    
    // Volume OSD shadow
    Rectangle {
        id: volumeOsdDropShadow
        visible: borderShape.volumeOSD !== null && borderShape.volumeOSD.visible
        opacity: borderShape.volumeOSD ? borderShape.volumeOSD.opacity : 0
        x: parent.width - 45
        y: (parent.height - 250) / 2
        width: 45
        height: 250
        color: "black"
        topLeftRadius: 20
        bottomLeftRadius: 20
        topRightRadius: 0
        bottomRightRadius: 0
        z: -1
        
        // Sync opacity animations with volume OSD
        Behavior on opacity {
            NumberAnimation { 
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        
        layer.enabled: borderShape.volumeOSD !== null
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: -1
            verticalOffset: 1
            radius: 12                     // Much more subtle
            samples: 25
            color: Qt.rgba(0, 0, 0, 0.4)   // Very light shadow
            cached: false
            spread: 0.2                    // Minimal spread
        }
    }
    
    // Clock shadow
    Rectangle {
        id: clockDropShadow
        visible: borderShape.clockWidget !== null
        x: borderShape.clockWidget ? borderShape.clockWidget.x : 0
        y: borderShape.clockWidget ? borderShape.clockWidget.y : 0
        width: borderShape.clockWidget ? borderShape.clockWidget.width : 0
        height: borderShape.clockWidget ? borderShape.clockWidget.height : 0
        color: "black"
        topLeftRadius: 0
        topRightRadius: borderShape.clockWidget ? borderShape.clockWidget.height / 2 : 16
        bottomLeftRadius: 0
        bottomRightRadius: 0
        z: -2  // Lower z-index to render behind border corners
        
        layer.enabled: borderShape.clockWidget !== null
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 1
            verticalOffset: -1
            radius: 12                     // Much more subtle
            samples: 25
            color: Qt.rgba(0, 0, 0, 0.4)   // Very light shadow
            cached: false
            spread: 0.2                    // Minimal spread
        }
    }
    
        
    // Shadow rendering source (hidden)
    Item {
        id: shadowSource
        anchors.fill: parent
        visible: false
        
        Shape {
            id: borderShadowShape
            anchors.fill: parent
            
            layer.enabled: true
            layer.samples: 4
        
        ShapePath {
            fillColor: "black"
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill

            // Outer rectangle (full screen)
            PathMove { x: 0; y: 0 }
            PathLine { x: shadowSource.width; y: 0 }
            PathLine { x: shadowSource.width; y: shadowSource.height }
            PathLine { x: 0; y: shadowSource.height }
            PathLine { x: 0; y: 0 }

            // Inner rounded cutout creates border
            PathMove { 
                x: borderShape.innerX + borderShape.radius
                y: borderShape.innerY
            }
            
            PathLine {
                x: borderShape.innerX + borderShape.innerWidth - borderShape.radius
                y: borderShape.innerY
            }
            
            PathArc {
                x: borderShape.innerX + borderShape.innerWidth
                y: borderShape.innerY + borderShape.radius
                radiusX: borderShape.radius
                radiusY: borderShape.radius
                direction: PathArc.Clockwise
            }
            
            PathLine {
                x: borderShape.innerX + borderShape.innerWidth
                y: borderShape.innerY + borderShape.innerHeight - borderShape.radius
            }
            
            PathArc {
                x: borderShape.innerX + borderShape.innerWidth - borderShape.radius
                y: borderShape.innerY + borderShape.innerHeight
                radiusX: borderShape.radius
                radiusY: borderShape.radius
                direction: PathArc.Clockwise
            }
            
            PathLine {
                x: borderShape.innerX + borderShape.radius
                y: borderShape.innerY + borderShape.innerHeight
            }
            
            PathArc {
                x: borderShape.innerX
                y: borderShape.innerY + borderShape.innerHeight - borderShape.radius
                radiusX: borderShape.radius
                radiusY: borderShape.radius
                direction: PathArc.Clockwise
            }
            
            PathLine {
                x: borderShape.innerX
                y: borderShape.innerY + borderShape.radius
            }
            
            PathArc {
                x: borderShape.innerX + borderShape.radius
                y: borderShape.innerY
                radiusX: borderShape.radius
                radiusY: borderShape.radius
                direction: PathArc.Clockwise
            }
        }
        }
        
        // Workspace indicator shadow with concave curves
        Shape {
            id: workspaceShadowShape
            visible: borderShape.workspaceIndicator !== null
            x: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.x : 0  // Exact match
            y: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.y : 0
            width: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.width : 0  // Exact match
            height: borderShape.workspaceIndicator ? borderShape.workspaceIndicator.height : 0
            preferredRendererType: Shape.CurveRenderer
            
            layer.enabled: borderShape.workspaceIndicator !== null
            layer.samples: 8
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: 3
                radius: 25 + (effectsActive && Data.Settings.workspaceGlowEnabled ? Math.sin(masterProgress * Math.PI) * 6 : 0)
                samples: 40
                color: {
                    if (!effectsActive) return Qt.rgba(0, 0, 0, 0.8)
                    if (!Data.Settings.workspaceGlowEnabled) return Qt.rgba(0, 0, 0, 0.8)
                    // Accent color glow with reduced intensity
                    const intensity = Math.sin(masterProgress * Math.PI) * 0.3
                    return Qt.rgba(
                        effectColor.r * intensity + 0.1,
                        effectColor.g * intensity + 0.1,
                        effectColor.b * intensity + 0.1,
                        0.6 + intensity * 0.15
                    )
                }
                cached: false
                spread: 0.5 + (effectsActive && Data.Settings.workspaceGlowEnabled ? Math.sin(masterProgress * Math.PI) * 0.2 : 0)
            }
            
            ShapePath {
                strokeWidth: 0
                fillColor: "black"
                strokeColor: "black"
                
                startX: 12
                startY: 0
                
                // Right side - standard rounded corners
                PathLine { x: workspaceShadowShape.width - 16; y: 0 }
                
                PathArc {
                    x: workspaceShadowShape.width; y: 16
                    radiusX: 16; radiusY: 16
                    direction: PathArc.Clockwise
                }
                
                PathLine { x: workspaceShadowShape.width; y: workspaceShadowShape.height - 16 }
                
                PathArc {
                    x: workspaceShadowShape.width - 16; y: workspaceShadowShape.height
                    radiusX: 16; radiusY: 16
                    direction: PathArc.Clockwise
                }
                
                PathLine { x: 12; y: workspaceShadowShape.height }
                
                // Left side - concave curves for border integration
                PathLine { x: 0; y: workspaceShadowShape.height - 12 }
                PathArc {
                    x: 12; y: workspaceShadowShape.height - 24
                    radiusX: 12; radiusY: 12
                    direction: PathArc.Clockwise
                }
                
                PathLine { x: 12; y: 24 }
                
                PathArc {
                    x: 0; y: 12
                    radiusX: 12; radiusY: 12
                    direction: PathArc.Clockwise
                }
                PathLine { x: 12; y: 0 }
            }
        }
        
        // Volume OSD shadow
        Rectangle {
            id: volumeOsdShadowShape
            visible: borderShape.volumeOSD !== null && borderShape.volumeOSD.visible
            x: shadowSource.width - 45
            y: (shadowSource.height - 250) / 2
            width: 45
            height: 250
            color: "black"
            topLeftRadius: 20
            bottomLeftRadius: 20
            topRightRadius: 0
            bottomRightRadius: 0
            
            layer.enabled: borderShape.volumeOSD !== null && borderShape.volumeOSD.visible
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: -2  // Shadow to the left for right-side widget
                verticalOffset: 3
                radius: 25
                samples: 40
                color: Qt.rgba(0, 0, 0, 0.8)
                cached: false
                spread: 0.5
            }
        }
        
        // Clock shadow
        Rectangle {
            id: clockShadowShape
            visible: borderShape.clockWidget !== null
            x: borderShape.clockWidget ? borderShape.clockWidget.x : 0
            y: borderShape.clockWidget ? borderShape.clockWidget.y : 0
            width: borderShape.clockWidget ? borderShape.clockWidget.width : 0
            height: borderShape.clockWidget ? borderShape.clockWidget.height : 0
            color: "black"
            topLeftRadius: 0
            topRightRadius: borderShape.clockWidget ? borderShape.clockWidget.height / 2 : 16
            bottomLeftRadius: 0
            bottomRightRadius: 0
            
            layer.enabled: borderShape.clockWidget !== null
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 2
                verticalOffset: -2  // Shadow upward for bottom widget
                radius: 25
                samples: 40
                color: Qt.rgba(0, 0, 0, 0.8)
                cached: false
                spread: 0.5
            }
        }
    }

    // Apply shadow effect to entire border shape
    layer.enabled: true
    layer.samples: 8
    layer.smooth: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 1
        verticalOffset: 2
        radius: 30                     // Slightly less dramatic
        samples: 45                    
        color: Qt.rgba(0, 0, 0, 0.75)  // A bit lighter
        cached: false
        spread: 0.5                    // Less spread
    }

    // Main border shape
    ShapePath {
        fillColor: Data.ThemeManager.bgColor
        strokeWidth: 0
        fillRule: ShapePath.OddEvenFill

        // Outer rectangle
        PathMove { x: 0; y: 0 }
        PathLine { x: borderShape.width; y: 0 }
        PathLine { x: borderShape.width; y: borderShape.height }
        PathLine { x: 0; y: borderShape.height }
        PathLine { x: 0; y: 0 }

        // Inner rounded cutout
        PathMove { 
            x: borderShape.innerX + borderShape.radius
            y: borderShape.innerY
        }
        
        PathLine {
            x: borderShape.innerX + borderShape.innerWidth - borderShape.radius
            y: borderShape.innerY
        }
        
        PathArc {
            x: borderShape.innerX + borderShape.innerWidth
            y: borderShape.innerY + borderShape.radius
            radiusX: borderShape.radius
            radiusY: borderShape.radius
            direction: PathArc.Clockwise
        }
        
        PathLine {
            x: borderShape.innerX + borderShape.innerWidth
            y: borderShape.innerY + borderShape.innerHeight - borderShape.radius
        }
        
        PathArc {
            x: borderShape.innerX + borderShape.innerWidth - borderShape.radius
            y: borderShape.innerY + borderShape.innerHeight
            radiusX: borderShape.radius
            radiusY: borderShape.radius
            direction: PathArc.Clockwise
        }
        
        PathLine {
            x: borderShape.innerX + borderShape.radius
            y: borderShape.innerY + borderShape.innerHeight
        }
        
        PathArc {
            x: borderShape.innerX
            y: borderShape.innerY + borderShape.innerHeight - borderShape.radius
            radiusX: borderShape.radius
            radiusY: borderShape.radius
            direction: PathArc.Clockwise
        }
        
        PathLine {
            x: borderShape.innerX
            y: borderShape.innerY + borderShape.radius
        }
        
        PathArc {
            x: borderShape.innerX + borderShape.radius
            y: borderShape.innerY
            radiusX: borderShape.radius
            radiusY: borderShape.radius
            direction: PathArc.Clockwise
        }
    }
} 