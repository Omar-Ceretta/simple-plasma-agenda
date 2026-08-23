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
    property alias cfg_eventLookaheadDays: lookaheadCombo.currentIndex
    property int cfg_eventLookaheadDaysDefault: 2
    property alias cfg_autoSyncGoogle: autoSyncCheck.checked
    property bool cfg_autoSyncGoogleDefault: true
    property int cfg_styleMode: 1
    property int cfg_styleModeDefault: 1
    property int cfg_appearance: 2
    property int cfg_appearanceDefault: 2
    property int cfg_cornerRadius: 14
    property int cfg_cornerRadiusDefault: 14
    property var cfg_enabledCalendarPlugins: ["pimevents"]
    property var cfg_enabledCalendarPluginsDefault: ["pimevents"]

    Kirigami.FormLayout {
        Layout.fillWidth: true

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
                i18nd(root.trDomain, "3 days"),
                i18nd(root.trDomain, "5 days"),
                i18nd(root.trDomain, "7 days"),
                i18nd(root.trDomain, "14 days")
            ]
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
        visible: true
        type: Kirigami.MessageType.Information
        text: i18nd(root.trDomain, "Simple Plasma Agenda displays events exposed by KDE PIM/Akonadi. This can include Google, CalDAV/Nextcloud, iCalendar and other sources configured in Akonadi.")
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: i18nd(root.trDomain, "Calendar and account selection is intentionally not changed from this widget. No additional login or Google API project is required by Simple Plasma Agenda.")
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: i18nd(root.trDomain, "The desktop refresh button currently forces Akonadi Google resources to synchronize immediately. Automatic synchronization can do the same every 5 minutes; other Akonadi sources remain visible but use their own synchronization mechanisms.")
    }

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        visible: true
        type: Kirigami.MessageType.Warning
        text: i18nd(root.trDomain, "Changing the enabled PIM calendars from some Plasma 6 widgets can crash plasmashell. For this reason this widget does not provide calendar-selection checkboxes.")
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        text: i18nd(root.trDomain, "Akonadi data are shared with Plasma's Digital Clock, so a synchronization requested here updates its agenda too.")
    }

    Label {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        opacity: 0.55
        text: "Simple Plasma Agenda 0.2.3"
    }

    Item { Layout.fillHeight: true }
}
