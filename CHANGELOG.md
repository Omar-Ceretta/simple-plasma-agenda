# Changelog

Simple Plasma Agenda is still under local pre-release development. These entries document the recent development versions that materially affect cross-distribution testing.

## 0.2.21 — 2026-08-26

### Changed

- Further reduced the initial desktop geometry from **21 × 24** to **19 × 21 Kirigami grid units**, with a stronger reduction in width.
- Recalibrated only the width-based typography coefficients so the default label/title/event text sizes remain equivalent to 0.2.20 at the new preferred width; density and vertical spacing behavior are otherwise unchanged.
- Changed the title tooltip to: **“Clicca su un evento per aprirne il giorno su KOrganizer”**.

### Testing status

- TUXEDO OS (Debian base, codename `forky`) / Plasma 6.7.2 passed the full 0.2.21 VM test cycle: Google/Akonadi event display, `pimevents`, manual and automatic refresh, click-to-KOrganizer, interaction/configuration checks, the refined 19 × 21 initial geometry, and logout/login with Akonadi remaining `Control: running` / `Server: running`.
- The 19 × 21 initial geometry was accepted after the TUXEDO VM test as the preferred default size.

## 0.2.20 — 2026-08-26

### Changed

- Reduced the initial desktop geometry from **22 × 26** to **21 × 24 Kirigami grid units**.
- Default typography, density presets, event spacing, minimum resize limits and backend behavior are unchanged.
- Synchronized the plugin metadata version with the current development version.

### Testing status

- This intermediate geometry-only build was superseded by 0.2.21 before the planned TUXEDO OS VM pass.
- openSUSE Tumbleweed passed the preceding 0.2.19 build and is recorded below as a completed VM test.

## 0.2.19 — 2026-08-25

### Fixed

- Delayed the **first automatic Google/Akonadi forced synchronization** from 1.5 seconds to 20 seconds after plasmoid startup.
- This prevents a startup race reproduced on Kubuntu 26.04 where an early forced sync could leave Akonadi in `Control: stopped / Server: running` after logout/login.
- Manual refresh remains immediate and subsequent automatic refreshes remain every 5 minutes.

### Tested

- Kubuntu 26.04 LTS / Plasma 6.6.4 passed logout/login with automatic Google synchronization enabled, with events visible in both Plasma's Digital Clock and Simple Plasma Agenda.
- Arch Linux + KDE Plasma passed the 0.2.19 VM test cycle: Akonadi/pimevents event display, Google manual and automatic refresh, click-to-KOrganizer, interaction/configuration checks, and logout/login with Akonadi remaining `Control: running` / `Server: running`.
- openSUSE Tumbleweed / Plasma 6.7.4 passed the 0.2.19 VM test cycle at the first attempt, including Google/Akonadi event display, `pimevents`, manual and automatic refresh, click-to-KOrganizer, interaction/configuration checks, and logout/login with Akonadi remaining `Control: running` / `Server: running`.
- An unrelated `ksecretd --pam-login` / QCA / OpenSSL crash encountered while initially configuring Google on the Arch VM was isolated before the plasmoid was added and recorded as an upstream environment issue in `TESTING.md`.

## 0.2.18 — 2026-08-25

### Fixed

- Improved event click portability on Kubuntu by explicitly launching KOrganizer between the `showDate` D-Bus request and the KWin window activation step.
- Kept Fedora behavior compatible with the same sequence through KOrganizer's single-instance behavior.

## 0.2.17 — 2026-08-25

### Changed

- Replaced Qt-specific `qdbus` command dependencies with `busctl --user` for Google synchronization and KOrganizer/KWin D-Bus actions.
- Added event hover feedback.
- Added keyboard focus and Enter/Space event activation with accessibility metadata.
