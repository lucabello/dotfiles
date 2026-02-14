import QtQuick 6.9
import QtQuick.Layouts 6.9
import QtQuick.Controls 6.9
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../services" as QsServices
import "../../../config" as QsConfig

// Material 3 Expressive Volume Popup
PanelWindow {
    id: popupWindow
    
    property bool shouldShow: false
    property bool isHovered: false
    readonly property var colors: QsServices.Colors
    readonly property var audio: QsServices.Audio
    readonly property var volumeMonitor: QsServices.VolumeMonitor
    readonly property var config: QsConfig.Config
    
    // Material 3 colors
    readonly property color m3Surface: Qt.rgba(
        colors.background.r,
        colors.background.g,
        colors.background.b,
        1.0
    )
    readonly property color m3Primary: colors.color4 ?? "#a6e3a1"
    readonly property color m3OnSurface: colors.foreground
    
    screen: Quickshell.screens.length > 0
        ? Quickshell.screens[Math.min(Math.max(0, config.barComponents.popupScreenIndex), Quickshell.screens.length - 1)]
        : null
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 4
        top: 4
    }
    
    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    color: "transparent"
    visible: shouldShow || container.opacity > 0
    
    // Animated container with Material 3 expressive motion
    Item {
        id: container
        anchors.fill: parent
        scale: 0.85
        opacity: 0
        transformOrigin: Item.TopRight
        
        // Bouncy entrance
        SequentialAnimation {
            running: popupWindow.shouldShow
            
            ParallelAnimation {
                NumberAnimation {
                    target: container
                    property: "scale"
                    from: 0.7
                    to: 1.08
                    duration: 280
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: container
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 250
                }
            }
            NumberAnimation {
                target: container
                property: "scale"
                to: 1.0
                duration: 220
                easing.type: Easing.OutBack
                easing.overshoot: 1.8
            }
        }
        
        // Quick exit
        ParallelAnimation {
            running: !popupWindow.shouldShow && container.opacity > 0
            
            NumberAnimation {
                target: container
                property: "scale"
                to: 0.85
                duration: 200
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: container
                property: "opacity"
                to: 0
                duration: 200
            }
        }
        
        // Shadow
        Rectangle {
            anchors.fill: backgroundRect
            anchors.margins: -6
            radius: backgroundRect.radius + 3
            color: "transparent"
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowBlur: 0.8
                shadowVerticalOffset: 8
            }
        }
    
        // Material 3 surface
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: m3Surface
            radius: 16
            
            border.color: Qt.rgba(m3Primary.r, m3Primary.g, m3Primary.b, 0.2)
            border.width: 1
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: popupWindow.isHovered = true
                onExited: {
                    popupWindow.isHovered = false
                    popupWindow.shouldShow = false
                }
            }
        }
    }
    
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        // Header
        Text {
            text: "Volume"
            font.family: "Inter"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: colors.foreground
        }
        
        // Output volume
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                    Text {
                    text: volumeMonitor.muted ? "󰖁" : "󰕾"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: colors.foreground
                }
                
                    Text {
                    text: "Output"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.7)
                }
                
                Item { Layout.fillWidth: true }
                
                    Text {
                    text: volumeMonitor.percentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: colors.foreground
                }
                
                // Mute toggle
                    Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: volumeMonitor.muted ? colors.color1 : Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.1)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                        Text {
                        anchors.centerIn: parent
                        text: volumeMonitor.muted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: colors.foreground
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audio.toggleMute()
                    }
                }
            }
            
            // Volume slider
            Slider {
                id: volumeSlider
                Layout.fillWidth: true
                wheelEnabled: false
                from: 0
                to: 150
                value: volumeMonitor.percentage
                
                onMoved: {
                    audio.setVolume(value / 100)
                }
                
                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: volumeSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.1)
                    
                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        color: colors.color2
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: colors.foreground
                    border.color: colors.color2
                    border.width: 2
                    
                    Behavior on x {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
        
        // Input volume
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: audio.sourceMuted ? "󰍭" : "󰍬"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: colors.foreground
                }
                
                    Text {
                    text: "Input"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.7)
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: audio.sourcePercentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: colors.foreground
                }
                
                // Mute toggle
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: audio.sourceMuted ? colors.color1 : Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.1)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: audio.sourceMuted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: colors.foreground
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audio.toggleSourceMute()
                    }
                }
            }
            
            // Input volume slider
            Slider {
                id: inputSlider
                Layout.fillWidth: true
                from: 0
                to: 150
                value: audio.sourcePercentage
                
                onMoved: {
                    audio.setSourceVolume(value / 100)
                }
                
                background: Rectangle {
                    x: inputSlider.leftPadding
                    y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: inputSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.1)
                    
                    Rectangle {
                        width: inputSlider.visualPosition * parent.width
                        height: parent.height
                        color: colors.color3
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                    y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: colors.foreground
                    border.color: colors.color3
                    border.width: 2
                    
                    Behavior on x {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
