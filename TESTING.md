# Test / Testing

## Italiano

Questo file registra solo **test realmente eseguiti** sulla versione **0.2.21**. Non è una promessa di supporto per ogni futura combinazione di pacchetti.

### Ambienti provati

| Ambiente | Plasma | Installer | Esito |
| --- | --- | --- | --- |
| Fedora KDE 44 | 6.6.4 | E2E (`dnf`) | PASS |
| Kubuntu 26.04 LTS | 6.6.4 | E2E (`apt`) | PASS |
| Arch Linux + KDE | 6.7.4 | E2E (`pacman`) | PASS |
| openSUSE Tumbleweed | 6.7.4 | E2E (`zypper`) | PASS |
| openSUSE Leap 16.0 | 6.4.2 | E2E (`zypper`) | PASS |
| TUXEDO OS Debian base (`forky`) | 6.7.2 | Smoke (`apt`) | PASS |
| KDE neon User Edition 24.04 (`noble`) | 6.7.4 | — | PASS |

**E2E**: test da sistema senza KDE PIM/Akonadi, fino a KOrganizer, selezione Akonadi, reload Plasma e installazione SPA.  
**Smoke**: stack PIM già presente; verificato il percorso dell'installer, la selezione esistente e l'installazione SPA.

### Controlli coperti

A seconda dell'ambiente sono stati verificati:

- eventi Akonadi visibili in KOrganizer e in Simple Plasma Agenda;
- selezione delle collection tramite `install.sh --calendars`;
- reload di Plasma solo quando la selezione cambia;
- refresh Google manuale e automatico;
- apertura del giorno corretto in KOrganizer;
- intervalli 1 / 3 / 5 / 7 / 14 / 21 / 28 giorni e impostazioni grafiche;
- hover, tastiera e attenuazione degli eventi conclusi;
- geometria iniziale **19 × 21**;
- persistenza di Akonadi dopo logout/login nei test completi.

Su openSUSE Tumbleweed è stato validato il riallineamento rolling con `zypper refresh` + `zypper dist-upgrade`; su Leap 16.0 è stato validato il normale percorso `zypper` senza `dist-upgrade` preventivo.

Durante il test Fedora è stato riprodotto anche un KOrganizer non avviabile per librerie non allineate. L'installer ora rileva questo stato e propone un aggiornamento completo; il ramo automatico di recupero non è stato rieseguito end-to-end dopo la modifica.

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

This file records only **tests that were actually performed** on version **0.2.21**. It is not a promise of support for every future package combination.

### Tested environments

| Environment | Plasma | Installer | Result |
| --- | --- | --- | --- |
| Fedora KDE 44 | 6.6.4 | E2E (`dnf`) | PASS |
| Kubuntu 26.04 LTS | 6.6.4 | E2E (`apt`) | PASS |
| Arch Linux + KDE | 6.7.4 | E2E (`pacman`) | PASS |
| openSUSE Tumbleweed | 6.7.4 | E2E (`zypper`) | PASS |
| openSUSE Leap 16.0 | 6.4.2 | E2E (`zypper`) | PASS |
| TUXEDO OS, Debian base (`forky`) | 6.7.2 | Smoke (`apt`) | PASS |
| KDE neon User Edition 24.04 (`noble`) | 6.7.4 | — | PASS |

**E2E**: tested from a system without KDE PIM/Akonadi through KOrganizer, Akonadi selection, Plasma reload and SPA installation.  
**Smoke**: PIM stack already present; installer path, existing selection and SPA installation were verified.

### Covered checks

As applicable across the environments above:

- Akonadi events visible in KOrganizer and Simple Plasma Agenda;
- collection selection through `install.sh --calendars`;
- Plasma reload only when the selection changes;
- manual and automatic Google refresh;
- correct day opened in KOrganizer;
- 1 / 3 / 5 / 7 / 14 / 21 / 28 day ranges and appearance settings;
- hover, keyboard interaction and dimming of completed events;
- initial **19 × 21** geometry;
- Akonadi persistence after logout/login in the full tests.

On openSUSE Tumbleweed the rolling alignment through `zypper refresh` + `zypper dist-upgrade` was validated; on Leap 16.0 the normal stable `zypper` path was validated without a preventive `dist-upgrade`.

The Fedora test also reproduced a KOrganizer runtime failure caused by out-of-sync libraries. The installer now detects that state and offers a full system update; that automatic recovery branch was not re-run end-to-end after the change.

### Minimal preflight

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```
