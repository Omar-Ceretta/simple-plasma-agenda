import QtQuick

Item {
    id: card

    property string title: ""
    property string timeLabel: ""
    property color pillColor: "#FF6B6B"
    property color textColor: "#ffffff"
    property real fontSize: 11
    property real densityScale: 1.0
    property color cardBg: "#ffffff"
    property real cardBgOpacity: 0.10
    property real pastAfter: 0
    property real nowTimestamp: 0
    property color focusColor: "#3daee9"
    property string accessibleDescription: ""

    signal activated()

    activeFocusOnTab: true

    Accessible.role: Accessible.Button
    Accessible.name: timeLabel.length > 0 ? title + ", " + timeLabel : title
    Accessible.description: accessibleDescription
    Accessible.focusable: true
    Accessible.focused: activeFocus
    Accessible.onPressAction: card.activated()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            card.activated();
            event.accepted = true;
        }
    }

    readonly property bool isPast: pastAfter > 0 && nowTimestamp >= pastAfter

    readonly property real _pad: Math.round(height * 0.22)

    implicitHeight: Math.round(fontSize * 2.8 * densityScale)

    Rectangle {
        anchors.fill: parent
        radius: Math.round(card.height * 0.25)
        color: card.cardBg
        opacity: Math.min(1.0, card.cardBgOpacity
                          + (clickArea.containsMouse ? 0.045 : 0.0)
                          + (card.activeFocus ? 0.025 : 0.0))

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    // Keyboard focus is deliberately visible but quieter than the day accent.
    Rectangle {
        anchors.fill: parent
        radius: Math.round(card.height * 0.25)
        color: "transparent"
        border.width: card.activeFocus ? 1 : 0
        border.color: card.focusColor
        opacity: 0.72
    }

    Rectangle {
        id: pill
        x: card._pad
        y: card._pad
        width: 3
        height: parent.height - 2 * card._pad
        radius: 1.5
        color: card.pillColor
        opacity: card.isPast ? 0.58 : 1.0
    }

    Text {
        anchors.left: pill.right
        anchors.leftMargin: 6
        anchors.right: timeText.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        text: card.title
        Accessible.ignored: true
        color: card.textColor
        opacity: card.isPast ? 0.46 : 1.0
        font.pixelSize: card.fontSize
        elide: Text.ElideRight
    }

    Text {
        id: timeText
        anchors.right: parent.right
        anchors.rightMargin: card._pad
        anchors.verticalCenter: parent.verticalCenter
        text: card.timeLabel
        Accessible.ignored: true
        color: card.textColor
        opacity: card.isPast ? 0.34 : 0.6
        font.pixelSize: Math.round(card.fontSize * 0.85)
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: card.activated()
    }
}
