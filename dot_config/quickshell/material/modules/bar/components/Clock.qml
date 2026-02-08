import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services
import "../../../config" as QsConfig
import "../../../components/effects"

Item {
    id: root

    readonly property var appearance: QsConfig.Appearance
    readonly property var barColors: QsConfig.Config.barColors
    readonly property real componentScale: QsConfig.Config.barComponents.scale.clock
    
    implicitWidth: clockRow.implicitWidth * componentScale
    implicitHeight: clockRow.implicitHeight * componentScale
    scale: componentScale
    transformOrigin: Item.Center
    
    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8
        
        // Compact time display
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            
            // Hours
            Text {
                id: hoursText
                text: Time.format("hh")
                color: barColors.foreground
                font.pixelSize: appearance.ui.textSm
                font.weight: appearance.ui.weightBold
                font.family: appearance.ui.family
                font.letterSpacing: 0.3
            }
            
            // Animated colon separator
            Text {
                id: colonSeparator
                text: ":"
                color: barColors.primary
                font.pixelSize: appearance.ui.textSm
                font.weight: appearance.ui.weightBold
                font.family: appearance.ui.family
                
                // Subtle pulse animation
                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    
                    NumberAnimation { to: 0.4; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                }
            }
            
            // Minutes
            Text {
                id: minutesText
                text: Time.format("mm")
                color: barColors.foreground
                font.pixelSize: appearance.ui.textSm
                font.weight: appearance.ui.weightBold
                font.family: appearance.ui.family
                font.letterSpacing: 0.3
            }
        }
        
        // Compact date
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.format("ddd d")
            color: barColors.textDim
            font.pixelSize: appearance.ui.textXs
            font.weight: appearance.ui.weightMedium
            font.family: appearance.ui.family
        }
    }
}
