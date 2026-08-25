# Simple Plasma Agenda — Testing

This document records **tests that were actually performed**. Planned environments and expected compatibility are kept separate so that repository documentation does not overstate support.

Current local development version: **0.2.19**.

## Tested environments

### Fedora KDE 44 / Plasma 6 — PASS

Primary development environment.

Verified during development:

- plasmoid installation and loading;
- KDE PIM / Akonadi event display through Plasma `pimevents`;
- Google Calendar resource through Akonadi;
- Italian localization, including `OGGI`, `DOMANI` and localized dates;
- week separators;
- solid and translucent backgrounds;
- follow-system, light and dark color modes;
- compact / normal / airy density presets;
- small / normal / large event text sizes;
- accent-colored day headers;
- past-event dimming after the actual event end time;
- hover state;
- keyboard focus and Enter/Space activation;
- manual Google synchronization;
- automatic Google synchronization every 5 minutes;
- event click opening the corresponding day in KOrganizer and bringing KOrganizer forward;
- simultaneous update of Simple Plasma Agenda and Plasma's Digital Clock when Akonadi calendar data changes.

The Fedora development system also provided `akonadi_control.service` as a systemd user unit. This is **distribution-specific** and must not be assumed elsewhere.

### Kubuntu 26.04 LTS / Plasma 6.6.4 — PASS on 0.2.19

Test VM details recorded during the test cycle:

- base: Ubuntu 26.04 LTS (Resolute Raccoon), Kubuntu desktop;
- Plasma: 6.6.4;
- KOrganizer: 6.6.3 (25.12.3);
- KDE PIM / Akonadi packages observed at 25.12.3;
- `busctl`: `/usr/bin/busctl`;
- Plasma PIM plugin: `/usr/lib/x86_64-linux-gnu/qt6/plugins/plasmacalendarplugins/pimevents.so`;
- Google Akonadi resource tested: `akonadi_google_resource_0`.

Verified:

- Akonadi calendar events visible in KOrganizer;
- the same events visible in Plasma's Digital Clock;
- the same events visible in Simple Plasma Agenda;
- Italian UI/localization;
- manual Google refresh through `busctl`;
- automatic Google refresh enabled;
- event click opens the correct day in KOrganizer and brings the application forward;
- clean reboot with Akonadi returning `Control: running` / `Server: running`;
- logout/login with Simple Plasma Agenda installed and automatic Google sync enabled;
- events remain available after that logout/login on 0.2.19.

#### Kubuntu startup-race finding — resolved in 0.2.19

During testing of 0.2.18, the plasmoid's first forced Google sync ran only **1.5 seconds** after the plasmoid loaded. On Kubuntu this could race Akonadi startup after logout/login. The observed failure state was:

```text
Akonadi Control: stopped
Akonadi Server: running
```

The journal also showed Akonadi resources repeatedly failing to register D-Bus service names that were already present, followed by crashes/restart exhaustion for resources such as Personal Contacts and Local Folders. Plasma's Digital Clock and Simple Plasma Agenda both lost calendar events because the shared Akonadi/PIM backend was unhealthy.

A/B tests isolated the trigger:

- Simple Plasma Agenda removed: logout/login succeeded;
- Simple Plasma Agenda present but automatic Google sync disabled: logout/login succeeded;
- automatic Google sync re-enabled with the first forced sync delayed to **20 seconds**: logout/login succeeded.

Version **0.2.19** therefore delays only the **first** automatic Google sync to 20 seconds after plasmoid startup. Manual refresh remains immediate, and subsequent automatic refreshes remain every 5 minutes. No Akonadi restart workaround is required by the widget.

This is recorded as a **resolved development issue**, not as a current Kubuntu limitation.

#### KWallet note from the VM

The Kubuntu VM used SDDM automatic login. A password-protected KWallet therefore requested its password after reboot because the graphical login did not supply a user password that PAM could use to unlock the wallet automatically. This was treated as desktop/session configuration, not a Simple Plasma Agenda defect.

The tested Kubuntu installation did not expose `akonadi_control.service` as a systemd user unit. Akonadi itself was managed and inspected with `akonadictl`.

## Known project limitations relevant to testing

- Calendar source selection is intentionally **not** implemented inside the plasmoid. Saving PIM calendar selections through Plasma's PIM model was found to crash `plasmashell`; source administration remains in Akonadi/KOrganizer.
- Event activation currently opens **the event's day** in KOrganizer, not the individual incidence editor, because the Plasma calendar QML event wrapper does not expose the original Akonadi incidence UID.
- Forced remote synchronization is intentionally limited to `akonadi_google_resource_*`. Do not generalize it to arbitrary Akonadi resources, which may represent mail, contacts or other data.

## Planned VM tests

These environments are **not yet recorded as passed**:

- Arch Linux + KDE Plasma — next planned test;
- openSUSE Tumbleweed KDE;
- TUXEDO OS (record the exact Debian/Ubuntu base used);
- KDE neon;
- an additional fresh Fedora KDE installation if useful before public release.

For each new VM, record at minimum:

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

Then verify calendar data first in KOrganizer and Plasma's Digital Clock before diagnosing the plasmoid itself.
