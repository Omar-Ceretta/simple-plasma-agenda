# Simple Plasma Agenda

Simple Plasma Agenda is a compact **KDE Plasma 6** desktop widget that shows upcoming calendar events provided by **KDE PIM / Akonadi**.

It is intentionally an agenda, not a full calendar: the monthly calendar view from the upstream project has been removed so the widget can stay permanently visible on the desktop and show only the next appointments.

> **Development status**
>
> Current local development version: **0.2.21**.  
> The widget has been tested on **Fedora KDE 44 / Plasma 6**, **Kubuntu 26.04 LTS / Plasma 6.6.4**, **Arch Linux + KDE Plasma**, and **openSUSE Tumbleweed / Plasma 6.7.4**. Distribution-specific PASS results below refer to the versions actually tested; 0.2.21 refines the initial desktop geometry and title tooltip and is the next VM-test build.

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
- Manual Google Calendar refresh and optional forced refresh every 5 minutes through Akonadi D-Bus, using `busctl` instead of distribution-specific Qt D-Bus command names. The first automatic refresh is delayed briefly after Plasma startup so Akonadi can finish initializing.
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
- **systemd / `busctl`** is **not required for the core event display**, but Simple Plasma Agenda currently uses `busctl --user` for two convenience features: forced Google-resource synchronization and click/keyboard activation of KOrganizer. The tested and planned target distributions are systemd-based; systems without `busctl` can still display Akonadi events but those two actions will not work.
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

and requests synchronization through the resource's public D-Bus interface. The desktop refresh button does this immediately. When automatic synchronization is enabled, the first forced Google sync is delayed by **20 seconds after the plasmoid starts**, then repeats every 5 minutes. The startup delay was added in 0.2.19 after VM testing showed that forcing a sync too early could race Akonadi session startup on Kubuntu 26.04.

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

This removes the previous `qdbus-qt6` / `qdbus6` command-name difference between distributions. Fedora KDE 44, Kubuntu 26.04 LTS, Arch Linux and openSUSE Tumbleweed have now been tested with the `busctl` path.

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

# Distribution notes and test status

Fedora KDE 44, Kubuntu 26.04 LTS, Arch Linux and openSUSE Tumbleweed have been tested during development. Commands for the other distributions remain **starting points for planned VM testing**, not compatibility claims.

## Kubuntu 26.04 LTS — tested

The tested Kubuntu VM used **Ubuntu 26.04 LTS (Resolute Raccoon)** with **Plasma 6.6.4**, KOrganizer 6.6.3 / KDE PIM 25.12.3. The relevant PIM packages are:

```bash
sudo apt install akonadi-server kdepim-runtime kdepim-addons korganizer
```

No Qt-specific `qdbus` package is required: the optional D-Bus actions use `busctl` from the systemd userspace. On the tested Kubuntu installation, `pimevents.so` was available at `/usr/lib/x86_64-linux-gnu/qt6/plugins/plasmacalendarplugins/pimevents.so`.

Kubuntu did **not** provide an `akonadi_control.service` systemd user unit in this test; use `akonadictl status/start/stop/restart` for Akonadi itself rather than assuming that unit exists on every distribution.

Version 0.2.19 passed a logout/login test with automatic Google synchronization enabled after the initial forced sync was delayed to 20 seconds. Event display in Plasma's Digital Clock, event display in Simple Plasma Agenda, manual/automatic Google refresh and click-to-KOrganizer were verified during the Kubuntu test cycle.

TUXEDO OS and KDE neon are still separate, untested environments even though they use APT-family packaging.

## Arch Linux — tested

The Arch Linux VM passed the 0.2.19 test cycle with the distribution's current KDE PIM packages at the time of testing, including `kdepim-runtime 26.08.0-1` and `korganizer 26.08.0-1`. Relevant package names are:

```bash
sudo pacman -S akonadi kdepim-runtime kdepim-addons korganizer
```

Verified on the VM: Google Calendar through Akonadi, events in KOrganizer, Plasma's Digital Clock and Simple Plasma Agenda, manual and automatic Google synchronization, event click opening the correct day in KOrganizer, hover and basic keyboard/accessibility behavior, appearance configuration, and logout/login with automatic synchronization enabled. After the delayed first automatic sync, `akonadictl status` remained `Control: running` / `Server: running`.

During the initial Google-account setup, before Simple Plasma Agenda had been added to the desktop, the VM hit an upstream `ksecretd --pam-login` crash in the QCA/OpenSSL path. The affected session used `kwallet 6.29.0-1`, `qca-qt6 2.3.10-8` and `openssl 3.6.3-1`. Reinitializing the KWallet/Secret Service processes in the current session and authenticating the Google resource again restored normal operation. This was treated as an Arch/KDE wallet issue, not a plasmoid defect; see `TESTING.md` for the recorded diagnosis.

## openSUSE Tumbleweed — tested

The openSUSE Tumbleweed VM passed the 0.2.19 test cycle on **Plasma 6.7.4**. Relevant packages installed successfully with `zypper`, and Plasma's PIM calendar plugin was present at:

```text
/usr/lib64/qt6/plugins/plasmacalendarplugins/pimevents.so
```

Verified on the VM: Google Calendar through Akonadi; events in KOrganizer, Plasma's Digital Clock and Simple Plasma Agenda; manual and automatic Google synchronization; event click opening the correct day in KOrganizer; interaction/configuration checks; and logout/login with automatic synchronization enabled. After login, `akonadictl status` remained `Control: running` / `Server: running`. The tested Google resource reported `status = 0`, `online = true`, and `statusMessage = "Pronto"`.

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
