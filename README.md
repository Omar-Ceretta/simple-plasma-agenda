# Simple Plasma Agenda

## Italiano

**Simple Plasma Agenda** è un plasmoide per **KDE Plasma 6** che mostra sul desktop i prossimi eventi di calendario già disponibili tramite **KDE PIM / Akonadi**.

È volutamente un'agenda, non un calendario completo: niente vista mensile, niente gestione degli account, niente selezione interna delle sorgenti. L'obiettivo è tenere sott'occhio i prossimi appuntamenti con un'interfaccia semplice e poco ingombrante.

Versione di sviluppo corrente: **0.2.21**.

### Caratteristiche

- intervallo configurabile: **1, 3, 5, 7, 14, 21 o 28 giorni**;
- sezioni **OGGI**, **DOMANI** e date successive localizzate;
- separatori settimanali;
- primo giorno della settimana lunedì o domenica;
- sfondo solido o traslucido;
- tema di sistema, chiaro o scuro;
- densità Compact / Normal / Airy;
- testo eventi Small / Normal / Large;
- eventi conclusi attenuati dopo l'orario reale di fine;
- hover, focus da tastiera e attivazione con Invio/Spazio;
- clic su un evento → apertura del relativo **giorno** in KOrganizer;
- refresh manuale delle risorse Google Akonadi;
- refresh Google automatico opzionale ogni 5 minuti, con prima sincronizzazione ritardata di 20 secondi dopo l'avvio;
- interfaccia italiana.

### Cosa non fa

Simple Plasma Agenda **non**:

- mostra un calendario mensile;
- si collega direttamente a Google, Nextcloud o altri servizi remoti;
- interroga direttamente il database Akonadi;
- gestisce account o credenziali;
- seleziona o deseleziona calendari dal proprio pannello di configurazione;
- apre direttamente l'editor del singolo evento.

La scelta delle sorgenti resta ad **Akonadi / KOrganizer**. Il plasmoide mostra ciò che il plugin Plasma `pimevents` rende disponibile.

### Come arrivano gli eventi

```text
Google / CalDAV / Nextcloud / iCalendar / calendario locale
                         ↓
                  risorsa Akonadi
                         ↓
                    Akonadi
                         ↓
             plugin Plasma `pimevents`
                         ↓
              Simple Plasma Agenda
```

Se gli eventi non sono visibili in Akonadi e in `pimevents`, Simple Plasma Agenda non può mostrarli.

## Installazione

### Se KDE PIM / Akonadi sono già configurati

Puoi usare il normale pacchetto `.plasmoid` o, quando disponibile, **Aggiungi elementi grafici… → Scarica nuovi elementi grafici…** in Plasma.

Per un pacchetto locale:

```bash
kpackagetool6 -t Plasma/Applet -i com.simple.plasma.agenda-0.2.21.zip
```

L'installazione per utente finisce sotto:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Poi: **Desktop → Aggiungi elementi grafici… → Simple Plasma Agenda**.

### Se parti da Plasma senza PIM: installazione assistita consigliata

Il repository include `scripts/install.sh`. Lo script:

- verifica che il sistema usi Plasma 6;
- riconosce la famiglia della distribuzione e il package manager appropriato (`dnf`, `apt`, `pacman` o `zypper`);
- controlla Akonadi, KOrganizer, `busctl` e il plugin Plasma `pimevents`;
- se manca qualcosa, mostra prima i pacchetti che intende installare e **chiede conferma prima di usare `sudo`**;
- avvia Akonadi come utente, se necessario;
- si ferma su un checkpoint manuale: devi aggiungere/autenticare almeno un calendario in KOrganizer e verificare che gli eventi siano visibili;
- solo dopo la tua conferma installa o aggiorna Simple Plasma Agenda.

Dal repository estratto:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

Comandi aggiuntivi:

```bash
./scripts/install.sh --check    # solo controlli, nessuna modifica
./scripts/install.sh --deps     # prepara solo KDE PIM / Akonadi
./scripts/install.sh --widget   # installa/aggiorna solo il plasmoide
```

Lo script **non** configura account, password o credenziali e non sceglie i calendari al posto dell'utente.

Se l'installazione delle dipendenze non ti interessa, puoi rispondere **No** alla richiesta di conferma: non verrà installato nulla.

### Installazione manuale delle dipendenze

Sono i gruppi di pacchetti usati nei test reali.

**Fedora KDE**

```bash
sudo dnf install akonadi-server kdepim-runtime kdepim-addons korganizer
```

**Debian / Ubuntu / Kubuntu / KDE neon / TUXEDO OS**

