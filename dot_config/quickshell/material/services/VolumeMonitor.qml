pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Monitor volume via wpctl for consistent PipeWire state
Singleton {
    id: root
    
    property int percentage: 50
    property bool muted: false
    
    // Fast polling for responsive OSD (200ms)
    Timer {
        interval: 200
        repeat: true
        running: true
        triggeredOnStart: true
        
        onTriggered: {
            if (!volumeProc.running) {
                volumeProc.running = true
            }
        }
    }
    
    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim()
                const match = output.match(/Volume:\s*([0-9.]+)/)
                const vol = match ? Math.round(parseFloat(match[1]) * 100) : root.percentage
                const isMuted = output.includes("MUTED")
                if (vol !== root.percentage) {
                    root.percentage = vol
                }
                if (isMuted !== root.muted) {
                    root.muted = isMuted
                }
            }
        }
    }
    
    Component.onCompleted: {
        console.log("📊 [VolumeMonitor] Service loaded - monitoring via wpctl")
    }
}
