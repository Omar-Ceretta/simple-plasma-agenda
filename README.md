# Simple Plasma Agenda

Simple Plasma Agenda is a compact **KDE Plasma 6** desktop widget that shows upcoming calendar events provided by **KDE PIM / Akonadi**.

It is intentionally an agenda, not a full calendar: the monthly calendar view from the upstream project has been removed so the widget can stay permanently visible on the desktop and show only the next appointments.

> **Development status**
>
> Current local development version: **0.2.17**.  
> The widget has been tested so far on **Fedora KDE 44 / Plasma 6**. Package-name notes for other distributions are provided below as installation guidance only; they must not yet be read as a claim of tested support.

## Main features

- Upcoming KDE PIM / Akonadi events directly on the Plasma desktop.
- Look-ahead periods: **1, 3, 5 or 7 days; 2 weeks (14 days); 3 weeks (21 days); 4 weeks (28 days)**.
- Day sections for **Today**, **Tomorrow** and subsequent localized dates.
- Week separators.
- Solid or translucent background.
- Follow-system, light or dark color mode.
- Compact, normal and airy density presets.
- Small, normal and large event text sizes.
- Past events are visually dimmed after their actual end time.
- Event cards have a subtle hover state and visible keyboard focus.
- Event cards are reachable with **Tab / Shift+Tab** and activate with **Enter or Space**; accessibility metadata exposes them as buttons.
- Clicking or keyboard-activating an event opens **KOrganizer on the day containing that event** and brings KOrganizer to the foreground.
- Manual Google Calendar refresh and optional forced refresh every 5 minutes through Akonadi D-Bus, using `busctl` instead of distribution-specific Qt D-Bus command names.
- Italian localization.

## How calendar data reaches the widget

Simple Plasma Agenda does **not** connect directly to Google Calendar, Nextcloud or another online service.

The data path is:

```text
Google / CalDAV / Nextcloud / iCalendar / local calendar
                         ↓
                Akonadi resource
                         ↓
                  Akonadi server
                         ↓
            KDE PIM `pimevents` plugin
                         ↓
              Simple Plasma Agenda
```

KDE describes **KDE PIM** as the family of libraries and applications for personal information such as mail, contacts and calendars, and **Akonadi** as the storage/service framework at the centre of that stack. Akonadi gives applications one common way to access PIM data regardless of whether the original calendar comes from Google, a DAV server, an `.ics` file or another supported resource.

This distinction matters: if an event is not available through Akonadi and the Plasma `pimevents` plugin, Simple Plasma Agenda cannot display it.

## What is actually required?

For the **core agenda display**, you need:

1. **KDE Plasma 6**;
2. **Akonadi** running for the current user;
3. the Akonadi calendar resource(s) needed for your provider — Google, DAV/Nextcloud, iCalendar, local calendar, etc.;
4. the Plasma **`pimevents`** calendar plugin, provided by `kdepim-addons` on Fedora;
5. at least one calendar resource configured and synchronized.

The following components are useful but have more specific roles:

- **KOrganizer** is **not required merely to display events**. It is a full calendar application and is the easiest tested GUI for adding/checking Akonadi calendar resources. Simple Plasma Agenda also currently uses KOrganizer for the **click an event → open that day** feature. If KOrganizer is absent, the agenda can still display events, but that click action cannot open the calendar application.
- **systemd / `busctl`** is **not required for the core event display**, but Simple Plasma Agenda currently uses `busctl --user` for two convenience features: forced Google-resource synchronization and click/keyboard activation of KOrganizer. The planned test distributions are systemd-based; systems without `busctl` can still display Akonadi events but those two actions will not work.
- **systemd** is not a calendar backend. On Fedora it also manages the per-user Akonadi control service. There is normally no reason to enable Akonadi as a permanent system-wide root service.

## Multiple calendars and providers

Simple Plasma Agenda does not care whether an event originally came from Google, CalDAV/Nextcloud, an iCalendar file or another Akonadi-supported calendar source. The `pimevents` plugin works with Akonadi calendar collections, so **multiple calendar resources can coexist and their events can appear together in the agenda**.

For example, one Akonadi setup may contain at the same time:

- two Google calendars;
- a Nextcloud/CalDAV calendar;
- a local or imported iCalendar calendar.

Simple Plasma Agenda does **not** implement its own provider filter and deliberately does not offer calendar-selection checkboxes. Calendar/resource administration remains outside the widget.

Akonadi normally starts automatically when an Akonadi-aware application or component requests it; `akonadictl` can also be used to start, stop, restart and inspect it manually.

---

# Minimum setup — Fedora KDE 44

This is the setup currently tested during development.

## 1. Install the KDE PIM/Akonadi components

For the **core agenda display** on the tested Fedora KDE 44 setup:

```bash
sudo dnf install akonadi-server kdepim-runtime kdepim-addons
```

These provide the pieces that matter to the widget:

- `akonadi-server` — the Akonadi service and `akonadictl`;
- `kdepim-runtime` — Akonadi resources, including Google and DAV resources on Fedora;
- `kdepim-addons` — contains the Plasma `pimevents` plugin used by Simple Plasma Agenda.