```bash
sudo apt update
sudo apt install akonadi-server kdepim-runtime kdepim-addons korganizer
```

**Arch Linux**

```bash
sudo pacman -Syu --needed akonadi kdepim-runtime kdepim-addons korganizer
```

**openSUSE**

```bash
sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer
```

Poi controlla:

```bash
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

Se Akonadi non è in esecuzione:

```bash
akonadictl start
```

Non avviare Akonadi come root.

### Aggiungere e verificare un calendario

Apri KOrganizer e vai in:

```text
Settings → Configure KOrganizer… → General → Calendars → Add…
```

oppure usa **Add Calendar…** nel pannello laterale dei calendari.

Configura almeno una sorgente supportata da Akonadi, per esempio Google, CalDAV / Nextcloud, iCalendar o un calendario locale, e completa l'eventuale autenticazione.

Prima di aggiungere Simple Plasma Agenda al desktop, verifica che gli eventi compaiano:

1. in **KOrganizer**;
2. preferibilmente anche nel calendario dell'**Orologio digitale di Plasma**, con gli eventi PIM attivi.

Se non compaiono lì, il problema è a monte del plasmoide e va risolto nella configurazione Akonadi/PIM.

### Note sul refresh Google

Il normale caricamento degli eventi passa sempre da Akonadi/`pimevents`.

Il pulsante Refresh e l'auto-refresh forzano invece soltanto risorse chiamate:

```text
akonadi_google_resource_*
```

Non vengono sincronizzate indiscriminatamente altre risorse Akonadi, che potrebbero rappresentare posta, contatti o dati non legati al calendario.

### Note sul clic degli eventi

Il clic apre **KOrganizer sul giorno dell'evento**, non il dettaglio dell'incidenza. Il wrapper QML del calendario Plasma non espone al plasmoide un UID Akonadi utilizzabile per aprire direttamente il singolo evento.

KOrganizer non è strettamente necessario per la sola visualizzazione dell'agenda, ma è richiesto per questa azione.

## Ambienti testati

Test reali completati durante lo sviluppo:

- Fedora KDE 44 / Plasma 6;
- Kubuntu 26.04 LTS / Plasma 6.6.4;
- Arch Linux + KDE Plasma;
- openSUSE Tumbleweed / Plasma 6.7.4;
- TUXEDO OS, base Debian `forky` / Plasma 6.7.2;
- KDE neon User Edition 24.04 / Plasma 6.7.4.

I dettagli sintetici sono in [`TESTING.md`](TESTING.md). Le versioni indicate sono ambienti realmente provati, non una promessa di supporto per ogni futura combinazione di pacchetti.

## Licenza e provenienza

Simple Plasma Agenda è distribuito con licenza **GPL-3.0** ed è un fork profondamente modificato di **macOS Calendar 1.1** di Jack Faith (`jaxparrow07`). Vedi [`NOTICE.md`](NOTICE.md).

Lo sviluppo è stato svolto con assistenza di OpenAI ChatGPT sotto direzione e verifica umana. Vedi [`AI_ASSISTED_DEVELOPMENT.md`](AI_ASSISTED_DEVELOPMENT.md).

---

## English

**Simple Plasma Agenda** is a **KDE Plasma 6** desktop widget that shows upcoming calendar events already available through **KDE PIM / Akonadi**.

It is intentionally an agenda, not a full calendar: no month view, no account management, and no calendar-source selector inside the widget. Its purpose is simply to keep upcoming appointments visible on the desktop in a compact form.

Current development version: **0.2.21**.

### Features

- configurable look-ahead: **1, 3, 5, 7, 14, 21 or 28 days**;
- **TODAY**, **TOMORROW** and localized following dates;
- week separators;
- Monday- or Sunday-first weeks;
- solid or translucent background;
- system, light or dark theme;
- Compact / Normal / Airy density;
- Small / Normal / Large event text;
- completed events dim after their actual end time;
- hover, keyboard focus and Enter/Space activation;
- click an event → open its **day** in KOrganizer;
- manual refresh for Google Akonadi resources;
- optional Google auto-refresh every 5 minutes, with the first sync delayed by 20 seconds after startup;
- Italian localization.

### What it does not do

Simple Plasma Agenda does **not**:

- provide a monthly calendar view;
- connect directly to Google, Nextcloud or other remote services;
- query the Akonadi database directly;
- manage accounts or credentials;
- enable or disable calendars from its own settings;
- open the individual event editor directly.

Calendar-source selection stays in **Akonadi / KOrganizer**. The widget displays what Plasma's `pimevents` plugin exposes.

### How events reach the widget

```text
Google / CalDAV / Nextcloud / iCalendar / local calendar
                         ↓
                  Akonadi resource
                         ↓
                    Akonadi
                         ↓
             Plasma `pimevents` plugin
                         ↓
              Simple Plasma Agenda
