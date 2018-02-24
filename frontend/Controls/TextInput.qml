import QtQuick 2.0
import QtQuick.Controls 2.2

TextField {
    id: component
    color: "white"
    font.family: "Roboto"
    font.weight: Font.Light
    font.pixelSize: 36
    leftPadding: 18
    topPadding: 0
    bottomPadding: 0
    verticalAlignment: Text.AlignVCenter
    selectByMouse: true

    background: Rectangle {
        color: "#2A2C31"
        radius: 4
        border.width: parent.activeFocus ? 2 : 0
        border.color: "#0ED8D2"
    }

    onActiveFocusChanged: {
        if (component.focus) {
            EventFilter.focus(this)
        }
    }
}