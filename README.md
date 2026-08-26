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

Account e sorgenti restano gestiti da **Akonadi / KOrganizer**. Simple Plasma Agenda non contiene un selettore di calendari: l'installer assistito può inizializzare, una tantum, quali collection Akonadi il backend Plasma `pimevents` deve esporre al plasmoide.

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

Prima di scegliere il metodo di installazione:

- se KDE PIM/Akonadi è già configurato **e `pimevents` ha già una selezione di calendari**, puoi installare direttamente il plasmoide;
- se parti da Plasma senza PIM, oppure gli eventi sono visibili in KOrganizer ma non sai se `pimevents` sia configurato, usa l'**installazione assistita**.

### Installazione assistita — consigliata

Il modo più rapido è scaricare ed eseguire **solo** `install.sh`.

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

Lo script viene salvato come file normale in `/tmp`, quindi puoi leggerlo prima di eseguirlo. Non viene usato il pattern `curl | bash`.

`install.sh`:

- verifica Plasma 6;
- rileva automaticamente `dnf`, `apt`, `pacman` o `zypper`;
- controlla Akonadi, KOrganizer, `busctl` e `pimevents`;
- se manca qualcosa, mostra i pacchetti e **chiede conferma prima di usare `sudo`**;
- avvia Akonadi come utente, se necessario;
- prosegue come un piccolo **wizard in 5 passaggi**, mostrando via via ciò che è già completato;
- apre automaticamente KOrganizer e, solo se serve, mostra una breve traccia per aggiungere un calendario (per esempio Google Groupware);
- apre poi un piccolo **selettore temporaneo dei calendari Akonadi**: scegli solo quelli che vuoi mostrare in Simple Plasma Agenda;
- registra quella scelta nella normale configurazione globale di `pimevents`, senza usare `PimCalendarsModel::saveConfig()` e senza interrogare direttamente il database Akonadi;
- elimina il selettore temporaneo e installa/aggiorna il plasmoide.

Il selettore serve solo durante la configurazione. **Non è necessario abilitare gli eventi PIM nell'Orologio digitale di Plasma.**

Se lo script è eseguito dentro una copia del repository usa i file locali. Se è stato scaricato da solo, recupera automaticamente `Simple-Plasma-Agenda.plasmoid` dall'ultima release GitHub e cancella il download temporaneo dopo l'installazione.

Dal repository:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

Comandi aggiuntivi:

```bash
./scripts/install.sh --check       # solo controlli
./scripts/install.sh --deps        # prepara solo KDE PIM / Akonadi
./scripts/install.sh --calendars   # cambia i calendari mostrati da SPA
./scripts/install.sh --widget      # installa/aggiorna solo il plasmoide
```

Lo script **non** configura account, password, OAuth o credenziali. La scelta dei calendari avviene localmente leggendo solo i nomi e gli ID delle collection Akonadi già configurate. Se non vuoi installare KDE PIM/Akonadi, rispondi **No** alla richiesta di conferma.

### Installazione diretta del plasmoide

Se KDE PIM/Akonadi e `pimevents` sono già configurati, puoi usare il normale pacchetto `.plasmoid` o **Aggiungi elementi grafici… → Scarica nuovi elementi grafici…** in Plasma.

```bash
kpackagetool6 -t Plasma/Applet -i Simple-Plasma-Agenda.plasmoid
```

L'installazione per utente finisce sotto:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Poi: **Desktop → Aggiungi elementi grafici… → Simple Plasma Agenda**.

Se gli eventi sono visibili in KOrganizer ma SPA resta vuota, inizializza o modifica la selezione di `pimevents` con:

```bash
/tmp/simple-plasma-agenda-install.sh --calendars
```

oppure, da un checkout del repository:

```bash
./scripts/install.sh --calendars
```

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

### Aggiungere un calendario: esempio Google Calendar con KOrganizer

KOrganizer è il percorso consigliato perché Simple Plasma Agenda lo usa anche quando clicchi un evento.

1. Apri **KOrganizer**.
2. Vai in **Impostazioni → Configura KOrganizer… → Generale → Calendari → Aggiungi…**.
3. Scegli **Google Groupware**.
4. Seleziona la nuova risorsa Google Groupware e premi **Configura**.
5. Completa accesso e autorizzazione Google nella pagina web aperta dal sistema.
6. Torna in KOrganizer e premi **Applica / OK**.
7. Attendi che la risorsa risulti pronta e verifica che gli eventi reali siano visibili in KOrganizer.
8. Se stai usando `install.sh`, KOrganizer viene aperto automaticamente e il terminale ti guida con una domanda alla volta. Quando confermi che il calendario è pronto, compare il selettore grafico con le collection Akonadi disponibili: scegli **solo** quelle che vuoi vedere in Simple Plasma Agenda.

Non serve attivare PIM Events nell'Orologio digitale. Il selettore dell'installer inizializza direttamente la lista globale usata da `pimevents`.

Per altri servizi puoi aggiungere, nello stesso dialogo, una risorsa **DAV groupware** per CalDAV / Nextcloud, un file o una cartella iCalendar oppure una sorgente locale.

### Posso usare Merkuro?