```

If events are not available through Akonadi and `pimevents`, Simple Plasma Agenda cannot display them.

## Installation

### If KDE PIM / Akonadi are already configured

Use the normal `.plasmoid` package or, once available, Plasma's **Add Widgets… → Get New Widgets…** interface.

For a local package:

```bash
kpackagetool6 -t Plasma/Applet -i com.simple.plasma.agenda-0.2.21.zip
```

Per-user installation lives under:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Then use: **Desktop → Add Widgets… → Simple Plasma Agenda**.

### Starting from Plasma without PIM: assisted installation recommended

The repository includes `scripts/install.sh`. The script:

- checks that the system is running Plasma 6;
- detects the distribution family and the appropriate package manager (`dnf`, `apt`, `pacman` or `zypper`);
- checks Akonadi, KOrganizer, `busctl` and Plasma's `pimevents` plugin;
- if something is missing, shows the packages it intends to install and **asks before using `sudo`**;
- starts Akonadi as the current user when needed;
- stops at a manual checkpoint: you must add/authenticate at least one calendar in KOrganizer and verify that events are visible;
- only after your confirmation installs or updates Simple Plasma Agenda.

From the extracted repository:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

Additional modes:

```bash
./scripts/install.sh --check    # checks only, no changes
./scripts/install.sh --deps     # prepare KDE PIM / Akonadi only
./scripts/install.sh --widget   # install/update the widget only
```

The script does **not** configure accounts, passwords or credentials, and it does not choose calendar sources for the user.

If you do not want the extra KDE PIM packages, answer **No** at the confirmation prompt: nothing will be installed.

### Manual dependency installation

These are the package sets used in the real tests.

**Fedora KDE**

```bash
sudo dnf install akonadi-server kdepim-runtime kdepim-addons korganizer
```

**Debian / Ubuntu / Kubuntu / KDE neon / TUXEDO OS**

```bash
sudo apt update
sudo apt install akonadi-server kdepim-runtime kdepim-addons korganizer
```

**Arch Linux**

```bash
sudo pacman -Syu --needed akonadi kdepim-runtime kdepim-addons korganizer
```

**openSUSE**

```bash
sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer
```

Then check:

```bash
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

If Akonadi is not running:

```bash
akonadictl start
```

Do not run Akonadi as root.

### Add and verify a calendar

Open KOrganizer and go to:

```text
Settings → Configure KOrganizer… → General → Calendars → Add…
```

or use **Add Calendar…** in KOrganizer's calendar sidebar.

Configure at least one Akonadi-supported source, such as Google, CalDAV / Nextcloud, iCalendar or a local calendar, and complete any required authentication.

Before adding Simple Plasma Agenda to the desktop, make sure events appear:

1. in **KOrganizer**;
2. preferably also in Plasma's **Digital Clock** calendar with PIM events enabled.

If they do not appear there, the issue is upstream of the widget and should be solved in the Akonadi/PIM setup first.

### Google refresh notes

Normal event loading always goes through Akonadi/`pimevents`.

The Refresh button and optional auto-refresh only force resources named:

```text
akonadi_google_resource_*
```

Other Akonadi resources are not synchronized indiscriminately because they may represent mail, contacts or unrelated data.

### Event-click notes

Clicking an event opens **KOrganizer on the event's day**, not the individual incidence editor. Plasma's calendar QML wrapper does not expose a usable original Akonadi UID to the widget.

KOrganizer is not strictly required for agenda display alone, but it is required for this action.

## Tested environments

Real tests completed during development:

- Fedora KDE 44 / Plasma 6;
- Kubuntu 26.04 LTS / Plasma 6.6.4;
- Arch Linux + KDE Plasma;
- openSUSE Tumbleweed / Plasma 6.7.4;
- TUXEDO OS, Debian base `forky` / Plasma 6.7.2;
- KDE neon User Edition 24.04 / Plasma 6.7.4.

See [`TESTING.md`](TESTING.md) for the compact record. These are environments actually tested, not a promise of support for every future package combination.

## License and provenance

Simple Plasma Agenda is released under **GPL-3.0** and is a deeply modified fork of **macOS Calendar 1.1** by Jack Faith (`jaxparrow07`). See [`NOTICE.md`](NOTICE.md).

Development has used OpenAI ChatGPT assistance under human direction and review. See [`AI_ASSISTED_DEVELOPMENT.md`](AI_ASSISTED_DEVELOPMENT.md).
