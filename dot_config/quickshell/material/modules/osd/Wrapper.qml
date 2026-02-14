import Quickshell
import QtQuick

Scope {
    id: root
    
    required property var colors

    VolumeOSD {
        colors: root.colors
    }

    BrightnessOSD {
        colors: root.colors
    }
}
