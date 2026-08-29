# Simple Plasma Agenda

## Italiano

**Simple Plasma Agenda** è un plasmoide per **KDE Plasma 6** che mostra sul desktop i prossimi eventi già disponibili tramite **KDE PIM / Akonadi**.

È volutamente un'agenda, non un calendario completo: niente vista mensile, niente gestione degli account e niente selettore permanente delle sorgenti nel widget.

Release corrente: **0.2.22**.

### Caratteristiche

- intervallo: **1, 3, 5, 7, 14, 21 o 28 giorni**;
- sezioni **OGGI**, **DOMANI** e date successive;
- separatori settimanali opzionali e settimana da lunedì o domenica;
- sfondo solido o traslucido con tre livelli di trasparenza, colori di sistema/chiari/scuri;
- titolo opzionale, densità Compact / Normal / Airy e testo Small / Normal / Large;
- eventi imminenti/in corso evidenziati con colori semantici KDE; eventi conclusi attenuati dopo l'orario reale di fine;
- avviso sonoro discreto opzionale 15 minuti prima degli eventi con orario, disattivato di default;
- hover, focus da tastiera e attivazione con Invio/Spazio;
- clic su un evento → apertura del relativo **giorno** in KOrganizer;
- refresh manuale delle risorse Google Akonadi;
- refresh Google automatico opzionale ogni 5 minuti, con prima sincronizzazione ritardata di 20 secondi;
- localizzazione italiana.

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

Simple Plasma Agenda non si collega direttamente ai servizi remoti, non gestisce credenziali e non interroga il database Akonadi. Account e sorgenti restano gestiti da **Akonadi / KOrganizer**.

## Installazione

### Installazione assistita — consigliata

È il percorso consigliato anche se parti da Plasma senza KDE PIM/Akonadi.

Con `curl`:

```bash
curl -fsSLo /tmp/simple-plasma-agenda-install.sh \
  https://raw.githubusercontent.com/Omar-Ceretta/simple-plasma-agenda/main/scripts/install.sh \
  && chmod +x /tmp/simple-plasma-agenda-install.sh \
  && /tmp/simple-plasma-agenda-install.sh
```

Oppure con `wget`:

```bash
wget -qO /tmp/simple-plasma-agenda-install.sh \
  https://raw.githubusercontent.com/Omar-Ceretta/simple-plasma-agenda/main/scripts/install.sh \
  && chmod +x /tmp/simple-plasma-agenda-install.sh \
  && /tmp/simple-plasma-agenda-install.sh
```

Lo script viene salvato come file normale in `/tmp`: puoi leggerlo prima di eseguirlo e non viene usato `curl | bash`.

L'installer:

- verifica Plasma 6 e rileva `dnf`, `apt`, `pacman` o `zypper`;
- installa KDE PIM/Akonadi solo dopo conferma prima di `sudo`;
- verifica che KOrganizer sia realmente avviabile e, se necessario, propone un aggiornamento coerente del sistema;
- su Tumbleweed riallinea lo snapshot rolling con `zypper refresh` + `zypper dist-upgrade` prima di installare PIM;
- apre KOrganizer e guida brevemente la configurazione del calendario;
- apre un selettore temporaneo delle collection Akonadi da mostrare in SPA;
- salva la selezione globale di `pimevents` e ricarica Plasma solo se serve;
- installa/aggiorna il plasmoide, usando i file locali da un checkout oppure l'asset stabile dell'ultima release GitHub.

Lo script non gestisce password, OAuth o credenziali.

Da un checkout del repository:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

Comandi utili:

```bash
./scripts/install.sh --check       # controlli, senza modifiche
./scripts/install.sh --deps        # prepara KDE PIM / Akonadi
./scripts/install.sh --calendars   # cambia i calendari mostrati da SPA
./scripts/install.sh --widget      # installa/aggiorna solo il plasmoide
```

### Installazione diretta del plasmoide

Se KDE PIM/Akonadi e `pimevents` sono già configurati, puoi scaricare l'asset stabile dalla [release più recente](https://github.com/Omar-Ceretta/simple-plasma-agenda/releases/latest/) e installarlo con:

```bash
kpackagetool6 -t Plasma/Applet -i Simple-Plasma-Agenda.plasmoid
```

L'installazione per utente finisce sotto:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Poi: **Desktop → Entra in modalità di modifica → Aggiungi o gestisci oggetti → Simple Plasma Agenda → Esci dalla modalità di modifica**.

Se KOrganizer vede gli eventi ma SPA resta vuota, esegui di nuovo il selettore:

```bash
/tmp/simple-plasma-agenda-install.sh --calendars
```

oppure, dal repository:

```bash
./scripts/install.sh --calendars
```

### Dipendenze manuali

