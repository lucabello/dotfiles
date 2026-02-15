pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    
    // Check if sink is ready for operations - use safe checks
    readonly property bool sinkReady: sink !== null && sink.audio !== null
    readonly property bool sourceReady: source !== null && source.audio !== null
    
    readonly property bool muted: sinkReady ? (sink.audio.muted ?? false) : false
    readonly property real volume: {
        if (!sinkReady) return 0
        const vol = sink.audio.volume
        if (vol === undefined || vol === null || isNaN(vol)) return 0
        return Math.max(0, Math.min(1.5, vol))
    }
    readonly property int percentage: Math.round(volume * 100)
    
    readonly property bool sourceMuted: sourceReady ? (source.audio.muted ?? false) : false
    readonly property real sourceVolume: sourceReady ? (source.audio.volume ?? 0) : 0
    readonly property int sourcePercentage: Math.round(sourceVolume * 100)
    
    Process {
        id: wpctlVolumeProc
    }

    Process {
        id: wpctlMuteProc
    }

    function setVolume(newVolume) {
        const clamped = Math.max(0, Math.min(1.5, newVolume))
        const percent = Math.round(clamped * 100) + "%"
        wpctlMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"]
        wpctlMuteProc.running = true
        wpctlVolumeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", percent]
        wpctlVolumeProc.running = true
    }
    
    function toggleMute() {
        wpctlMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        wpctlMuteProc.running = true
    }
    
    function increaseVolume() {
        setVolume(volume + 0.05)
    }
    
    function decreaseVolume() {
        setVolume(volume - 0.05)
    }
    
    function setSourceVolume(newVolume) {
        if (sourceReady && source.audio) {
            source.audio.muted = false
            source.audio.volume = Math.max(0, Math.min(1.5, newVolume))
        }
    }
    
    function toggleSourceMute() {
        if (sourceReady && source.audio) {
            source.audio.muted = !source.audio.muted
        }
    }
}
