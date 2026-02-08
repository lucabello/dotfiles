import QtQuick 6.10

QtObject {
    // Centralized bar component scaling
    readonly property var scale: QtObject {
        property real bar: 1.5
        property real clock: 1.5
        property real network: 1.5
        property real bluetooth: 1.5
        property real battery: 1.5
        property real volume: 1.5
        property real brightness: 1.5
        property real media: 1.5
        property real workspaces: 1.5
        property real controlCenter: 1.5
    }

    // Centralized bar component toggles
    readonly property var enabled: QtObject {
        property bool bar: true
        property bool clock: true
        property bool network: true
        property bool bluetooth: true
        property bool battery: false
        property bool volume: true
        property bool brightness: false
        property bool media: true
        property bool workspaces: true
        property bool controlCenter: true
    }
}
