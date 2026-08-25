import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    readonly property string trDomain: "plasma_applet_com.simple.plasma.agenda"

    property string title: ""
    property alias cfg_styleMode: styleCombo.currentIndex
    property int cfg_styleModeDefault: 1
    property alias cfg_appearance: appearanceCombo.currentIndex
    property int cfg_appearanceDefault: 2
    property alias cfg_cornerRadius: radiusSpin.value
    property int cfg_cornerRadiusDefault: 16
    property alias cfg_densityMode: densityCombo.currentIndex
    property int cfg_densityModeDefault: 1
    property alias cfg_eventTextSize: eventTextSizeCombo.currentIndex
    property int cfg_eventTextSizeDefault: 1
    property int cfg_firstDayOfWeek: 1
    property int cfg_firstDayOfWeekDefault: 1
    property int cfg_lookaheadDays: 7
    property int cfg_lookaheadDaysDefault: 7
    property bool cfg_autoSyncGoogle: true
    property bool cfg_autoSyncGoogleDefault: true
    property var cfg_enabledCalendarPlugins: ["pimevents"]
    property var cfg_enabledCalendarPluginsDefault: ["pimevents"]

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        visible: true
        type: Kirigami.MessageType.Information
        text: i18nd(root.trDomain, "Solid follows the Plasma color scheme and is the recommended default. Translucent keeps the same colors with a slightly transparent background.")
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true
        ComboBox {
            id: styleCombo
            Kirigami.FormData.label: i18nd(root.trDomain, "Background:")
            model: [
                i18nd(root.trDomain, "Translucent"),
                i18nd(root.trDomain, "Solid")
            ]
        }

        Item { Kirigami.FormData.isSection: true }

        ComboBox {
            id: appearanceCombo
            Kirigami.FormData.label: i18nd(root.trDomain, "Colors:")
            model: [
                i18nd(root.trDomain, "Dark"),
                i18nd(root.trDomain, "Light"),
                i18nd(root.trDomain, "Follow system")
            ]
        }

        Item { Kirigami.FormData.isSection: true }

        ComboBox {
            id: densityCombo
            Kirigami.FormData.label: i18nd(root.trDomain, "Density:")
            model: [
                i18nd(root.trDomain, "Compact"),
                i18nd(root.trDomain, "Normal"),
                i18nd(root.trDomain, "Airy")
            ]
        }

        Item { Kirigami.FormData.isSection: true }

        ComboBox {
            id: eventTextSizeCombo
            Kirigami.FormData.label: i18nd(root.trDomain, "Event text size:")
            model: [
                i18nd(root.trDomain, "Small"),
                i18nd(root.trDomain, "Normal"),
                i18nd(root.trDomain, "Large")
            ]
        }

        Item { Kirigami.FormData.isSection: true }

        SpinBox {
            id: radiusSpin
            Kirigami.FormData.label: i18nd(root.trDomain, "Corner radius (px):")
            from: 0
            to: 40
            stepSize: 1
        }
    }

    Item { Layout.fillHeight: true }
}