Sì. Merkuro usa anch'esso Akonadi e supporta calendari online come Google, Nextcloud e CalDAV. Nelle versioni attuali il percorso per aggiungere un account è normalmente:

```text
Impostazioni → Configura Merkuro → Account → Aggiungi account
```

Per Simple Plasma Agenda, però, **KOrganizer resta il percorso consigliato per la prima configurazione**: è quello richiesto anche dal clic sugli eventi ed è il flusso che abbiamo usato nei test. Una risorsa Akonadi aggiunta in KOrganizer diventa normalmente disponibile anche in Merkuro, quindi puoi poi usare liberamente l'applicazione che preferisci.

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

Accounts and calendar resources remain managed by **Akonadi / KOrganizer**. Simple Plasma Agenda has no calendar selector of its own: the assisted installer can initialize, once, which Akonadi collections Plasma's `pimevents` backend should expose to the widget.

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

Before choosing an installation method:

- if KDE PIM/Akonadi is already configured **and `pimevents` already has a calendar selection**, you can install the widget directly;
- if you start from Plasma without PIM, or events are visible in KOrganizer but you are unsure whether `pimevents` is configured, use the **assisted installation**.

### Assisted installation — recommended

The quickest method downloads and runs **only** `install.sh`.

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

The script is saved as a normal file under `/tmp`, so you can inspect it before running it. The project does not use the `curl | bash` pattern.

`install.sh`:

- checks Plasma 6;
- automatically detects `dnf`, `apt`, `pacman` or `zypper`;
- checks Akonadi, KOrganizer, `busctl` and `pimevents`;
- if something is missing, shows the packages and **asks before using `sudo`**;
- starts Akonadi as the current user when needed;
- continues as a small **5-step wizard**, showing progress as each stage is completed;
- opens KOrganizer automatically and, only when needed, shows a short path for adding a calendar (for example Google Groupware);
- then opens a small **temporary Akonadi calendar selector**: choose only the calendars you want Simple Plasma Agenda to display;
- stores that choice in the normal global `pimevents` configuration, without using `PimCalendarsModel::saveConfig()` and without querying the Akonadi database directly;
- removes the temporary selector and installs/updates the widget.

The selector is only a setup tool. **PIM events do not need to be enabled in Plasma's Digital Clock.**

When run inside a repository checkout, the script uses local widget files. When downloaded standalone, it fetches `Simple-Plasma-Agenda.plasmoid` from the latest GitHub release and removes the temporary download after installation.

From the repository:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

Additional modes:

```bash
./scripts/install.sh --check       # checks only
./scripts/install.sh --deps        # prepare KDE PIM / Akonadi only
./scripts/install.sh --calendars   # change the calendars shown by SPA
./scripts/install.sh --widget      # install/update the widget only
```

The script does **not** configure accounts, passwords, OAuth or credentials. Calendar selection is local and reads only names and IDs of already configured Akonadi collections. If you do not want KDE PIM/Akonadi installed, answer **No** at the confirmation prompt.

### Direct widget installation

If KDE PIM/Akonadi and `pimevents` are already configured, use the normal `.plasmoid` package or Plasma's **Add Widgets… → Get New Widgets…** interface.

```bash
kpackagetool6 -t Plasma/Applet -i Simple-Plasma-Agenda.plasmoid
```

Per-user installation lives under:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Then use: **Desktop → Add Widgets… → Simple Plasma Agenda**.

If events are visible in KOrganizer but SPA remains empty, initialize or change the `pimevents` selection with:

```bash
/tmp/simple-plasma-agenda-install.sh --calendars
```

or, from a repository checkout:

```bash
./scripts/install.sh --calendars
```

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

### Add a calendar: Google Calendar example with KOrganizer

KOrganizer is the recommended path because Simple Plasma Agenda also uses it when you click an event.

1. Open **KOrganizer**.
2. Go to **Settings → Configure KOrganizer… → General → Calendars → Add…**.
3. Choose **Google Groupware**.
4. Select the new Google Groupware resource and click **Configure**.
5. Complete Google sign-in and authorization in the web page opened by the system.
6. Return to KOrganizer and click **Apply / OK**.
7. Wait until the resource is ready and verify that real events are visible in KOrganizer.
8. If you are using `install.sh`, KOrganizer is opened automatically and the terminal guides you one question at a time. Once you confirm that the calendar is ready, the graphical selector lists the available Akonadi collections: choose **only** those you want Simple Plasma Agenda to display.

You do not need to enable PIM Events in the Digital Clock. The installer selector initializes the global list used by `pimevents` directly.

For other services, the same dialog can add a **DAV groupware** resource for CalDAV / Nextcloud, an iCalendar file or folder, or a local source.

### Can I use Merkuro?

Yes. Merkuro also uses Akonadi and supports online calendars including Google, Nextcloud and CalDAV. In current versions, the account path is normally:

```text
Settings → Configure Merkuro → Accounts → Add Account
```

For Simple Plasma Agenda, however, **KOrganizer remains the recommended first-setup path**: it is also required for the widget's event-click action and it is the workflow used in our tests. An Akonadi resource added in KOrganizer normally becomes available in Merkuro as well, so you can then use whichever calendar application you prefer.

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
