import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing

    readonly property string trDomain: "plasma_applet_com.simple.plasma.agenda"

    // Plasma passes every config key (and its default) to each config page.
    // Declare the complete set here to avoid noisy "Setting initial properties
    // failed" warnings while keeping aliases for the controls owned by this page.
    property string title: ""
    property alias cfg_firstDayOfWeek: firstDayCombo.currentIndex
    property int cfg_firstDayOfWeekDefault: 1
    property int cfg_lookaheadDays: 7
    property int cfg_lookaheadDaysDefault: 7
    property alias cfg_autoSyncGoogle: autoSyncCheck.checked
    property bool cfg_autoSyncGoogleDefault: true
    property int cfg_styleMode: 1
    property int cfg_styleModeDefault: 1
    property int cfg_appearance: 2
    property int cfg_appearanceDefault: 2
    property int cfg_transparencyLevel: 1
    property int cfg_transparencyLevelDefault: 1
    property int cfg_cornerRadius: 12
    property int cfg_cornerRadiusDefault: 12
    property int cfg_densityMode: 1
    property int cfg_densityModeDefault: 1
    property int cfg_eventTextSize: 1
    property int cfg_eventTextSizeDefault: 1
    property bool cfg_showTitle: true
    property bool cfg_showTitleDefault: true
    property bool cfg_showWeekDividers: true
    property bool cfg_showWeekDividersDefault: true
    property bool cfg_highlightTemporalEvents: true
    property bool cfg_highlightTemporalEventsDefault: true
    property var cfg_enabledCalendarPlugins: ["pimevents"]
    property var cfg_enabledCalendarPluginsDefault: ["pimevents"]

    readonly property var _lookaheadValues: [1, 3, 5, 7, 14, 21, 28]

    Kirigami.FormLayout {
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.largeSpacing

        ComboBox {
            id: firstDayCombo
            Kirigami.FormData.label: i18nd(root.trDomain, "First day of week:")
            model: [
                i18nd(root.trDomain, "Sunday"),
                i18nd(root.trDomain, "Monday")
            ]
        }

        ComboBox {
            id: lookaheadCombo
            Kirigami.FormData.label: i18nd(root.trDomain, "Show events for:")
            model: [
                i18nd(root.trDomain, "1 day"),
                i18nd(root.trDomain, "3 days"),
                i18nd(root.trDomain, "5 days"),
                i18nd(root.trDomain, "7 days"),
                i18nd(root.trDomain, "2 weeks (14 days)"),
                i18nd(root.trDomain, "3 weeks (21 days)"),
                i18nd(root.trDomain, "4 weeks (28 days)")
            ]
            currentIndex: root._lookaheadValues.indexOf(root.cfg_lookaheadDays)
            onActivated: root.cfg_lookaheadDays = root._lookaheadValues[currentIndex]
        }
    }

    CheckBox {
        id: autoSyncCheck
        Layout.fillWidth: true
        text: i18nd(root.trDomain, "Force Google Calendar synchronization through Akonadi every 5 minutes")
    }

    Kirigami.Separator { Layout.fillWidth: true }

    Kirigami.Heading {
        Layout.fillWidth: true
        level: 3
        text: i18nd(root.trDomain, "Calendar source")
    }

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing
        visible: true
        type: Kirigami.MessageType.Information
        text: i18nd(root.trDomain, "Simple Plasma Agenda displays calendars exposed by KDE PIM/Akonadi. To change which calendars are shown, run the installer again with --calendars.")
    }

    Label {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing
        wrapMode: Text.WordWrap
        text: i18nd(root.trDomain, "The refresh button forces Akonadi Google resources to synchronize immediately. Other Akonadi sources keep using their own synchronization mechanisms.")
    }

    Item { Layout.fillHeight: true }
}
