import Quickshell
import QtQuick 6.9
import QtQuick.Layouts 6.9
import QtQuick.Effects
import "components" as BarComponents
import "../../components/effects"
import "../../config" as QsConfig
import "../../services" as QsServices

Item {
    id: root
    
    property var screen
    property var barWindow
    property var mediaPopup
    property var bluetoothPopup
    property var networkPopup
    property var volumePopup
    property var brightnessPopup
    property var controlCenter
    
    readonly property var config: QsConfig.Config
    readonly property var appearance: QsConfig.AppearanceConfig
    readonly property var colors: QsServices.Colors
    readonly property var barComponents: config.barComponents
    readonly property var barColors: config.barColors
    readonly property real barScale: barComponents.scale.bar

    function s(value) {
        return value * barScale
    }
    
    // ═══════════════════════════════════════════════════════════════════════
    // MINIMAL AESTHETIC BAR
    // Clean, professional, beautiful - inspired by modern Linux rice
    // ═══════════════════════════════════════════════════════════════════════
    
    // Main bar container with floating effect
    Item {
        id: barContainer
        anchors.fill: parent
        anchors.topMargin: s(1)
        anchors.leftMargin: s(9)
        anchors.rightMargin: s(9)
        anchors.bottomMargin: s(1)
        
        // ═══════════════════════════════════════════════════════════════
        // LEFT MODULE - Workspaces
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: leftModule
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: barComponents.enabled.workspaces
            height: s(28)
            width: leftContent.implicitWidth + s(16)
            
            radius: s(14)
            color: barColors.surfaceContainer
            
            // Elegant shadow simulation with subtle border
            border.width: s(1)
            border.color: barColors.border
            
            // Smooth transitions
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            
            Behavior on width {
                NumberAnimation { duration: 350; easing.bezierCurve: [0.34, 1.56, 0.64, 1] }
            }
            
            // Top highlight for depth
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: s(1)
                height: parent.height / 2
                radius: parent.radius - 1
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: barColors.highlightTop }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            RowLayout {
                id: leftContent
                anchors.centerIn: parent
                spacing: s(10)
                
                // Workspaces
                Loader {
                    id: workspacesLoader
                    Layout.alignment: Qt.AlignVCenter
                    asynchronous: true
                    source: "components/Workspaces.qml"
                    visible: barComponents.enabled.workspaces
                    
                    Binding {
                        target: workspacesLoader.item
                        property: "screen"
                        value: root.screen
                        when: workspacesLoader.status === Loader.Ready && root.screen !== undefined
                        restoreMode: Binding.RestoreBinding
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // CENTER MODULE - Clock (Focal Point)
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: centerModule
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            visible: barComponents.enabled.clock
            height: s(28)
            width: clockLoader.implicitWidth + s(20)
            
            radius: s(14)
            color: barColors.surfaceContainer
            
            border.width: s(1)
            border.color: barColors.border
            
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            
            // Top highlight
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: s(1)
                height: parent.height / 2
                radius: parent.radius - 1
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: barColors.highlightTop }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            Loader {
                id: clockLoader
                anchors.centerIn: parent
                asynchronous: true
                source: "components/Clock.qml"
                visible: barComponents.enabled.clock
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // RIGHT SIDE - Three Separate Pills
        // ═══════════════════════════════════════════════════════════════
        Row {
            id: rightPills
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: s(6)
            
            // ═══ PILL 1: Network + Bluetooth (Connectivity) ═══
            Rectangle {
                id: connectivityPill
                visible: barComponents.enabled.network || barComponents.enabled.bluetooth
                height: s(28)
                width: connectivityContent.implicitWidth + s(16)
                radius: s(14)
                color: barColors.surfaceContainer
                border.width: s(1)
                border.color: barColors.border
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: s(1)
                    height: parent.height / 2
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: barColors.highlightTop }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                Row {
                    id: connectivityContent
                    anchors.centerIn: parent
                    spacing: s(16)
                    
                    Loader {
                        id: networkLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Network.qml"
                        visible: barComponents.enabled.network
                        
                        Binding {
                            target: networkLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: networkLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: networkLoader.item
                            property: "networkPopup"
                            value: root.networkPopup
                            when: networkLoader.status === Loader.Ready && root.networkPopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    // Separator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: s(1)
                        height: s(12)
                        radius: s(0.5)
                        color: barColors.separator
                        visible: networkLoader.visible && bluetoothLoader.visible
                    }
                    
                    Loader {
                        id: bluetoothLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Bluetooth.qml"
                        visible: barComponents.enabled.bluetooth
                        
                        Binding {
                            target: bluetoothLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: bluetoothLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: bluetoothLoader.item
                            property: "bluetoothPopup"
                            value: root.bluetoothPopup
                            when: bluetoothLoader.status === Loader.Ready && root.bluetoothPopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
            
            // ═══ PILL 2: Brightness + Volume (Audio/Display) ═══
            Rectangle {
                id: audioPill
                visible: barComponents.enabled.brightness || barComponents.enabled.volume
                height: s(28)
                width: audioContent.implicitWidth + s(16)
                radius: s(14)
                color: barColors.surfaceContainer
                border.width: s(1)
                border.color: barColors.border
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: s(1)
                    height: parent.height / 2
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: barColors.highlightTop }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                Row {
                    id: audioContent
                    anchors.centerIn: parent
                    spacing: s(8)
                    
                    Loader {
                        id: brightnessLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Brightness.qml"
                        visible: barComponents.enabled.brightness
                        
                        Binding {
                            target: brightnessLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: brightnessLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: brightnessLoader.item
                            property: "brightnessPopup"
                            value: root.brightnessPopup
                            when: brightnessLoader.status === Loader.Ready && root.brightnessPopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    // Separator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: s(1)
                        height: s(12)
                        radius: s(0.5)
                        color: barColors.separator
                        visible: brightnessLoader.visible && volumeLoader.visible
                    }
                    
                    Loader {
                        id: volumeLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Volume.qml"
                        visible: barComponents.enabled.volume
                        
                        Binding {
                            target: volumeLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: volumeLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: volumeLoader.item
                            property: "volumePopup"
                            value: root.volumePopup
                            when: volumeLoader.status === Loader.Ready && root.volumePopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
            
            // ═══ PILL 3: Battery + Control Center + Tray ═══
            Rectangle {
                id: powerPill
                visible: barComponents.enabled.battery || barComponents.enabled.controlCenter || (systemTrayLoader.item?.hasItems ?? false) || (statusIndicatorsLoader.item?.hasActiveIndicators ?? false)
                height: s(28)
                width: powerContent.implicitWidth + s(16)
                radius: s(14)
                color: barColors.surfaceContainer
                border.width: s(1)
                border.color: barColors.border
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: s(1)
                    height: parent.height / 2
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: barColors.highlightTop }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                Row {
                    id: powerContent
                    anchors.centerIn: parent
                    spacing: s(8)
                    
                    // Status Indicators (Caffeine, DND)
                    Loader {
                        id: statusIndicatorsLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/StatusIndicators.qml"
                        visible: item?.hasActiveIndicators ?? false
                    }
                    
                    // Separator (only if status indicators visible)
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: s(1)
                        height: s(12)
                        radius: s(0.5)
                        color: barColors.separator
                        visible: statusIndicatorsLoader.item?.hasActiveIndicators ?? false
                    }
                    
                    // Battery
                    Loader {
                        id: batteryLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Battery.qml"
                        visible: barComponents.enabled.battery
                    }
                    
                    // Separator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: s(1)
                        height: s(12)
                        radius: s(0.5)
                        color: barColors.separator
                        visible: batteryLoader.visible && controlCenterLoader.visible
                    }
                    
                    // Control Center Toggle
                    Loader {
                        id: controlCenterLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/ControlCenterToggle.qml"
                        visible: barComponents.enabled.controlCenter
                        
                        Binding {
                            target: controlCenterLoader.item
                            property: "controlCenter"
                            value: root.controlCenter
                            when: controlCenterLoader.status === Loader.Ready && root.controlCenter !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    // System Tray (only if has items)
                    Loader {
                        id: systemTrayLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/SystemTray.qml"
                        visible: item?.hasItems ?? false
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // MEDIA MODULE - Always visible (shows "No media" when not playing)
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: mediaModule
            anchors.left: leftModule.right
            anchors.leftMargin: s(8)
            anchors.verticalCenter: parent.verticalCenter
            visible: barComponents.enabled.media
            height: s(28)
            width: mediaPlayerLoader.implicitWidth + s(16)
            
            radius: s(14)
            color: barColors.surfaceContainer
            
            border.width: s(1)
            border.color: barColors.border
            
            clip: true
            
            Behavior on width {
                NumberAnimation { 
                    duration: 400
                    easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                }
            }
            
            // Top highlight
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: s(1)
                height: parent.height / 2
                radius: parent.radius - 1
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: barColors.highlightTop }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            Loader {
                id: mediaPlayerLoader
                anchors.centerIn: parent
                asynchronous: true
                source: "components/MediaPlayer.qml"
                visible: barComponents.enabled.media
                
                Binding {
                    target: mediaPlayerLoader.item
                    property: "barWindow"
                    value: root.barWindow
                    when: mediaPlayerLoader.status === Loader.Ready && root.barWindow !== undefined
                    restoreMode: Binding.RestoreBinding
                }
                
                Binding {
                    target: mediaPlayerLoader.item
                    property: "mediaPopup"
                    value: root.mediaPopup
                    when: mediaPlayerLoader.status === Loader.Ready && root.mediaPopup !== undefined
                    restoreMode: Binding.RestoreBinding
                }
            }
        }
    }
}
