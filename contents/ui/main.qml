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
    property double currentTimeMs: Date.now()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth() // 0..11

    // First day of week: 0 = Sunday, 1 = Monday
    readonly property int firstDow: plasmoid.configuration.firstDayOfWeek

    onViewYearChanged: {
        _syncCalendarBackends();
        _scheduleRebuildEvents();
    }
    onViewMonthChanged: {
        _syncCalendarBackends();
        _scheduleRebuildEvents();
    }
    onFirstDowChanged: _scheduleRebuildEvents()
    Component.onCompleted: {
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

    // Refresh only the visual "past" state of event cards. This timer does not
    // query or synchronize Akonadi; it merely advances the local clock used
    // by the delegates to compare against each event's end time.
    Timer {
        id: pastStateTimer
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.currentTimeMs = Date.now()
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

    // --- Event lookahead ---
    readonly property int effectiveLookahead: plasmoid.configuration.lookaheadDays
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

    // Current-month backend; viewYear/viewMonth keep the three event backends aligned
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

    // Third backend retained to preserve the proven month-spanning backend structure.
    // Even with the current 28-day maximum it is normally not queried, but keeping
    // the proven backend arrangement avoids unnecessary PIM-side changes.
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

    function _pastAfterFor(ev, dayDate) {
        // All-day entries remain active for the whole displayed day.
        if (ev.isAllDay) {
            return new Date(dayDate.getFullYear(), dayDate.getMonth(), dayDate.getDate() + 1, 0, 0, 0).getTime();
        }

        // Timed events become past only when their actual end time has passed.
        // If a backend ever provides no valid end time, keep the event active
        // rather than guessing from its start time.
        var end = ev.endDateTime;
        if (end && typeof end.getTime === "function") {
            var endMs = end.getTime();
            if (!isNaN(endMs)) return endMs;
        }
        return 0;
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

    function _emptyAgendaText() {
        if (effectiveLookahead === 1)
            return i18nd(root.trDomain, "No events today.");
        return i18nd(root.trDomain, "No events in the next %1 days.", effectiveLookahead);
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
                    timeLabel: _formatTime(ev),
                    pastAfter: _pastAfterFor(ev, d),
                    eventYear: d.getFullYear(),
                    eventMonth: d.getMonth() + 1,
                    eventDay: d.getDate()
                });
            }

            if (dayEntries.length === 0) continue;

            var wk = _weekKey(d);
            if (addedAnyDay && wk !== previousWeekKey) {
                eventsModel.append({ kind: "divider", title: "", pillColor: "", timeLabel: "", isAllDay: false, pastAfter: 0, eventYear: 0, eventMonth: 0, eventDay: 0 });
            }

            eventsModel.append({
                kind: "header",
                title: _dateHeader(d, todayStart),
                pillColor: "",
                timeLabel: "",
                isAllDay: false,
                pastAfter: 0,
                eventYear: 0,
                eventMonth: 0,
                eventDay: 0
            });

            for (var di = 0; di < dayEntries.length; di++) eventsModel.append(dayEntries[di]);

            previousWeekKey = wk;
            addedAnyDay = true;
        }

    }

    // --- Open event day in KOrganizer ---
    // Plasma's EventDataDecorator currently does not expose the source event UID,
    // so a card click cannot yet open the exact incidence. As a safe fallback we
    // ask KOrganizer to show the event's day, then use KWin's own Windows Runner
    // to activate its window. All command parameters are generated/validated here;
    // no event text is ever interpolated into a shell command.
    readonly property string _korganizerMatchCommand: "busctl --user --json=short call org.kde.KWin /WindowsRunner org.kde.krunner1 Match s korganizer"
    readonly property string _korganizerShowCommand: "korganizer"
    property string _eventOpenShowDateCommand: ""
    property string _eventOpenRunCommand: ""
    property int _eventOpenMatchAttempts: 0
    property bool _eventOpenInProgress: false

    Plasma5Support.DataSource {
        id: eventOpenRunner
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            disconnectSource(source);
            root._handleEventOpenCommand(source, data);
        }
    }

    Timer {
        id: eventOpenMatchTimer
        interval: 180
        repeat: false
        onTriggered: eventOpenRunner.connectSource(root._korganizerMatchCommand)
    }

    function openEventDay(year, month, day) {
        if (_eventOpenInProgress) return;

        year = Number(year);
        month = Number(month);
        day = Number(day);
        if (!Number.isInteger(year) || !Number.isInteger(month) || !Number.isInteger(day)) return;
        if (year < 1970 || year > 9999 || month < 1 || month > 12 || day < 1 || day > 31) return;

        _eventOpenInProgress = true;
        _eventOpenMatchAttempts = 0;
        _eventOpenRunCommand = "";
        _eventOpenShowDateCommand = "busctl --user call org.kde.korganizer /Calendar org.kde.Korganizer.Calendar showDate '(iii)' "
                                  + year + " " + month + " " + day;
        eventOpenRunner.connectSource(_eventOpenShowDateCommand);
    }

    function _findKOrganizerMatchId(value) {
        if (typeof value === "string") {
            // KWin's Windows Runner currently returns IDs shaped like <index>_{UUID}.
            // Validate strictly before ever putting the value into a command.
            return /^[0-9]+_\{[0-9A-Fa-f-]{36}\}$/.test(value) ? value : "";
        }
        if (Array.isArray(value)) {
            for (var i = 0; i < value.length; ++i) {
                var arrayResult = _findKOrganizerMatchId(value[i]);
                if (arrayResult.length > 0) return arrayResult;
            }
            return "";
        }
        if (value !== null && typeof value === "object") {
            for (var key in value) {
                var objectResult = _findKOrganizerMatchId(value[key]);
                if (objectResult.length > 0) return objectResult;
            }
        }
        return "";
    }

    function _requestKOrganizerWindowMatch() {
        _eventOpenMatchAttempts += 1;
        eventOpenMatchTimer.restart();
    }

    function _handleEventOpenCommand(source, data) {
        var exitCode = data["exit code"];
        var stdout = data["stdout"] ? data["stdout"].toString() : "";

        if (source === _eventOpenShowDateCommand) {
            if (exitCode === 0) {
                // On some distributions (notably Kubuntu 26.04), D-Bus activation
                // starts KOrganizer and applies the date without materializing its
                // main window. Launching the application once asks the existing
                // single-instance process to show its window; KWin then handles
                // foreground activation in the next step.
                eventOpenRunner.connectSource(_korganizerShowCommand);
            } else {
                _eventOpenInProgress = false;
            }
            return;
        }

        if (source === _korganizerShowCommand) {
            if (exitCode === 0) {
                _requestKOrganizerWindowMatch();
            } else {
                _eventOpenInProgress = false;
            }
            return;
        }

        if (source === _korganizerMatchCommand) {
            var matchId = "";
            if (exitCode === 0 && stdout.length > 0) {
                try {
                    matchId = _findKOrganizerMatchId(JSON.parse(stdout));
                } catch (e) {
                    matchId = "";
                }
            }

            if (matchId.length > 0) {
                _eventOpenRunCommand = "busctl --user call org.kde.KWin /WindowsRunner org.kde.krunner1 Run ss '" + matchId + "' ''";
                eventOpenRunner.connectSource(_eventOpenRunCommand);
            } else if (_eventOpenMatchAttempts < 4) {
                _requestKOrganizerWindowMatch();
            } else {
                _eventOpenInProgress = false;
            }
            return;
        }

        if (source === _eventOpenRunCommand) {
            _eventOpenRunCommand = "";
            _eventOpenInProgress = false;
        }
    }

    // --- Google/Akonadi synchronization ---
    // We deliberately do not touch PimCalendarsModel or calendar selection.
    // Instead, we ask every Akonadi Google resource to synchronize through
    // its public D-Bus interface. Use busctl here as well as for the KOrganizer
    // click integration, avoiding distribution-specific qdbus executable names.
    // JSON output keeps the resource list machine-readable across distributions.
    readonly property string _resourceListCommand: "busctl --user --json=short call org.freedesktop.Akonadi /ResourceManager org.freedesktop.Akonadi.ResourceManager resourceInstances"
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
            try {
                _collectGoogleResources(JSON.parse(stdout), resources);
            } catch (e) {
                lastRemoteSyncFailed = true;
                _finishRemoteSync();
                return;
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


    function _collectGoogleResources(value, output) {
        if (typeof value === "string") {
            // Keep command construction safe and restrict it to Akonadi's
            // Google resource naming convention.
            if (/^akonadi_google_resource_[A-Za-z0-9_]+$/.test(value)
                    && output.indexOf(value) === -1)
                output.push(value);
            return;
        }
        if (Array.isArray(value)) {
            for (var i = 0; i < value.length; ++i)
                _collectGoogleResources(value[i], output);
            return;
        }
        if (value !== null && typeof value === "object") {
            for (var key in value)
                _collectGoogleResources(value[key], output);
        }
    }

    function _syncNextGoogleResource() {
        if (_syncQueue.length === 0) {
            _finishRemoteSync();
            return;
        }

        var resource = _syncQueue.shift();
        _currentSyncCommand = "busctl --user --quiet call org.freedesktop.Akonadi.Resource." + resource
                            + " / org.freedesktop.Akonadi.Resource synchronize";
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

    // Give the desktop session and Akonadi time to finish starting before the
    // first automatic Google sync. Triggering it immediately during Plasma
    // startup can race Akonadi resource activation on some distributions.
    Timer {
        id: initialRemoteSyncTimer
        interval: 20 * 1000
        repeat: false
        onTriggered: {
            if (plasmoid.configuration.autoSyncGoogle) root.requestRemoteSync();
        }
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
        // Initial desktop size: use Kirigami grid units so the preferred
        // geometry follows Plasma/font scaling instead of hard-coded pixels.
        // Minimum sizes remain deliberately permissive for manual resizing.
        Layout.preferredWidth: Kirigami.Units.gridUnit * 22
        Layout.preferredHeight: Kirigami.Units.gridUnit * 26
        Layout.minimumWidth: 220
        Layout.minimumHeight: 150

        readonly property real marginSize: Math.max(12, Math.min(22, Math.round(width * 0.050)))
        readonly property real labelSize: Math.max(10, Math.min(15, Math.round(width * 0.040)))
        readonly property real titleSize: Math.max(labelSize + 1, Math.round(labelSize * 1.14))
        readonly property real baseCardSize: Math.max(10, Math.min(15, Math.round(width * 0.039)))
        readonly property real eventTextScale: plasmoid.configuration.eventTextSize === 0 ? 0.88
                                             : plasmoid.configuration.eventTextSize === 2 ? 1.15
                                             : 1.0
        readonly property real cardSize: baseCardSize * eventTextScale
        readonly property real densityScale: plasmoid.configuration.densityMode === 0 ? 0.82
                                           : plasmoid.configuration.densityMode === 2 ? 1.25
                                           : 1.0
        readonly property real baseCardSpacing: Math.max(5, Math.round(labelSize * 0.50))
        readonly property real cardSpacing: Math.max(3, Math.round(baseCardSpacing * densityScale))

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

        // Compact header: the widget title and manual refresh action share a
        // dedicated row, separated from the agenda by a subtle divider.
        Item {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Math.max(6, full.marginSize * 0.45)
            anchors.leftMargin: full.marginSize
            anchors.rightMargin: full.marginSize
            height: Math.max(refreshIcon.height + Math.round(full.labelSize * 0.9),
                             Math.round(full.titleSize * 2.15))

            Kirigami.Icon {
                id: titleIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -Math.round(separator.height / 2)
                width: Math.max(18, Math.round(full.titleSize * 1.15))
                height: width
                source: plasmoid.icon
                isMask: true
                color: colors.foreground
                opacity: 0.82
            }

            Text {
                id: widgetTitle
                anchors.left: titleIcon.right
                anchors.leftMargin: Kirigami.Units.smallSpacing
                anchors.right: refreshButton.left
                anchors.rightMargin: Kirigami.Units.smallSpacing
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -Math.round(separator.height / 2)
                text: "Simple Agenda"
                color: colors.foreground
                font.pixelSize: full.titleSize
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            PlasmaCore.ToolTipArea {
                anchors.left: parent.left
                anchors.right: refreshButton.left
                anchors.top: parent.top
                anchors.bottom: separator.top
                mainText: i18nd(root.trDomain, "Click an event to open its day in KOrganizer")
            }

            // Manual refresh: request a real Google -> Akonadi synchronization.
            // It does not change PIM calendar selection.
            Item {
                id: refreshButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -Math.round(separator.height / 2)
                width: refreshIcon.width + 12
                height: refreshIcon.height + 12
                enabled: !root.remoteSyncInProgress
                activeFocusOnTab: enabled

                Accessible.role: Accessible.Button
                Accessible.name: i18nd(root.trDomain, "Synchronize Google calendars")
                Accessible.focusable: enabled
                Accessible.focused: activeFocus
                Accessible.onPressAction: {
                    if (refreshButton.enabled) root.requestRemoteSync();
                }

                Keys.onPressed: function(event) {
                    if (refreshButton.enabled
                            && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)) {
                        root.requestRemoteSync();
                        event.accepted = true;
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Math.round(Math.min(width, height) * 0.25)
                    color: "transparent"
                    border.width: refreshButton.activeFocus ? 1 : 0
                    border.color: Kirigami.Theme.highlightColor
                    opacity: 0.72
                }

                Kirigami.Icon {
                    id: refreshIcon
                    anchors.centerIn: parent
                    width: Math.max(16, full.labelSize * 1.35)
                    height: width
                    source: "view-refresh"
                    isMask: true
                    color: colors.foreground
                    opacity: root.lastRemoteSyncFailed ? 0.80 : (refreshMouse.containsMouse ? 0.95 : 0.42)

                    RotationAnimator {
                        target: refreshIcon
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                        running: root.remoteSyncInProgress
                    }
                }

                PlasmaCore.ToolTipArea {
                    anchors.fill: parent
                    mainText: i18nd(root.trDomain, "Synchronize Google calendars")

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: refreshButton.enabled
                        onClicked: root.requestRemoteSync()
                    }
                }
            }

            Rectangle {
                id: separator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: colors.separator
                opacity: 0.16
            }
        }

        Item {
            id: agendaArea
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: Math.max(6, Math.round(full.cardSpacing * 0.9))
            anchors.leftMargin: full.marginSize
            anchors.rightMargin: full.marginSize
            anchors.bottomMargin: full.marginSize

            Text {
                anchors.centerIn: parent
                visible: eventsModel.count === 0
                text: root._emptyAgendaText()
                color: colors.foreground
                font.pixelSize: full.labelSize
                font.weight: Font.Normal
                opacity: 0.55
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: Math.max(0, parent.width)
            }

            ListView {
                id: eventsList
                anchors.fill: parent
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
                                item.cardPastAfter = model.pastAfter;
                                item.cardEventYear = model.eventYear;
                                item.cardEventMonth = model.eventMonth;
                                item.cardEventDay = model.eventDay;
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: sectionHeaderComponent
            Text {
                property string headerTitle: ""
                text: headerTitle
                color: Kirigami.Theme.highlightColor
                font.pixelSize: full.labelSize
                font.weight: Font.DemiBold
                opacity: 0.90
                font.letterSpacing: 0.35
                height: Math.round(font.pixelSize * 1.55 * full.densityScale)
                verticalAlignment: Text.AlignVCenter
            }
        }

        Component {
            id: weekDividerComponent
            Item {
                height: Math.round(Math.max(12, full.baseCardSpacing * 2) * full.densityScale)
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
                property real cardPastAfter: 0
                property int cardEventYear: 0
                property int cardEventMonth: 0
                property int cardEventDay: 0

                width: parent ? parent.width : 0
                title: cardTitle
                timeLabel: cardTime
                pillColor: cardPill
                textColor: colors.foreground
                fontSize: full.cardSize
                densityScale: full.densityScale
                cardBg: colors.cardBackground
                cardBgOpacity: colors.cardBackgroundOpacity
                pastAfter: cardPastAfter
                nowTimestamp: root.currentTimeMs
                focusColor: Kirigami.Theme.highlightColor
                accessibleDescription: i18nd(root.trDomain, "Click an event to open its day in KOrganizer")
                onActivated: root.openEventDay(cardEventYear, cardEventMonth, cardEventDay)
            }
        }
    }
}