For the complete currently tested experience, also install:

```bash
sudo dnf install korganizer
```

- `korganizer` — recommended GUI for configuring/verifying calendars and required by the current **click event → open its day** action.

`busctl` is provided by Fedora's normal systemd installation and is used for the click action and forced Google synchronization. No Qt-specific `qdbus` package is required by Simple Plasma Agenda anymore.

The core agenda display does **not** require a Google account, KOrganizer or `busctl`; it requires calendar events to be available through Akonadi + `pimevents`.

## 2. Check that Akonadi can run

```bash
akonadictl status
```

If it is not running:

```bash
akonadictl start
```

Akonadi is normally activated automatically when an Akonadi-aware application requests it, so there is generally no need to enable a service manually at every login.

On Fedora 44, `akonadi-server` also installs the systemd **user** unit:

```text
akonadi_control.service
```

If Akonadi does not start, inspect it with:

```bash
systemctl --user status akonadi_control.service
```

If you had previously disabled Akonadi by **masking** that unit, undo the mask first:

```bash
systemctl --user unmask akonadi_control.service
akonadictl start
```

Do not run Akonadi as root.

## 3. Add at least one calendar to Akonadi

The simplest **tested** route is KOrganizer. Other Akonadi-aware calendar applications, such as Merkuro Calendar, can also manage Akonadi-backed calendars; Simple Plasma Agenda only needs the resulting calendar data to be present in Akonadi.

Open **KOrganizer** and go to:

```text
Settings → Configure KOrganizer… → General → Calendars → Add…
```

Alternatively, in KOrganizer's Calendar Manager sidebar, use **Add Calendar…**.

KOrganizer can expose several Akonadi resource types, including for example:

- **Google Calendars and Tasks**;
- **DAV groupware resource** for CalDAV / Nextcloud;
- **iCal Calendar File**;
- other Akonadi-supported resources.

KDE's current KOrganizer documentation describes the resource setup here:

- https://docs.kde.org/stable_kf6/en/korganizer/korganizer/managing-data.html

Complete any account authentication requested by the selected resource.

## 4. Verify Akonadi before installing the widget

Before troubleshooting Simple Plasma Agenda, verify the calendar data in an Akonadi-aware client. If you installed **KOrganizer**, make sure the events are visible there. Merkuro Calendar can serve the same basic verification role when it is using the same Akonadi resources.

A particularly useful check is Plasma's **Digital Clock** calendar with the PIM Events plugin enabled. Both it and Simple Plasma Agenda consume the same Akonadi/PIM calendar path; if neither can see the events, solve the Akonadi/resource configuration first.

## 5. Install Simple Plasma Agenda locally

Plasma installs per-user widgets under:

```text
~/.local/share/plasma/plasmoids/
```

After extracting the release ZIP, the final structure must be exactly:

```text
~/.local/share/plasma/plasmoids/
└── com.simple.plasma.agenda/
    ├── metadata.json
    └── contents/
        ├── config/
        ├── locale/
        └── ui/
```

For a manual installation from an extracted release directory:

```bash
mkdir -p ~/.local/share/plasma/plasmoids
rm -rf ~/.local/share/plasma/plasmoids/com.simple.plasma.agenda
cp -a com.simple.plasma.agenda ~/.local/share/plasma/plasmoids/
```

Then open Plasma's **Add Widgets…** interface and drag **Simple Plasma Agenda** onto the desktop.

KDE documents the per-user plasmoid location here:

- https://develop.kde.org/docs/plasma/widget/setup/

---

# Google Calendar synchronization

Normal event display still goes through Akonadi. The widget does not implement its own Google API client.

In addition, Simple Plasma Agenda detects Akonadi resources named like:

```text
akonadi_google_resource_*
```

and requests an immediate synchronization through the resource's public D-Bus interface. The desktop refresh button does this manually; the corresponding option can repeat it every 5 minutes.

Starting with development version **0.2.17**, this path uses **`busctl --user`** rather than a Qt-specific `qdbus` executable. The resource list is requested as lossless JSON and parsed inside QML; only resource names matching Akonadi's Google-resource naming convention are accepted.

Conceptually, the two D-Bus calls are equivalent to:

```bash
busctl --user --json=short call \
  org.freedesktop.Akonadi \
  /ResourceManager \
  org.freedesktop.Akonadi.ResourceManager \
  resourceInstances

busctl --user --quiet call \
  org.freedesktop.Akonadi.Resource.akonadi_google_resource_0 \
  / \
  org.freedesktop.Akonadi.Resource \
  synchronize
```

This removes the previous `qdbus-qt6` / `qdbus6` command-name difference between distributions. The planned VM distributions — Fedora, Kubuntu/Ubuntu-family systems, Arch Linux and openSUSE Tumbleweed — are systemd-based and normally provide `busctl` as part of systemd. This still needs real VM testing before being called supported.

