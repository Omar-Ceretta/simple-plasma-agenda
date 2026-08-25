# Changelog

Simple Plasma Agenda is still under local pre-release development. These entries document the recent development versions that materially affect cross-distribution testing.

## 0.2.19 — 2026-08-25

### Fixed

- Delayed the **first automatic Google/Akonadi forced synchronization** from 1.5 seconds to 20 seconds after plasmoid startup.
- This prevents a startup race reproduced on Kubuntu 26.04 where an early forced sync could leave Akonadi in `Control: stopped / Server: running` after logout/login.
- Manual refresh remains immediate and subsequent automatic refreshes remain every 5 minutes.

### Tested

- Kubuntu 26.04 LTS / Plasma 6.6.4 passed logout/login with automatic Google synchronization enabled, with events visible in both Plasma's Digital Clock and Simple Plasma Agenda.
- Arch Linux + KDE Plasma passed the 0.2.19 VM test cycle: Akonadi/pimevents event display, Google manual and automatic refresh, click-to-KOrganizer, interaction/configuration checks, and logout/login with Akonadi remaining `Control: running` / `Server: running`.
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
