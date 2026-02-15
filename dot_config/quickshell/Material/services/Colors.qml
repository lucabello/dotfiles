pragma Singleton
import QtQuick 6.9

QtObject {
    // Fallback palette (will be overridden by overrides/Colors.qml when installed)
    readonly property color surface: "#1e1e2e"
    readonly property color background: surface
    readonly property color foreground: "#cdd6f4"
    readonly property color primary: "#89b4fa"
    readonly property color secondary: "#cba6f7"
    readonly property color warning: "#fab387"
    readonly property color error: "#f38ba8"
    readonly property color failure: error
    readonly property color success: "#a6e3a1"
    readonly property color info: "#89b4fa"

    // Quick aliases for components that used color1..color4
    readonly property color color1: primary
    readonly property color color2: secondary
    readonly property color color3: info
    readonly property color color4: success

    // Derived surfaces
    readonly property color surfaceContainer: Qt.lighter(surface, 1.12)
    readonly property color surfaceContainerHigh: Qt.lighter(surface, 1.2)

    // Chrome and separators
    readonly property color border: Qt.rgba(0, 0, 0, 0.15)
    readonly property color outline: Qt.rgba(0, 0, 0, 0.2)
    readonly property color shadow: Qt.rgba(0, 0, 0, 0.4)
    readonly property color separator: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.12)
    readonly property color highlightTop: Qt.rgba(1, 1, 1, 0.04)

    // Text ramps
    readonly property color textDim: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.7)
    readonly property color textMuted: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.8)
    readonly property color textDisabled: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.4)
    readonly property color textDisabledStrong: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.3)
}
