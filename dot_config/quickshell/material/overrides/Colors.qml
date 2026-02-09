import QtQuick 6.9

QtObject {
    // Base palette (hardcoded)
    readonly property color surface: "#070605"
    readonly property color foreground: "#e9e5e6"
    readonly property color primary: "#CE6649"
    readonly property color secondary: "#9A847D"
    readonly property color warning: "#FF9F00"
    readonly property color error: "#DE1222"

    // Derived surfaces
    readonly property color surfaceContainer: Qt.lighter(surface, 1.12)
    readonly property color surfaceContainerHigh: Qt.lighter(surface, 1.2)

    // Chrome and separators
    readonly property color border: Qt.rgba(0, 0, 0, 0.15)
    readonly property color separator: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.12)
    readonly property color highlightTop: Qt.rgba(1, 1, 1, 0.04)

    // Text ramps
    readonly property color textDim: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.7)
    readonly property color textMuted: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.8)
    readonly property color textDisabled: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.4)
    readonly property color textDisabledStrong: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.3)
}
