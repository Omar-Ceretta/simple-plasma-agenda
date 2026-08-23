# Simple Plasma Agenda

A compact **agenda-only widget for KDE Plasma 6**. It keeps upcoming events visible directly on the desktop instead of hiding them behind a click on the Digital Clock.

> **Project status:** early development (`0.2.x`). The core agenda and Google/Akonadi synchronization are already usable, but the visual configuration and cross-distribution testing are still being expanded.

## Why this fork exists

Simple Plasma Agenda began as a derivative of the **Calendar** widget from Jack Faith's macOS/Liquid Glass widgets. The upstream widget combines a month calendar with an optional upcoming-events panel. This fork focuses exclusively on the agenda panel and reshapes it around a Plasma-native, always-visible desktop use case.

For detailed provenance, preserved upstream credit and a summary of the differences, see [NOTICE.md](NOTICE.md).

## Current features

- upcoming events from **KDE PIM / Akonadi**;
- Google Calendar works through the user's existing Akonadi configuration — no separate OAuth client or Google API project is required by this widget;
- day-by-day grouping with locale-aware dates;
- dedicated labels for **Today / Tomorrow** and separators between weeks;
- 3, 5, 7 or 14 day look-ahead;
- manual refresh button;
- optional forced synchronization of **Akonadi Google resources every five minutes**;
- solid or translucent background;
- system/light/dark color modes;
- Italian localization;
- Plasma/system fonts rather than bundled Apple fonts.

## Calendar sources

The agenda reads events exposed by the Plasma **`pimevents`** backend, so it is not limited to Google Calendar. In principle, calendars provided to KDE PIM/Akonadi by Google, CalDAV/Nextcloud, iCalendar and other supported resources can be displayed.

The current **forced refresh implementation is intentionally narrower**: it discovers and synchronizes resources matching `akonadi_google_resource_*`. Other Akonadi calendars remain visible, but their remote synchronization is left to their normal Akonadi resource behavior until those providers are explicitly tested.

## Requirements

- KDE Plasma 6;
- KDE PIM / Akonadi calendar integration and the Plasma PIM events plugin;
- at least one calendar source configured in Akonadi if remote events are desired;
- `qdbus-qt6` for the current forced Google synchronization feature.

If `qdbus-qt6` is unavailable, the widget can still display events already present in Akonadi, but the manual/automatic forced Google refresh cannot work.

## Installation

### Development / manual installation

Copy the repository directory to:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Then add **Simple Plasma Agenda** from Plasma's *Add Widgets* dialog.

When changing QML during development, Plasma can occasionally retain compiled QML caches. If a changed widget clearly behaves like an older version, remove it from the desktop and, only when necessary, clear:

```bash
rm -rf ~/.cache/plasmashell/qmlcache
systemctl --user restart plasma-plasmashell.service
```

### Packaged installation

A `.plasmoid` package can be built with:

```bash
./scripts/package.sh
```

and installed with Plasma's *Install Widget From Local File* dialog or with `kpackagetool6`.

## Configuration philosophy

Simple Plasma Agenda deliberately does **not** expose calendar/account selection controls. Account and collection management belong to KDE PIM/Akonadi applications such as KOrganizer/Merkuro. This keeps the widget small and avoids a calendar-selection crash path observed in Plasma during development.

The default first day of the week is **Monday**. The user can switch it to Sunday from the Agenda settings.

## Privacy and credentials

Simple Plasma Agenda does not implement its own Google OAuth flow and does not store Google credentials. It reads data already synchronized by KDE PIM/Akonadi. The forced Google refresh asks the existing Akonadi Google resource to synchronize through the local D-Bus interface.

## Testing

Testing is being expanded across several Plasma distributions and clean virtual machines. The current matrix, including planned environments, is maintained in [TESTING.md](TESTING.md).

## AI-assisted development

This project has been developed with substantial assistance from **OpenAI ChatGPT** for source analysis, QML implementation/refactoring, debugging, documentation and test planning. Functional goals, design choices, manual tests and acceptance/rejection of proposed changes are directed by the **Author**.

The project does not present AI-generated output as independently verified code: changes are intended to be reviewed and tested on real Plasma systems before release. See [AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md).

## License

GPL-3.0. See [LICENSE](LICENSE).

## Credits

- **Omar Ceretta** — author and maintainer of Simple Plasma Agenda.
- **Jack Faith (`jaxparrow07`)** — author of the upstream macOS Calendar widget on which this project was based.

Upstream attribution is documented in [NOTICE.md](NOTICE.md).
