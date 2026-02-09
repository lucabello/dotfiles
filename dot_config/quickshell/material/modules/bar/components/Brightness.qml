import QtQuick 6.9
import QtQuick.Layouts 6.9
import Quickshell
import "../../../services" as QsServices
import "../../../config" as QsConfig
import "../../../components/effects"

// Brightness indicator with number - no popup
Item {
    id: root
    
    property var barWindow
    property var brightnessPopup  // Kept for compatibility but not used
    
    readonly property var pywal: QsServices.Pywal
    readonly property var brightness: QsServices.Brightness
    readonly property var appearance: QsConfig.Appearance
    readonly property var barColors: QsConfig.Config.barColors
    readonly property real componentScale: QsConfig.Config.barComponents.scale.brightness
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property int percentage: brightness.percentage
    
    implicitWidth: brightnessRow.implicitWidth * componentScale
    implicitHeight: 20 * componentScale
    scale: componentScale
    transformOrigin: Item.Center
    
    RowLayout {
        id: brightnessRow
        anchors.centerIn: parent
        spacing: 3
        
        // Brightness icon
        Text {
            id: brightnessIcon
            
            text: {
                if (percentage >= 75) return "󰃠"
                if (percentage >= 50) return "󰃟"
                if (percentage >= 25) return "󰃞"
                return "󰃝"
            }
            
            font.family: appearance.icons.family
            font.pixelSize: appearance.icons.xs
            
            color: {
                if (isHovered) return barColors.primary
                if (percentage >= 75) return barColors.warning
                return barColors.foreground
            }
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }
        
        // Percentage number
        Text {
            id: brightnessText
            
            text: percentage
            font.family: appearance.ui.family
            font.pixelSize: appearance.ui.textXs
            font.weight: appearance.ui.weightMedium
            
            color: barColors.textDim
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            // Number change animation
            Behavior on text {
                SequentialAnimation {
                    NumberAnimation {
                        target: brightnessText
                        property: "scale"
                        to: 1.15
                        duration: 80
                    }
                    NumberAnimation {
                        target: brightnessText
                        property: "scale"
                        to: 1.0
                        duration: 100
                    }
                }
            }
        }
    }
    
    // Interaction area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                brightness.increaseBrightness()
            } else {
                brightness.decreaseBrightness()
            }
        }
    }
    
    // Brightness change pulse
    Connections {
        target: brightness
        function onBrightnessChanged() {
            pulseAnim.restart()
        }
    }
    
    SequentialAnimation {
        id: pulseAnim
        
        NumberAnimation {
            target: brightnessIcon
            property: "scale"
            to: 1.2
            duration: 80
        }
        NumberAnimation {
            target: brightnessIcon
            property: "scale"
            to: isHovered ? 1.05 : 1.0
            duration: 120
        }
    }
}
