# Simple Plasma Agenda — VM quick testing

This file is a **development helper**, not end-user installation documentation. It is intended to make repeated clean-VM testing fast while Simple Plasma Agenda is still under local development.

## Fastest path from a cloned repository

From the repository root:

```bash
chmod +x scripts/vm-test-setup.sh
./scripts/vm-test-setup.sh all
```

`all` performs four operations:

1. detects the distribution through `/etc/os-release`;
2. installs the KDE PIM/Akonadi packages needed for the **full** test experience;
3. starts Akonadi when possible;
4. performs a clean plasmoid install, clears the Plasma QML cache, restarts `plasmashell`, and prints a pre-flight report.

The one part it **does not automate** is calendar account authentication. After the script finishes, open KOrganizer, add/authenticate the calendar resource, and verify the events are visible there before testing the plasmoid.

> If the plasmoid is already placed on the desktop, remove that instance before running `fresh` or `all`.

```bash
rm -rf ~/.cache/plasmashell/qmlcache
systemctl --user restart plasma-plasmashell.service
```

## Why the script does not rename `-main`

A GitHub branch ZIP normally expands to a directory such as `simple-plasma-agenda-main`. We do **not** need to rename that folder manually. KDE's `kpackagetool6` reads `metadata.json` and installs the package according to the plugin ID `com.simple.plasma.agenda`.

The helper stages only `metadata.json` and `contents/`, so repository documentation and development scripts are not copied into the installed plasmoid.

## Useful commands

Install dependencies only:

```bash
./scripts/vm-test-setup.sh deps
```

Install/update the plasmoid from the current checkout without restarting Plasma:

```bash
./scripts/vm-test-setup.sh install
```

Clean reinstall + QML cache clear + Plasma restart:

```bash
./scripts/vm-test-setup.sh fresh
```

Quick diagnostics:

```bash
./scripts/vm-test-setup.sh check
```

Download the `main` branch ZIP from the future GitHub repository and install it:

```bash
./scripts/vm-test-setup.sh download
```

Or another branch:

```bash
./scripts/vm-test-setup.sh download my-test-branch
```

The download mode requires the repository to be accessible from the VM. Before the repository is public, use a cloned/shared working tree instead, or set `SPA_ARCHIVE_URL` to an accessible ZIP URL.

---

# Distribution cheat sheet

These commands intentionally install **KOrganizer as well**, because the current event-click feature opens the corresponding day in KOrganizer. For core agenda display alone, KOrganizer is not required.

## Fedora KDE 44

```bash
sudo dnf install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
akonadictl start
```

Then verify:

