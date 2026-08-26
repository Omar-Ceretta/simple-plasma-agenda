# Simple Plasma Agenda — Testing

This document records **tests that were actually performed**. Planned environments and expected compatibility are kept separate so that repository documentation does not overstate support.

Current local development version: **0.2.21**.

The distribution PASS results below record the build that was actually tested. Version 0.2.21 refines the initial preferred desktop geometry and title tooltip; its first full VM pass is planned on the TUXEDO OS Debian-based image.

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

### Arch Linux + KDE Plasma — PASS on 0.2.19

Fresh Arch Linux VM tested with the distribution packages current during the test cycle. Recorded package versions included:

- `kdepim-runtime 26.08.0-1`;
- `korganizer 26.08.0-1`;
- `kwallet 6.29.0-1`;
- `qca-qt6 2.3.10-8`;
- `openssl 3.6.3-1`.

Verified:

- dependency installation through `scripts/vm-test-setup.sh`;
- Akonadi Control and Server running normally;
- Google Calendar authentication and synchronization through the Akonadi Google resource;
- Google events visible in KOrganizer;
- the same events visible in Plasma's Digital Clock;
- the same events visible in Simple Plasma Agenda;
- manual Google refresh;
- automatic Google refresh, including the delayed first sync after plasmoid startup;
- event click opens the correct day in KOrganizer;
- hover behavior;
- basic keyboard/accessibility behavior;
- appearance/configuration controls;
- logout/login with automatic Google synchronization enabled;
- after login and the delayed first automatic sync, `akonadictl status` remained:

```text
Akonadi Control: running
Akonadi Server: running
```

The Arch test therefore confirmed that the 20-second startup delay introduced in 0.2.19 also avoids destabilizing Akonadi on this VM.

#### Arch KWallet / Secret Service incident — upstream, not Simple Plasma Agenda

During the **initial Google-account setup, before Simple Plasma Agenda was added to the desktop**, the PAM-launched process

```text
/usr/bin/ksecretd --pam-login 8 9
```

crashed with `SIGSEGV`. The backtrace passed through `EVP_CIPHER_CTX_set_key_length()`, `libqca-ossl.so` and `QCA::Cipher::setup()`. The package combination was `kwallet 6.29.0-1`, `qca-qt6 2.3.10-8`, and `openssl 3.6.3-1`, matching contemporaneous upstream KDE reports (bugs 524522 / 524636).

After the crash, the Google Akonadi resource remained offline because its credential was not available in the password store. The journal contained messages including `Can't find session /org/freedesktop/secrets/session/1` and `Account ... not found in password store`. Akonadi itself remained `Control: running` / `Server: running`.

For this VM test, only the affected session services were restarted: `ksecretd` and `kwalletd6` were stopped and then reactivated through their D-Bus services, without deleting or resetting the Akonadi database. Re-authenticating the existing Google resource then succeeded. The resource reported `status = 0`, `online = true`, `statusMessage = "Pronto"`, and events appeared normally in KOrganizer and Plasma's Digital Clock before the plasmoid was introduced.

Because the failure was reproduced entirely upstream of Simple Plasma Agenda and disappeared once KWallet/Secret Service was restored, it is recorded as a **distribution/KDE PIM environment issue**, not a widget limitation. The later Simple Plasma Agenda logout/login test passed.

### openSUSE Tumbleweed / Plasma 6.7.4 — PASS on 0.2.19

Fresh openSUSE Tumbleweed KDE VM tested with Plasma **6.7.4**.

Recorded pre-flight state:

- `akonadictl status`: `Akonadi Control: running` / `Akonadi Server: running`;
- Plasma PIM plugin: `/usr/lib64/qt6/plugins/plasmacalendarplugins/pimevents.so`;
- Google Akonadi resource tested: `akonadi_google_resource_0`;
- resource state after testing: `status = 0`, `online = true`, `statusMessage = "Pronto"`.

Verified:

- dependency installation through the openSUSE path in `scripts/vm-test-setup.sh`;
- Google Calendar authentication and synchronization through Akonadi;
- Google events visible in KOrganizer;
- the same events visible in Plasma's Digital Clock;
- the same events visible in Simple Plasma Agenda;
- manual Google refresh;
- automatic Google refresh, including the delayed first sync;
- event click opens the correct day in KOrganizer;
- interaction and appearance/configuration checks;
- logout/login with Simple Plasma Agenda present and automatic Google synchronization enabled;
- after login, Akonadi remained `Control: running` / `Server: running`.

The user journal contained non-blocking messages from `akonadi_control` about host-portal app registration and one `akonadi_birthdays_resource` `DeleteItems` error. They had no observed effect on Google synchronization, Akonadi state, Plasma's Digital Clock or Simple Plasma Agenda, and are not recorded as widget defects.

## Known project limitations relevant to testing

- Calendar source selection is intentionally **not** implemented inside the plasmoid. Saving PIM calendar selections through Plasma's PIM model was found to crash `plasmashell`; source administration remains in Akonadi/KOrganizer.
- Event activation currently opens **the event's day** in KOrganizer, not the individual incidence editor, because the Plasma calendar QML event wrapper does not expose the original Akonadi incidence UID.
- Forced remote synchronization is intentionally limited to `akonadi_google_resource_*`. Do not generalize it to arbitrary Akonadi resources, which may represent mail, contacts or other data.

## Planned VM tests

These environments are **not yet recorded as passed**:

- TUXEDO OS Debian-based image — next planned test; record the exact image/build used;
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
