pragma Singleton

import Quickshell

Singleton {
    // Directly expose appearance properties from Config
    readonly property var rounding: Config.appearance.rounding
    readonly property var spacing: Config.appearance.spacing
    readonly property var padding: Config.appearance.padding
    readonly property var font: Config.appearance.font
    readonly property var ui: Config.appearance.ui
    readonly property var icons: Config.appearance.icons
    readonly property var typography: Config.appearance.typography
    readonly property var anim: Config.appearance.anim
    readonly property var transparency: Config.appearance.transparency
}
