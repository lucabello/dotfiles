import QtQuick 6.9
import QtQuick.Layouts 6.9
import QtQuick.Controls 6.9
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../services" as QsServices
import "../../../config" as QsConfig

// Material 3 Expressive Brightness Popup
PanelWindow {
    id: popupWindow
    
    property bool shouldShow: false
    property bool isHovered: false
    readonly property var colors: QsServices.Colors
    readonly property var brightness: QsServices.Brightness
    readonly property var config: QsConfig.Config
    
    // Material 3 colors
    readonly property color m3Surface: Qt.rgba(colors.background.r, colors.background.g, colors.background.b, 1.0)
    readonly property color m3Primary: colors.color3 ?? "#f9e2af"
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
    
    // Material 3 animated container
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
            text: "Brightness"
            font.family: "Inter"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: colors.foreground
        }
        
        // Brightness control
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "󰃠"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: colors.foreground
                }
                
                Text {
                    text: "Display"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.7)
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: brightness.percentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: colors.foreground
                }
            }
            
            // Brightness slider
            Slider {
                id: brightnessSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                value: brightness.percentage
                
                onMoved: {
                    brightness.setBrightness(value / 100)
                }
                
                background: Rectangle {
                    x: brightnessSlider.leftPadding
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: brightnessSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.1)
                    
                    Rectangle {
                        width: brightnessSlider.visualPosition * parent.width
                        height: parent.height
                        color: colors.color3
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
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
            
            // Quick brightness presets
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Repeater {
                    model: [
                        { label: "25%", value: 0.25 },
                        { label: "50%", value: 0.5 },
                        { label: "75%", value: 0.75 },
                        { label: "100%", value: 1.0 }
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 28
                        radius: 6
                        color: Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.1)
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: colors.foreground
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: brightness.setBrightness(modelData.value)
                            
                            onPressed: parent.color = Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.2)
                            onReleased: parent.color = Qt.rgba(colors.foreground.r, colors.foreground.g, colors.foreground.b, 0.1)
                        }
                    }
                }
            }
        }
    }
}