L'installer è preferibile; questi sono i comandi equivalenti usati nei test:

| Sistema | Comando |
| --- | --- |
| Fedora | `sudo dnf install akonadi-server kdepim-runtime kdepim-addons korganizer` |
| Debian / Ubuntu / Kubuntu / KDE neon / TUXEDO OS | `sudo apt update && sudo apt install akonadi-server kdepim-runtime kdepim-addons korganizer` |
| Arch Linux | `sudo pacman -Syu --needed akonadi kdepim-runtime kdepim-addons korganizer` |
| openSUSE Tumbleweed | `sudo zypper refresh && sudo zypper dist-upgrade && sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer` |
| openSUSE Leap | `sudo zypper refresh && sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer` |

Non avviare Akonadi come root.

### Aggiungere un calendario con KOrganizer

Per Google Calendar:

1. **KOrganizer → Impostazioni → Configura KOrganizer… → Generale → Calendari → Aggiungi…**
2. scegli **Google Groupware**, poi **Configura**;
3. completa l'accesso nel browser;
4. torna in KOrganizer, usa **Applica / OK** e attendi che gli eventi siano visibili;
5. nell'installer conferma il checkpoint e scegli le collection desiderate nel selettore Akonadi.

Nello stesso dialogo puoi aggiungere DAV/CalDAV (per esempio Nextcloud), iCalendar o sorgenti locali. Merkuro può usare le stesse risorse Akonadi, ma KOrganizer resta il percorso consigliato perché SPA lo usa anche per il clic sugli eventi.

### Note di funzionamento

- Il normale caricamento degli eventi passa sempre da Akonadi/`pimevents`.
- Refresh manuale e auto-refresh forzano solo risorse `akonadi_google_resource_*`; le altre sorgenti usano i propri meccanismi di sincronizzazione.
- Il clic apre **il giorno** in KOrganizer, non il singolo editor dell'evento: il wrapper QML del calendario Plasma non espone al plasmoide un UID Akonadi originale utilizzabile per quell'azione.
- La selezione dei calendari resta volutamente fuori dalle impostazioni permanenti del plasmoide.

## Ambienti testati

Test reali completati su **Fedora KDE 44, Kubuntu 26.04 LTS, Arch Linux, openSUSE Tumbleweed, openSUSE Leap 16.0, TUXEDO OS e KDE neon**. Vedi [`TESTING.md`](TESTING.md) per versioni Plasma e livello di test (E2E / smoke).

## Licenza e provenienza

Simple Plasma Agenda è distribuito con licenza **GPL-3.0** ed è un fork profondamente modificato di **macOS Calendar 1.1** di Jack Faith (`jaxparrow07`). Vedi [`NOTICE.md`](NOTICE.md).

Lo sviluppo è stato svolto con assistenza di OpenAI ChatGPT sotto direzione e verifica umana. Vedi [`AI_ASSISTED_DEVELOPMENT.md`](AI_ASSISTED_DEVELOPMENT.md).

---

## English

**Simple Plasma Agenda** is a **KDE Plasma 6** desktop widget that shows upcoming events already available through **KDE PIM / Akonadi**.

It is intentionally an agenda, not a full calendar: no month view, no account management and no permanent calendar-source selector inside the widget.

Current release: **0.2.22**.

### Features

- look-ahead: **1, 3, 5, 7, 14, 21 or 28 days**;
- **TODAY**, **TOMORROW** and following dates;
- optional week separators and Monday- or Sunday-first weeks;
- solid or translucent background with three transparency levels, system/light/dark colors;
- optional title, Compact / Normal / Airy density and Small / Normal / Large event text;
- events starting soon/in progress use KDE semantic colors; completed events dim after their actual end time;
- optional subtle sound 15 minutes before timed events, disabled by default;
- hover, keyboard focus and Enter/Space activation;
- click an event → open its **day** in KOrganizer;
- manual refresh for Google Akonadi resources;
- optional Google auto-refresh every 5 minutes, with the first sync delayed by 20 seconds;
- Italian localization.

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

Simple Plasma Agenda does not connect directly to remote services, manage credentials or query the Akonadi database. Accounts and resources remain managed by **Akonadi / KOrganizer**.

## Installation

### Assisted installation — recommended

This is also the recommended path when starting from Plasma without KDE PIM/Akonadi.

With `curl`:

```bash
curl -fsSLo /tmp/simple-plasma-agenda-install.sh \
  https://raw.githubusercontent.com/Omar-Ceretta/simple-plasma-agenda/main/scripts/install.sh \
  && chmod +x /tmp/simple-plasma-agenda-install.sh \
  && /tmp/simple-plasma-agenda-install.sh
```

Or with `wget`:

