# Simple Plasma Agenda — Testing

## Italiano

Questo file registra solo **test realmente eseguiti**. Non è un elenco di piattaforme promesse o garantite.

Versione di sviluppo corrente: **0.2.21**.

## Ambienti provati

| Ambiente | Plasma | Build SPA provata | Esito |
| --- | --- | --- | --- |
| Fedora KDE 44 | Plasma 6 | sviluppo 0.2.x | PASS |
| Kubuntu 26.04 LTS | 6.6.4 | 0.2.19 | PASS |
| Arch Linux + KDE | Plasma 6 | 0.2.19 | PASS |
| openSUSE Tumbleweed | 6.7.4 | 0.2.19 | PASS |
| TUXEDO OS Debian base (`forky`) | 6.7.2 | 0.2.21 | PASS |
| KDE neon User Edition 24.04 (`noble`) | 6.7.4 | 0.2.21 | PASS |

## Controlli coperti

Nel corso dei test sono stati verificati, a seconda dell'ambiente:

- installazione delle dipendenze KDE PIM/Akonadi;
- presenza del plugin Plasma `pimevents`;
- calendario Google tramite risorsa Akonadi;
- eventi visibili in KOrganizer;
- stessi eventi visibili nel calendario dell'Orologio digitale di Plasma;
- stessi eventi visibili in Simple Plasma Agenda;
- refresh Google manuale;
- refresh Google automatico ogni 5 minuti;
- prima sincronizzazione automatica ritardata di 20 secondi;
- clic/attivazione evento → giorno corretto in KOrganizer;
- hover e navigazione da tastiera di base;
- impostazioni grafiche e intervalli temporali;
- logout/login con Akonadi ancora operativo;
- geometria iniziale **19 × 21** validata sulla 0.2.21.

## Limiti intenzionali da tenere presenti nei test

- La selezione delle sorgenti calendario **non** appartiene al plasmoide: resta ad Akonadi/KOrganizer.
- Il clic apre il **giorno** in KOrganizer, non il singolo editor dell'evento.
- Il refresh forzato riguarda soltanto `akonadi_google_resource_*`.
- Se KOrganizer e il calendario Plasma non vedono gli eventi, il problema va risolto prima nel livello Akonadi/PIM.

## Preflight minimo

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

---

## English

This file records only **tests that were actually performed**. It is not a list of promised or guaranteed platforms.

Current development version: **0.2.21**.

## Tested environments

| Environment | Plasma | SPA build tested | Result |
| --- | --- | --- | --- |
| Fedora KDE 44 | Plasma 6 | development 0.2.x | PASS |
| Kubuntu 26.04 LTS | 6.6.4 | 0.2.19 | PASS |
| Arch Linux + KDE | Plasma 6 | 0.2.19 | PASS |
| openSUSE Tumbleweed | 6.7.4 | 0.2.19 | PASS |
| TUXEDO OS Debian base (`forky`) | 6.7.2 | 0.2.21 | PASS |
| KDE neon User Edition 24.04 (`noble`) | 6.7.4 | 0.2.21 | PASS |

## Covered checks

Across the tested environments, the following were verified as applicable:

- KDE PIM/Akonadi dependency installation;
- presence of Plasma's `pimevents` plugin;
- Google Calendar through an Akonadi resource;
- events visible in KOrganizer;
- the same events visible in Plasma's Digital Clock calendar;
- the same events visible in Simple Plasma Agenda;
- manual Google refresh;
- automatic Google refresh every 5 minutes;
- delayed first automatic sync after 20 seconds;
- event click/activation → correct day in KOrganizer;
- hover and basic keyboard navigation;
- appearance settings and date ranges;
- logout/login with Akonadi still operational;
- initial **19 × 21** geometry validated on 0.2.21.

## Intentional limitations relevant to testing

- Calendar-source selection does **not** belong to the widget; it stays in Akonadi/KOrganizer.
- Clicking opens the event's **day** in KOrganizer, not the individual event editor.
- Forced refresh is limited to `akonadi_google_resource_*`.
- If KOrganizer and Plasma's calendar cannot see the events, solve the Akonadi/PIM layer first.

## Minimal preflight

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```