```bash
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

Development status: **already tested** on Fedora KDE 44.

## Kubuntu / Ubuntu 26.04 LTS

```bash
sudo apt update
sudo apt install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
akonadictl start
```

If APT cannot find one of the KDE PIM packages, check that the Ubuntu **Universe** repository is enabled. The relevant KDE PIM packages are published in Universe.

Development status: **PASS on Simple Plasma Agenda 0.2.19**.

Tested VM details:

- Ubuntu 26.04 LTS (Resolute Raccoon) / Kubuntu desktop;
- Plasma 6.6.4;
- KOrganizer 6.6.3 / KDE PIM 25.12.3;
- `busctl` at `/usr/bin/busctl`;
- `pimevents.so` at `/usr/lib/x86_64-linux-gnu/qt6/plugins/plasmacalendarplugins/pimevents.so`.

Important test finding: 0.2.18 could race Akonadi at session startup because the first forced Google sync happened after only 1.5 seconds. Version 0.2.19 delays the first automatic sync to **20 seconds**; logout/login with automatic sync enabled then passed, with `Akonadi Control: running`, `Akonadi Server: running`, and events visible in both Plasma's Digital Clock and Simple Plasma Agenda. See `TESTING.md` for the full A/B diagnosis.

On this Kubuntu installation there was no `akonadi_control.service` systemd user unit. Use `akonadictl` for Akonadi lifecycle/status checks rather than assuming the Fedora unit exists.

If the VM uses SDDM automatic login and KWallet is password-protected, KWallet may ask for its password after reboot; that is a desktop/session configuration issue rather than a plasmoid requirement.

## KDE neon

KDE neon is apt-based, so start with the same package names:

```bash
sudo apt update
sudo apt install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
akonadictl start
```

Development status: **optional/planned test; not yet claimed as supported**.

## Arch Linux + Plasma

```bash
sudo pacman -Syu --needed akonadi kdepim-runtime kdepim-addons korganizer curl unzip
akonadictl start
```

Development status: **PASS on Simple Plasma Agenda 0.2.19**.

Verified on the test VM: Google/Akonadi events in KOrganizer, Plasma's Digital Clock and Simple Plasma Agenda; manual and automatic Google refresh; click-to-KOrganizer; interaction/configuration checks; and logout/login with `Akonadi Control: running` / `Akonadi Server: running` after the delayed first automatic sync.

The VM also exposed an upstream KWallet/Secret Service problem during the initial Google setup, before the plasmoid was added: `ksecretd --pam-login` crashed in the QCA/OpenSSL path with `kwallet 6.29.0-1`, `qca-qt6 2.3.10-8` and `openssl 3.6.3-1`. Restarting only `ksecretd`/`kwalletd6` in the current session and authenticating the Google resource again restored normal operation. Do not diagnose this particular failure as a Simple Plasma Agenda issue; see the Arch section in `TESTING.md`.

## openSUSE Tumbleweed KDE

```bash
sudo zypper refresh
sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer curl unzip
akonadictl start
```

Development status: **PASS on Simple Plasma Agenda 0.2.19**.

Tested with Plasma **6.7.4**. `pimevents.so` was present at `/usr/lib64/qt6/plugins/plasmacalendarplugins/pimevents.so`. Google/Akonadi events were verified in KOrganizer, Plasma's Digital Clock and Simple Plasma Agenda; manual and automatic refresh, event activation, interaction/configuration checks and logout/login all passed. After login Akonadi remained `Control: running` / `Server: running`, and the Google resource reported `status = 0`, `online = true`, `statusMessage = "Pronto"`.

## TUXEDO OS

TUXEDO OS was tested on the recovered **Debian-based** image reporting `ID=tuxedo`, `ID_LIKE=debian` and `VERSION_CODENAME=forky`. Existing "TUXEDO OS Legacy" installations may still use the older Ubuntu base. Both families use APT and the helper detects them through `/etc/os-release` rather than hard-coding a specific TUXEDO base.

Start with:

```bash
sudo apt update
sudo apt install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
akonadictl start
```

Development status: **PASS on Simple Plasma Agenda 0.2.21**.

Tested on TUXEDO OS (Debian base, codename `forky`) with Plasma **6.7.2**. `pimevents.so` was present at `/usr/lib/x86_64-linux-gnu/qt6/plugins/plasmacalendarplugins/pimevents.so`. Google/Akonadi events were verified in KOrganizer, Plasma's Digital Clock and Simple Plasma Agenda; manual and automatic refresh, event activation, interaction/configuration checks, the 19 × 21 preferred geometry and logout/login all passed. After login Akonadi remained `Control: running` / `Server: running`, and the Google resource reported `status = 0`, `online = true`, `statusMessage = "Pronto"`.

---

# Calendar setup: the unavoidable manual step

After package installation, open KOrganizer:

```bash
korganizer
```

Configure at least one Akonadi-backed calendar resource and authenticate it. Examples include:

- Google Calendar;
- CalDAV / Nextcloud;
- iCalendar;
- another calendar resource supported by Akonadi.

Before testing Simple Plasma Agenda, confirm that the event is visible in KOrganizer (or another Akonadi-aware client) and, ideally, in Plasma's Digital Clock PIM events view. If those cannot see the event either, debug Akonadi/resource configuration first.

# Open KOrganizer and go to:

Settings → Configure KOrganizer… → General → Calendars → Add…

Alternatively, in KOrganizer's Calendar Manager sidebar, use Add Calendar….


# What to record for every VM

Copy the output of:

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

Then test at least:

- widget loads and survives a Plasma restart;
- Italian localization when Plasma is Italian;
- 1 / 3 / 5 / 7 / 14 / 21 / 28 day ranges;
- density and event text-size presets;
- past-event dimming;
- mouse hover;
- Tab / Shift+Tab focus and Enter/Space activation;
- event click opens the correct day in KOrganizer and brings it forward;
- manual Google refresh when a Google Akonadi resource exists;
- automatic Google refresh every 5 minutes;
- **logout/login with automatic Google refresh enabled**, followed by `akonadictl status` confirming both Control and Server are running;
- events still visible in Plasma's Digital Clock and Simple Plasma Agenda after the delayed first automatic sync;
- multiple calendar providers together when available.

Record **actual results**, not expected support, in the repository TESTING.md.
