# Upstream attribution and provenance

**Simple Plasma Agenda** is a derivative work based on **macOS Calendar 1.1** by **Jack Faith (`jaxparrow07`)**.

The package used as the starting point identified its upstream project as:

- Author: Jack Faith
- Widget: macOS Calendar 1.1
- Original package ID: `com.jaxparrow07.macoswidgets.calendar`
- Repository URL recorded by that package: `https://github.com/jaxparrow07/macos-widgets`
- Current upstream widget collection: `https://github.com/jaxparrow07/liquidglass-kde-widgets`
- License: GPL-3.0

Simple Plasma Agenda is **not affiliated with or endorsed by Jack Faith**. Jack Faith is the upstream author, not a maintainer or co-author of this fork.

## What was retained

The fork deliberately kept the proven KDE Plasma Calendar / KDE PIM / Akonadi event-loading approach close to the upstream implementation, because it already interoperated correctly with Plasma's calendar infrastructure.

## What changed

The project was refocused around a different use case: an **agenda-only panel that stays visible on the Plasma desktop**.

Among the changes introduced during the initial development phase:

- removal of the month-calendar view;
- compact upcoming-events-only layout;
- locale-aware day labels and date formatting;
- `OGGI` / `DOMANI` grouping and separators between weeks;
- default Monday-first week;
- Plasma-native solid and translucent visual styles;
- removal of the upstream liquid-glass shader, realtime refraction controls and bundled SF Pro fonts;
- use of the Plasma/system font and color scheme;
- no calendar-selection checkboxes inside the widget, to avoid a Plasma/PIM crash path observed during testing;
- optional forced synchronization of Akonadi Google resources, manually or every five minutes;
- Italian localization.

The project remains distributed under **GPL-3.0**, preserving the upstream license.
