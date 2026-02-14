import QtQuick 6.9
import QtQuick.Layouts 6.9
import Quickshell
import Quickshell.Bluetooth
import "../../../services" as QsServices
import "../../../config" as QsConfig

// Clean Bluetooth indicator - No shadows, proper alignment
Item {
    id: root
    
    property var barWindow
    property var bluetoothPopup
    
    
    readonly property var barColors: QsConfig.Config.barColors
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property real componentScale: QsConfig.Config.barComponents.scale.bluetooth
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property bool hasConnection: connectedDevices.length > 0
    readonly property bool isEnabled: adapter?.enabled ?? false
    readonly property string deviceName: hasConnection ? (connectedDevices[0]?.name ?? "Device") : ""
    readonly property int deviceCount: connectedDevices.length
    
    implicitWidth: bluetoothRow.implicitWidth * componentScale
    implicitHeight: 20 * componentScale
    scale: componentScale
    transformOrigin: Item.Center
    
    RowLayout {
        id: bluetoothRow
        anchors.centerIn: parent
        spacing: 5
        
        // Bluetooth icon
        Text {
            id: bluetoothIcon
            Layout.alignment: Qt.AlignVCenter
            
            text: {
                if (!isEnabled) return "󰂲"
                if (hasConnection) return "󰂱"
                return "󰂯"
            }
            
            font.family: "Material Design Icons"
            font.pixelSize: 14
            
            color: {
                if (!isEnabled) return barColors.textDisabledStrong
                if (isHovered) return barColors.primary
                if (hasConnection) return barColors.textMuted
                return barColors.textDisabled
            }
            
            Behavior on color { ColorAnimation { duration: 150 } }
            
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
        
        // Device name - simple text, no gradient overlay
        Text {
            id: deviceText
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 65
            
            text: {
                if (!isEnabled) return "Off"
                if (!hasConnection) return "No Device"
                if (deviceCount > 1) return deviceName + " +" + (deviceCount - 1)
                return deviceName
            }
            
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: hasConnection ? Font.Medium : Font.Normal
            elide: Text.ElideRight
            
            color: {
                if (!isEnabled || !hasConnection) return barColors.textDisabled
                if (isHovered) return barColors.foreground
                return barColors.textDim
            }
            
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
    
    // Click handler
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        
        onClicked: {
            if (!bluetoothPopup) return
            
            if (bluetoothPopup.shouldShow) {
                bluetoothPopup.shouldShow = false
            } else {
                if (!barWindow || !barWindow.screen) return
                
                const pos = root.mapToItem(barWindow.contentItem, 0, 0)
                const rightEdge = pos.x + root.width
                const screenWidth = barWindow.screen.width
                
                // Position popup below the bar
                // Bar anchors to screen top, so margins.top = bar_height + gap
                // Use the small, centralized popup margin so vertical gap matches Control Center
                bluetoothPopup.margins.right = Math.round(screenWidth - rightEdge - 8)
                bluetoothPopup.margins.top = (barWindow?.config?.barComponents?.popupMargin) || 12
                bluetoothPopup.shouldShow = true
            }
        }
    }
}
