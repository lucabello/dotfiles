import QtQuick 6.9

Item {
    id: root

    property url source
    property var effectProps: ({})
    readonly property Item effectItem: loader.item
    readonly property bool available: loader.status === Loader.Ready
    property bool forwardOpacity: false

    Loader {
        id: loader
        anchors.fill: parent
        source: root.source
        onLoaded: root.applyProps()
    }

    function applyProps() {
        if (!loader.item) {
            return
        }
        const props = root.effectProps || {}
        for (const key in props) {
            loader.item[key] = props[key]
        }
        if (root.forwardOpacity) {
            loader.item.opacity = Qt.binding(function() { return root.opacity })
        }
    }

    onEffectPropsChanged: applyProps()
    onSourceChanged: applyProps()
}
