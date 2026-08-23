import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.workspace.calendar 2.0 as PlasmaCalendar
import org.kde.kirigami as Kirigami
import "components"
import "widget"

PlasmoidItem {
    id: root

    readonly property string trDomain: "plasma_applet_com.simple.plasma.agenda"

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    AgendaColors {
        id: colors
        styleMode: plasmoid.configuration.styleMode
        appearance: plasmoid.configuration.appearance
    }

    // --- Date state ---
    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth() // 0..11

    // First day of week: 0 = Sunday, 1 = Monday
    readonly property int firstDow: plasmoid.configuration.firstDayOfWeek

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var weekdayShortSun: ["S", "M", "T", "W", "T", "F", "S"]
    readonly property var weekdayShortMon: ["M", "T", "W", "T", "F", "S", "S"]
    readonly property var weekdayShort: firstDow === 1 ? weekdayShortMon : weekdayShortSun

    // Column [0..6] → is this a Sat/Sun column, given the current firstDow?
    function isWeekendCol(col) {
        return firstDow === 1 ? (col === 5 || col === 6) // Mon-first: cols 5,6 = Sat,Sun
        : (col === 0 || col === 6); // Sun-first: cols 0,6 = Sun,Sat
    }

    // Precomputed day-of-month per grid slot [0..41]; 0 means empty.
    property var monthDays: []
    function rebuildMonthDays() {
        const firstOfMonth = new Date(viewYear, viewMonth, 1);
        let offset = firstOfMonth.getDay() - firstDow;
        if (offset < 0)
            offset += 7;
        const lastDay = new Date(viewYear, viewMonth + 1, 0).getDate();
        const out = new Array(42);
        for (let i = 0; i < 42; i++) {
            const day = i - offset + 1;
            out[i] = (day < 1 || day > lastDay) ? 0 : day;
        }
        monthDays = out;
    }
    onViewYearChanged: {
        rebuildMonthDays();
        _syncCalendarBackends();
        _scheduleRebuildEvents();
    }
    onViewMonthChanged: {
        rebuildMonthDays();
        _syncCalendarBackends();
        _scheduleRebuildEvents();
    }
    onFirstDowChanged: rebuildMonthDays()
    Component.onCompleted: {
        rebuildMonthDays();
        scheduleNextMidnight();
        // Delay initial event load so all three Calendar backends finish their
        // Component.onCompleted (setPluginsManager + goToYearAndMonth) first.
        initialLoadTimer.start();
        if (plasmoid.configuration.autoSyncGoogle) initialRemoteSyncTimer.start();
    }

    Timer {
        id: initialLoadTimer
        interval: 500
        repeat: false
        onTriggered: root._scheduleRebuildEvents()
    }

    // Midnight rollover
    Timer {
        id: midnightTimer
        repeat: false
        onTriggered: {
            const n = new Date();
            root.today = n;
            if (n.getFullYear() !== root.viewYear)
                root.viewYear = n.getFullYear();
            if (n.getMonth() !== root.viewMonth)
                root.viewMonth = n.getMonth();
            root.scheduleNextMidnight();
            root._scheduleRebuildEvents();
        }
    }
    function scheduleNextMidnight() {
        const now = new Date();
        const next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 5);
        midnightTimer.interval = Math.max(1000, next.getTime() - now.getTime());
        midnightTimer.start();
    }

    // --- Event lookahead preset ---
    readonly property var _lookaheadPresets: [3, 5, 7, 14]
    readonly property int effectiveLookahead: {
        var idx = plasmoid.configuration.eventLookaheadDays;
        return (idx >= 0 && idx < _lookaheadPresets.length) ? _lookaheadPresets[idx] : 7;
    }
    onEffectiveLookaheadChanged: _scheduleRebuildEvents()

    // --- Plasma Calendar backends ---
    PlasmaCalendar.EventPluginsManager {
        id: eventPluginsManager
        enabledPlugins: plasmoid.configuration.enabledCalendarPlugins
        onPluginsChanged: {
            // Plugins take a moment to load and push data into the backends.
            // Use the longer initialLoadTimer so we don't query before data arrives.
            initialLoadTimer.restart();
        }
    }

    // Current-month backend (also tracks viewYear/viewMonth for the grid)
    PlasmaCalendar.Calendar {
        id: calendarBackend
        days: 7
        weeks: 6
        firstDayOfWeek: root.firstDow
        today: root.today
        Component.onCompleted: {
            daysModel.setPluginsManager(eventPluginsManager);
        }
    }

    // Next-month backend for lookahead spanning the month boundary
    PlasmaCalendar.Calendar {
        id: nextMonthBackend
        days: 7
        weeks: 6
        firstDayOfWeek: root.firstDow
        today: root.today
        Component.onCompleted: {
            daysModel.setPluginsManager(eventPluginsManager);
            var d = new Date(root.viewYear, root.viewMonth + 1, 1);
            goToYearAndMonth(d.getFullYear(), d.getMonth() + 1);
        }
    }

    // Third backend: covers the month after next (for 60-day lookahead starting late in a month)
    PlasmaCalendar.Calendar {
        id: thirdMonthBackend
        days: 7
        weeks: 6
        firstDayOfWeek: root.firstDow
        today: root.today
        Component.onCompleted: {
            daysModel.setPluginsManager(eventPluginsManager);
            var d = new Date(root.viewYear, root.viewMonth + 2, 1);
            goToYearAndMonth(d.getFullYear(), d.getMonth() + 1);
        }
    }

    function _syncCalendarBackends() {
        var d1 = new Date(viewYear, viewMonth + 1, 1);
        nextMonthBackend.goToYearAndMonth(d1.getFullYear(), d1.getMonth() + 1);
        var d2 = new Date(viewYear, viewMonth + 2, 1);
        thirdMonthBackend.goToYearAndMonth(d2.getFullYear(), d2.getMonth() + 1);
    }

    // Pick the right DaysModel for a given date
    function _daysModelForDate(d) {
        var m = d.getMonth();
        var y = d.getFullYear();
        if (y === viewYear && m === viewMonth) return calendarBackend.daysModel;
        var nextD = new Date(viewYear, viewMonth + 1, 1);
        if (y === nextD.getFullYear() && m === nextD.getMonth()) return nextMonthBackend.daysModel;
        return thirdMonthBackend.daysModel;
    }

    Connections {
        target: calendarBackend.daysModel
        function onAgendaUpdated() { root._scheduleRebuildEvents(); }
    }
    Connections {
        target: nextMonthBackend.daysModel
        function onAgendaUpdated() { root._scheduleRebuildEvents(); }
    }
    Connections {
        target: thirdMonthBackend.daysModel
        function onAgendaUpdated() { root._scheduleRebuildEvents(); }
    }

    // Debounce rapid re-build signals
    Timer {
        id: rebuildDebounce
        interval: 80
        repeat: false
        onTriggered: root._doRebuildEventsModel()
    }
    function _scheduleRebuildEvents() {
        rebuildDebounce.restart();
    }

    // --- Flat events model (section headers + event cards) ---
    ListModel {
        id: eventsModel
    }

    // Fallback pill colors by event type when the collection has no color set.
    // These are matched against EventDataDecorator.eventType (strings from libcalendarplugin.so).
    readonly property var _eventTypeColors: ({
        "Event":    "#4B9EFF",   // blue  — calendar events
        "Todo":     "#FF9500",   // orange — tasks / todos
        "Journal":  "#34C759",   // green  — journal entries
        "Holiday":  "#FF6B6B"    // red    — public holidays
    })

    function _pillColorFor(ev) {
        var c = ev.eventColor ? ev.eventColor.toString() : "";
        if (c.length > 0 && c !== "#000000" && c !== "#00000000") return c;
        var tc = _eventTypeColors[ev.eventType];
        return tc ? tc : "#0a84ff";
    }

    function _formatTime(ev) {
        if (ev.isAllDay) return i18nd(root.trDomain, "All day");
        // The agenda is deliberately compact. Date labels follow the system
        // locale; event times use the familiar local 24-hour representation.
        return Qt.locale().toString(ev.startDateTime, "HH:mm");
    }

    function _capitalizedLocaleDate(d) {
        var text = Qt.locale().toString(d, "dddd d MMMM");
        return text.length > 0 ? text.charAt(0).toUpperCase() + text.slice(1) : text;
    }

    function _dateHeader(d, todayStart) {
        var delta = Math.round((d.getTime() - todayStart.getTime()) / 86400000);
        if (delta === 0) return i18nd(root.trDomain, "Today");
        if (delta === 1) return i18nd(root.trDomain, "Tomorrow");
        return _capitalizedLocaleDate(d);
    }

    function _weekKey(d) {
        var offset = (d.getDay() - firstDow + 7) % 7;
        var start = new Date(d.getFullYear(), d.getMonth(), d.getDate() - offset);
        return start.getFullYear() + "-" + start.getMonth() + "-" + start.getDate();
    }

    function _doRebuildEventsModel() {
        eventsModel.clear();

        var now = root.today;
        var todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        var lookaheadEnd = new Date(todayStart.getTime() + effectiveLookahead * 86400000);
        var seen = {};
        var previousWeekKey = "";
        var addedAnyDay = false;

        for (var d = new Date(todayStart); d < lookaheadEnd; d = new Date(d.getTime() + 86400000)) {
            var dm = _daysModelForDate(d);
            var rawEvents = dm.eventsForDate(d);
            if (!rawEvents || rawEvents.length === 0) continue;

            // QVariantList → JS array so we can sort.
            var events = [];
            for (var ei = 0; ei < rawEvents.length; ei++) events.push(rawEvents[ei]);

            events.sort(function(a, b) {
                if (a.isAllDay && !b.isAllDay) return -1;
                if (!a.isAllDay && b.isAllDay) return 1;
                return a.startDateTime.getTime() - b.startDateTime.getTime();
            });

            var dayEntries = [];
            for (var i = 0; i < events.length; i++) {
                var ev = events[i];
                // Deduplicate multi-day events, preserving the original backend behaviour.
                var key = ev.title + "|" + ev.startDateTime.getTime();
                if (seen[key]) continue;
                seen[key] = true;

                dayEntries.push({
                    kind: "event",
                    title: ev.title,
                    pillColor: _pillColorFor(ev),
                    isAllDay: ev.isAllDay,
                    timeLabel: _formatTime(ev)
                });
            }

            if (dayEntries.length === 0) continue;

            var wk = _weekKey(d);
            if (addedAnyDay && wk !== previousWeekKey) {
                eventsModel.append({ kind: "divider", title: "", pillColor: "", timeLabel: "", isAllDay: false });
            }

            eventsModel.append({
                kind: "header",
                title: _dateHeader(d, todayStart),
                pillColor: "",
                timeLabel: "",
                isAllDay: false
            });

            for (var di = 0; di < dayEntries.length; di++) eventsModel.append(dayEntries[di]);

            previousWeekKey = wk;
            addedAnyDay = true;
        }

    }

    // --- Google/Akonadi synchronization ---
    // We deliberately do not touch PimCalendarsModel or calendar selection.
    // Instead, we ask every Akonadi Google resource to synchronize through
    // its public D-Bus interface. This is the same operation that worked from
    // qdbus-qt6 during testing, and it updates the shared Akonadi data used by
    // both this widget and Plasma's Digital Clock.
    readonly property string _resourceListCommand: "qdbus-qt6 org.freedesktop.Akonadi /ResourceManager org.freedesktop.Akonadi.ResourceManager.resourceInstances"
    property var _syncQueue: []
    property string _currentSyncCommand: ""
    property bool remoteSyncInProgress: false
    property bool lastRemoteSyncFailed: false
    property date lastRemoteSync: new Date(0)

    Plasma5Support.DataSource {
        id: commandRunner
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            disconnectSource(source);
            root._handleCommandResult(source, data);
        }
    }

    function requestRemoteSync() {
        if (remoteSyncInProgress) return;
        remoteSyncInProgress = true;
        lastRemoteSyncFailed = false;
        _syncQueue = [];
        _currentSyncCommand = "";
        commandRunner.connectSource(_resourceListCommand);
    }

    function _handleCommandResult(source, data) {
        var exitCode = data["exit code"];
        var stdout = data["stdout"] ? data["stdout"].toString() : "";

        if (source === _resourceListCommand) {
            if (exitCode !== 0) {
                lastRemoteSyncFailed = true;
                _finishRemoteSync();
                return;
            }

            var resources = [];
            var lines = stdout.split(/\s+/);
            for (var i = 0; i < lines.length; i++) {
                var name = lines[i].trim();
                // Keep command construction safe and restrict it to Akonadi's
                // Google resource naming convention.
                if (/^akonadi_google_resource_[A-Za-z0-9_]+$/.test(name))
                    resources.push(name);
            }

            _syncQueue = resources;
            _syncNextGoogleResource();
            return;
        }

        if (source === _currentSyncCommand) {
            if (exitCode !== 0) lastRemoteSyncFailed = true;
            _syncNextGoogleResource();
        }
    }

    function _syncNextGoogleResource() {
        if (_syncQueue.length === 0) {
            _finishRemoteSync();
            return;
        }

        var resource = _syncQueue.shift();
        _currentSyncCommand = "qdbus-qt6 org.freedesktop.Akonadi.Resource." + resource
                            + " / org.freedesktop.Akonadi.Resource.synchronize";
        commandRunner.connectSource(_currentSyncCommand);
    }

    function _finishRemoteSync() {
        remoteSyncInProgress = false;
        lastRemoteSync = new Date();
        _currentSyncCommand = "";
        // D-Bus acknowledge is immediate; the actual network synchronization
        // finishes asynchronously. agendaUpdated normally rebuilds the model,
        // and this delayed pass is a harmless fallback.
        postRemoteSyncRefresh.restart();
    }

    Timer {
        id: initialRemoteSyncTimer
        interval: 1500
        repeat: false
        onTriggered: root.requestRemoteSync()
    }

    Timer {
        id: remoteSyncTimer
        interval: 5 * 60 * 1000
        repeat: true
        running: plasmoid.configuration.autoSyncGoogle
        onTriggered: root.requestRemoteSync()
    }

    Timer {
        id: postRemoteSyncRefresh
        interval: 4000
        repeat: false
        onTriggered: root._scheduleRebuildEvents()
    }

    fullRepresentation: Item {
        id: full
        Layout.preferredWidth: 330
        Layout.preferredHeight: 360
        Layout.minimumWidth: 220
        Layout.minimumHeight: 150

        readonly property real marginSize: Math.max(12, Math.min(22, Math.round(width * 0.050)))
        readonly property real labelSize: Math.max(10, Math.min(15, Math.round(width * 0.040)))
        readonly property real cardSize: Math.max(10, Math.min(15, Math.round(width * 0.039)))
        readonly property real cardSpacing: Math.max(5, Math.round(labelSize * 0.50))

        Rectangle {
            id: background
            anchors.fill: parent
            radius: plasmoid.configuration.cornerRadius
            color: colors.background
            opacity: colors.backgroundOpacity

            // Keep the outline extremely subtle; the event color bars remain
            // the main visual accent.
            border.width: 1
            border.color: Qt.rgba(colors.separator.r, colors.separator.g, colors.separator.b, 0.08)
        }

        Text {
            anchors.centerIn: parent
            anchors.margins: full.marginSize
            visible: eventsModel.count === 0
            text: i18nd(root.trDomain, "No upcoming events")
            color: colors.foreground
            font.pixelSize: full.labelSize
            font.weight: Font.Normal
            opacity: 0.55
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: Math.max(0, parent.width - full.marginSize * 2)
        }

        ListView {
            id: eventsList
            anchors.fill: parent
            anchors.margins: full.marginSize
            visible: eventsModel.count > 0
            model: eventsModel
            spacing: full.cardSpacing
            clip: true
            interactive: contentHeight > height
            rightMargin: 0

            delegate: Item {
                width: eventsList.width
                height: loader.height

                Loader {
                    id: loader
                    width: parent.width
                    sourceComponent: model.kind === "header" ? sectionHeaderComponent
                                     : model.kind === "divider" ? weekDividerComponent
                                     : eventCardComponent
                    onLoaded: {
                        if (model.kind === "header") {
                            item.headerTitle = model.title;
                        } else if (model.kind === "event") {
                            item.cardTitle = model.title;
                            item.cardTime = model.timeLabel;
                            item.cardPill = model.pillColor;
                        }
                    }
                }
            }
        }

        // Manual refresh: request a real Google -> Akonadi synchronization.
        // It does not change PIM calendar selection.
        Kirigami.Icon {
            id: refreshIcon
            z: 10
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Math.max(6, full.marginSize * 0.45)
            anchors.rightMargin: Math.max(6, full.marginSize * 0.45)
            width: Math.max(16, full.labelSize * 1.35)
            height: width
            source: "view-refresh"
            isMask: true
            color: colors.foreground
            opacity: root.lastRemoteSyncFailed ? 0.80 : (refreshMouse.containsMouse ? 0.95 : 0.42)

            MouseArea {
                id: refreshMouse
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: !root.remoteSyncInProgress
                onClicked: root.requestRemoteSync()
            }

            RotationAnimator {
                target: refreshIcon
                from: 0
                to: 360
                duration: 900
                loops: Animation.Infinite
                running: root.remoteSyncInProgress
            }
        }

        Component {
            id: sectionHeaderComponent
            Text {
                property string headerTitle: ""
                text: headerTitle
                color: colors.foreground
                font.pixelSize: full.labelSize
                font.weight: Font.DemiBold
                opacity: 0.70
                font.letterSpacing: 0.35
                rightPadding: refreshIcon.width + 8
                height: Math.round(font.pixelSize * 1.55)
                verticalAlignment: Text.AlignVCenter
            }
        }

        Component {
            id: weekDividerComponent
            Item {
                height: Math.max(12, full.cardSpacing * 2)
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 1
                    color: colors.foreground
                    opacity: 0.16
                }
            }
        }

        Component {
            id: eventCardComponent
            EventCard {
                property string cardTitle: ""
                property string cardTime: ""
                property string cardPill: ""

                width: parent ? parent.width : 0
                title: cardTitle
                timeLabel: cardTime
                pillColor: cardPill
                textColor: colors.foreground
                fontSize: full.cardSize
                cardBg: colors.cardBackground
                cardBgOpacity: colors.cardBackgroundOpacity
            }
        }
    }
}