```bash
wget -qO /tmp/simple-plasma-agenda-install.sh \
  https://raw.githubusercontent.com/Omar-Ceretta/simple-plasma-agenda/main/scripts/install.sh \
  && chmod +x /tmp/simple-plasma-agenda-install.sh \
  && /tmp/simple-plasma-agenda-install.sh
```

The script is saved as a normal file in `/tmp`, so you can inspect it before running it; `curl | bash` is not used.

The installer:

- checks Plasma 6 and detects `dnf`, `apt`, `pacman` or `zypper`;
- installs KDE PIM/Akonadi only after confirmation before `sudo`;
- verifies that KOrganizer can actually run and, when needed, offers a coherent system update;
- on Tumbleweed, aligns the rolling snapshot with `zypper refresh` + `zypper dist-upgrade` before PIM installation;
- opens KOrganizer and gives a short calendar-setup guide;
- opens a temporary selector for the Akonadi collections SPA should display;
- saves the global `pimevents` selection and reloads Plasma only when needed;
- installs/updates the widget, using local files from a checkout or the stable asset from the latest GitHub release.

The script never handles passwords, OAuth choices or credentials.

From a repository checkout:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

Useful modes:

```bash
./scripts/install.sh --check       # read-only checks
./scripts/install.sh --deps        # prepare KDE PIM / Akonadi
./scripts/install.sh --calendars   # change the calendars shown by SPA
./scripts/install.sh --widget      # install/update only the widget
```

### Direct widget installation

If KDE PIM/Akonadi and `pimevents` are already configured, download the stable asset from the [latest release](https://github.com/Omar-Ceretta/simple-plasma-agenda/releases/latest/download/Simple-Plasma-Agenda.plasmoid) and install it with:

```bash
kpackagetool6 -t Plasma/Applet -i Simple-Plasma-Agenda.plasmoid
```

Per-user installation goes under:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Then: **Desktop → Enter Edit Mode → Add or Manage Widgets → Simple Plasma Agenda → Exit Edit Mode**.

If KOrganizer sees the events but SPA stays empty, run the selector again:

```bash
/tmp/simple-plasma-agenda-install.sh --calendars
```

or, from the repository:

```bash
./scripts/install.sh --calendars
```

### Manual dependencies

The installer is preferred; these are the equivalent commands used in testing:

| System | Command |
| --- | --- |
| Fedora | `sudo dnf install akonadi-server kdepim-runtime kdepim-addons korganizer` |
| Debian / Ubuntu / Kubuntu / KDE neon / TUXEDO OS | `sudo apt update && sudo apt install akonadi-server kdepim-runtime kdepim-addons korganizer` |
| Arch Linux | `sudo pacman -Syu --needed akonadi kdepim-runtime kdepim-addons korganizer` |
| openSUSE Tumbleweed | `sudo zypper refresh && sudo zypper dist-upgrade && sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer` |
| openSUSE Leap | `sudo zypper refresh && sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer` |

Do not start Akonadi as root.

### Add a calendar with KOrganizer

For Google Calendar:

1. **KOrganizer → Settings → Configure KOrganizer… → General → Calendars → Add…**
2. choose **Google Groupware**, then **Configure**;
3. complete sign-in in the browser;
4. return to KOrganizer, use **Apply / OK** and wait until events are visible;
5. confirm the installer checkpoint and choose the desired collections in the Akonadi selector.

The same dialog can add DAV/CalDAV (for example Nextcloud), iCalendar or local resources. Merkuro can use the same Akonadi resources, but KOrganizer remains the recommended setup path because SPA also uses it when an event is clicked.

### Behavior notes

- Normal event loading always goes through Akonadi/`pimevents`.
- Manual refresh and auto-refresh only force `akonadi_google_resource_*`; other sources use their own synchronization mechanisms.
- Clicking opens **the day** in KOrganizer, not the individual event editor: Plasma's calendar QML wrapper does not expose a usable original Akonadi UID to the widget.
- Calendar selection intentionally remains outside the widget's permanent settings.

## Tested environments

Real tests were completed on **Fedora KDE 44, Kubuntu 26.04 LTS, Arch Linux, openSUSE Tumbleweed, openSUSE Leap 16.0, TUXEDO OS and KDE neon**. See [`TESTING.md`](TESTING.md) for Plasma versions and test level (E2E / smoke).

## License and provenance

Simple Plasma Agenda is released under **GPL-3.0** and is a deeply modified fork of **macOS Calendar 1.1** by Jack Faith (`jaxparrow07`). See [`NOTICE.md`](NOTICE.md).

Development has used OpenAI ChatGPT assistance under human direction and review. See [`AI_ASSISTED_DEVELOPMENT.md`](AI_ASSISTED_DEVELOPMENT.md).
