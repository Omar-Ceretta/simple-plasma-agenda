# Test / Testing

## Italiano

Questo file registra solo **test realmente eseguiti**. Le modifiche UI della **0.2.22** sono state validate su Fedora; installer e integrazione KDE PIM/Akonadi sono rimasti invariati rispetto al codice già provato sulle altre distribuzioni.

### Ambienti provati

| Ambiente | Plasma | Test | Esito |
| --- | --- | --- | --- |
| Fedora KDE 44 | 6.6.4 | **0.2.22 UI** + E2E installer (`dnf`) | PASS |
| Kubuntu 26.04 LTS | 6.6.4 | E2E installer (`apt`) | PASS |
| Arch Linux + KDE | 6.7.4 | E2E installer (`pacman`) | PASS |
| openSUSE Tumbleweed | 6.7.4 | E2E installer (`zypper`) | PASS |
| openSUSE Leap 16.0 | 6.4.2 | E2E installer (`zypper`) | PASS |
| TUXEDO OS Debian base (`forky`) | 6.7.2 | Smoke installer (`apt`) | PASS |
| KDE neon User Edition 24.04 (`noble`) | 6.7.4 | Widget 0.2.21 | PASS |

**E2E**: test da sistema senza KDE PIM/Akonadi, fino a KOrganizer, selezione Akonadi, reload Plasma e installazione SPA.  
**Smoke**: stack PIM già presente; verificato il percorso dell'installer, la selezione esistente e l'installazione SPA.

### 0.2.22 — controlli UI su Fedora

Verificati sulla build poi promossa senza modifiche funzionali a 0.2.22:

- raggio predefinito **12 px**;
- titolo nascondibile con testata compatta e refresh ancora disponibile;
- sfondo traslucido con trasparenza **Bassa / Media / Alta**;
- separatori settimanali opzionali;
- evidenziazione KDE semantica degli eventi entro 15 minuti e degli eventi in corso;
- avviso sonoro opzionale a **T−15 minuti**, disattivato di default, una sola volta, senza recupero tardivo dopo reload/sospensione e senza eventi “tutto il giorno”;
- localizzazione italiana delle nuove impostazioni e del tooltip;
- regressioni principali: eventi Akonadi visibili, refresh Google, attenuazione degli eventi conclusi e clic evento → giorno corretto in KOrganizer.

### Installer / PIM già validati

A seconda dell'ambiente sono stati verificati:

- installazione KDE PIM/Akonadi tramite `dnf`, `apt`, `pacman` e `zypper`;
- selezione delle collection tramite `install.sh --calendars`;
- reload di Plasma solo quando la selezione cambia;
- refresh Google manuale e automatico;
- geometria iniziale **19 × 21**;
- persistenza di Akonadi dopo logout/login nei test completi.

Su openSUSE Tumbleweed è stato validato `zypper refresh` + `zypper dist-upgrade`; su Leap 16.0 il normale percorso `zypper` senza `dist-upgrade` preventivo.

Durante il test Fedora è stato riprodotto anche un KOrganizer non avviabile per librerie non allineate. L'installer rileva questo stato e propone un aggiornamento completo; il ramo automatico di recupero non è stato rieseguito end-to-end dopo la modifica.

### Preflight minimo

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

---

## English

This file records only **tests that were actually performed**. The **0.2.22** UI changes were validated on Fedora; the installer and KDE PIM/Akonadi integration remained unchanged from the code already tested on the other distributions.

### Tested environments

| Environment | Plasma | Test | Result |
| --- | --- | --- | --- |
| Fedora KDE 44 | 6.6.4 | **0.2.22 UI** + E2E installer (`dnf`) | PASS |
| Kubuntu 26.04 LTS | 6.6.4 | E2E installer (`apt`) | PASS |
| Arch Linux + KDE | 6.7.4 | E2E installer (`pacman`) | PASS |
| openSUSE Tumbleweed | 6.7.4 | E2E installer (`zypper`) | PASS |
| openSUSE Leap 16.0 | 6.4.2 | E2E installer (`zypper`) | PASS |
| TUXEDO OS, Debian base (`forky`) | 6.7.2 | Installer smoke (`apt`) | PASS |
| KDE neon User Edition 24.04 (`noble`) | 6.7.4 | Widget 0.2.21 | PASS |

**E2E**: tested from a system without KDE PIM/Akonadi through KOrganizer, Akonadi selection, Plasma reload and SPA installation.  
**Smoke**: PIM stack already present; installer path, existing selection and SPA installation were verified.

### 0.2.22 — Fedora UI checks

Verified on the build later promoted to 0.2.22 without functional changes:

- default **12 px** corner radius;
- optional title with compact header and refresh still available;
- translucent background with **Low / Medium / High** transparency;
- optional weekly dividers;
- KDE semantic highlighting for events within 15 minutes and events in progress;
- optional **T−15 minute** sound, disabled by default, one playback only, no late catch-up after reload/suspend and no all-day events;
- Italian localization for the new settings and tooltip;
- main regressions: Akonadi events visible, Google refresh, completed-event dimming and event click → correct day in KOrganizer.

### Previously validated installer / PIM paths

As applicable across the environments above:

- KDE PIM/Akonadi installation through `dnf`, `apt`, `pacman` and `zypper`;
- collection selection through `install.sh --calendars`;
- Plasma reload only when the selection changes;
- manual and automatic Google refresh;
- initial **19 × 21** geometry;
- Akonadi persistence after logout/login in the full tests.

On openSUSE Tumbleweed, `zypper refresh` + `zypper dist-upgrade` was validated; on Leap 16.0, the normal `zypper` path without a preventive `dist-upgrade` was validated.

The Fedora test also reproduced a KOrganizer runtime failure caused by out-of-sync libraries. The installer detects that state and offers a full system update; that automatic recovery branch was not re-run end-to-end after the change.

### Minimal preflight

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```