The widget deliberately does **not** force synchronization of arbitrary Akonadi resources, because Akonadi may also contain mail, contacts and other agents. Only Google resources matching `akonadi_google_resource_*` are targeted. Other calendar sources remain visible through Akonadi and use their own synchronization mechanisms.

---

# Clicking an event

A click currently performs this safe fallback:

```text
click event
   ↓
KOrganizer opens the event's day
   ↓
KWin brings KOrganizer to the foreground
```

It does **not yet open the individual event editor**.

The current Plasma calendar QML wrapper does not expose the source event UID even though the underlying KDE calendar event data contains it. Until that is exposed upstream, opening the correct day is used instead of guessing an event by title/time or reading Akonadi's database directly.

This feature currently relies on:

- KOrganizer's D-Bus calendar interface;
- `busctl --user` from systemd;
- KWin's Windows Runner, available in the Plasma desktop session.

If these components are unavailable, the agenda itself can still display events; only the click action will fail to open KOrganizer.

---

# Other distributions — package guidance, not yet tested support

These commands are **starting points for planned VM testing**, not a compatibility claim.

## Kubuntu / Ubuntu-family Plasma systems

For current Ubuntu package naming, the relevant PIM packages are:

```bash
sudo apt install akonadi-server kdepim-runtime kdepim-addons korganizer
```

No Qt-specific `qdbus` package is required by Simple Plasma Agenda 0.2.17: the optional D-Bus actions use `busctl` from the systemd userspace already present on normal Kubuntu/Ubuntu-family installations.

TUXEDO OS and KDE neon are Ubuntu-family systems, but their exact preinstalled PIM components and versions still need real VM tests before being documented as supported.

## Arch Linux

Relevant package names are currently:

```bash
sudo pacman -S akonadi kdepim-runtime kdepim-addons korganizer
```

Arch uses systemd and therefore already provides the `busctl` path used by Simple Plasma Agenda 0.2.17. The previous `qdbus6` versus `qdbus-qt6` portability issue no longer applies; the Akonadi/PIM integration itself still needs real VM testing.

## openSUSE Tumbleweed

The current Tumbleweed package names to start from are `akonadi`, `kdepim-runtime`, `kdepim-addons` and `korganizer`. Tumbleweed is systemd-based, so the widget's D-Bus helper is expected to be `busctl` there as well. Exact installation behaviour and the presence/location of the Plasma `pimevents` plugin still need a real Tumbleweed test.

## VM pre-flight checks

Before diagnosing the widget itself on a new distribution, record these results:

```bash
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

Then verify that at least one calendar event is visible in an Akonadi-aware calendar application and, where available, in Plasma's Digital Clock calendar. This separates packaging/Akonadi problems from plasmoid problems before testing Simple Plasma Agenda.

---

# Troubleshooting

## The widget loads but shows no events

Check in this order:

1. Does `akonadictl status` report a working Akonadi instance?
2. Do the events appear in KOrganizer?
3. Is `kdepim-addons` installed, including the Plasma `pimevents` plugin?
4. Does Plasma's Digital Clock see the same events when event display is enabled?
5. Only after those checks, investigate the widget itself.

## Plasma appears to use an older QML version

During development or after replacing files manually, Plasma may retain compiled QML from an older version.

Use this only when the installed files and the observed behaviour clearly disagree:

```bash
rm -rf ~/.cache/plasmashell/qmlcache
systemctl --user restart plasma-plasmashell.service
```

A restart is especially worth trying after changes to configuration keys, translations or theme-related QML. It should not be necessary for every ordinary update.

## Calendar selection

Simple Plasma Agenda intentionally does **not** provide checkboxes to enable/disable individual PIM calendars.

During development, saving calendar selections from Plasma's PIM calendar model was found to be able to crash `plasmashell`; the same failure was reproducible in the upstream widget. Calendar/resource administration is therefore left to KOrganizer/Akonadi rather than duplicated inside this widget.

---

# Current configuration

The widget currently provides:

- first day of week: Sunday / Monday;
- look-ahead: 1 / 3 / 5 / 7 days; 2 weeks (14 days); 3 weeks (21 days); 4 weeks (28 days);
- Google forced synchronization every 5 minutes: on/off;
- background: solid / translucent;
- colors: follow system / light / dark;
- density: compact / normal / airy;
- event text size: small / normal / large;
- corner radius.

The default look-ahead is **7 days**, the default first day is **Monday**, and the default corner radius is **16 px**.

---

# Project origin

Simple Plasma Agenda is a fork/derivative of **macOS Calendar 1.1** by **Jack Faith (`jaxparrow07`)**. The original project provided a monthly calendar, agenda and Plasma/KDE PIM integration; this fork focuses on a compact always-visible agenda panel.

The upstream author is credited as the author of the project from which this work derives, not as a maintainer or co-author of Simple Plasma Agenda.

Simple Plasma Agenda is maintained by **Omar Ceretta** and is licensed under **GPL-3.0**.

Development is **human-directed, AI-assisted**: requirements, acceptance decisions and real-system testing are performed by the maintainer; ChatGPT is used to assist with source analysis, QML changes, debugging, documentation and test planning.
