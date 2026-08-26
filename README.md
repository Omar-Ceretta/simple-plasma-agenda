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

Prima di scegliere il metodo di installazione, fai questa distinzione:

- se i tuoi eventi sono già visibili in **KOrganizer** e nel calendario dell'**Orologio digitale di Plasma**, puoi installare direttamente il plasmoide;
- se non usi ancora KDE PIM / Akonadi, oppure non sai se siano configurati, è consigliata l'**installazione assistita**.

### Installazione assistita — consigliata se parti da Plasma senza PIM

Quando il repository sarà pubblico, il modo più rapido sarà scaricare ed eseguire **solo** `install.sh`.

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

Lo script viene salvato come file normale in `/tmp`: puoi quindi leggerlo prima di eseguirlo. Non viene usato il pattern `curl | bash`.

`install.sh`:

- verifica che il sistema usi Plasma 6;
- riconosce automaticamente la distribuzione e usa il package manager appropriato (`dnf`, `apt`, `pacman` o `zypper`);
- controlla Akonadi, KOrganizer, `busctl` e il plugin Plasma `pimevents`;
- se manca qualcosa, mostra prima i pacchetti che intende installare e **chiede conferma prima di usare `sudo`**;
- avvia Akonadi come utente, se necessario;
- si ferma su un checkpoint manuale per farti configurare e verificare almeno un calendario;
- solo dopo la tua conferma installa o aggiorna Simple Plasma Agenda.

Se lo script è eseguito dentro una copia del repository usa i file locali del plasmoide. Se invece è stato scaricato da solo, al momento dell'installazione recupera automaticamente l'asset stabile:

```text
Simple-Plasma-Agenda.plasmoid
```

dall'ultima release GitHub e lo elimina dalla directory temporanea dopo l'installazione.

Dal repository estratto puoi comunque usare:

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

Lo script **non** configura account, password o credenziali e non sceglie i calendari al posto dell'utente. Se non vuoi installare KDE PIM/Akonadi, rispondi **No** alla richiesta di conferma e non verrà installato nulla.

### Installazione diretta del plasmoide

Se KDE PIM / Akonadi sono già configurati, puoi usare il normale pacchetto `.plasmoid` o, quando disponibile, **Aggiungi elementi grafici… → Scarica nuovi elementi grafici…** in Plasma.

Per il pacchetto scaricato da una release:

```bash
kpackagetool6 -t Plasma/Applet -i Simple-Plasma-Agenda.plasmoid
```

L'installazione per utente finisce sotto:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Poi: **Desktop → Aggiungi elementi grafici… → Simple Plasma Agenda**.

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

KOrganizer è il percorso consigliato perché è ben documentato e perché Simple Plasma Agenda lo apre quando clicchi un evento.

1. Apri **KOrganizer**.
2. Vai in **Impostazioni → Configura KOrganizer… → Generale → Calendari → Aggiungi…**. In alternativa, nel pannello laterale **Gestore calendari**, usa il menu contestuale e scegli **Aggiungi calendario…**.
3. Seleziona **Google Calendars and Tasks** / **Calendari e attività di Google** (il testo può variare leggermente con la lingua dell'interfaccia).
4. Inserisci il tuo account Google quando richiesto.
5. Completa l'accesso e l'autorizzazione nella pagina web aperta dal sistema.
6. Torna in KOrganizer e attendi che la risorsa Google risulti pronta.
7. Nel Gestore calendari, verifica che i calendari Google che vuoi usare siano abilitati.
8. Controlla che almeno alcuni eventi reali siano visibili in KOrganizer.
9. Apri il calendario dell'**Orologio digitale di Plasma** e verifica, preferibilmente, che gli stessi eventi PIM compaiano anche lì.

Solo a questo punto ha senso installare o aggiungere Simple Plasma Agenda al desktop. Il plasmoide mostra ciò che Akonadi e `pimevents` gli forniscono: se gli eventi non sono visibili a monte, non può recuperarli autonomamente.

Per altri servizi, nello stesso dialogo puoi scegliere per esempio una risorsa **DAV groupware** per CalDAV / Nextcloud, un file o una cartella iCalendar, oppure una sorgente locale.

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

Before choosing an installation method, make this distinction:

- if your events are already visible in **KOrganizer** and in Plasma's **Digital Clock** calendar, you can install the widget directly;
- if you do not use KDE PIM / Akonadi yet, or you are unsure whether they are configured, the **assisted installation** is recommended.

### Assisted installation — recommended for Plasma systems without PIM

Once the repository is public, the quickest method will download and run **only** `install.sh`.

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

- checks that the system is running Plasma 6;
- automatically detects the distribution and uses the appropriate package manager (`dnf`, `apt`, `pacman` or `zypper`);
- checks Akonadi, KOrganizer, `busctl` and Plasma's `pimevents` plugin;
- if something is missing, shows the packages it intends to install and **asks before using `sudo`**;
- starts Akonadi as the current user when needed;
- stops at a manual checkpoint so you can configure and verify at least one calendar;
- only after your confirmation installs or updates Simple Plasma Agenda.

When the script is run inside a repository checkout, it uses the local widget files. When it is downloaded standalone, it fetches the stable release asset:

```text
Simple-Plasma-Agenda.plasmoid
```

from the latest GitHub release and removes the temporary download after installation.

From an extracted repository you can still use:

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

The script does **not** configure accounts, passwords or credentials, and it does not choose calendar sources for you. If you do not want KDE PIM/Akonadi installed, answer **No** at the confirmation prompt and nothing will be installed.

### Direct widget installation

If KDE PIM / Akonadi are already configured, use the normal `.plasmoid` package or, once available, Plasma's **Add Widgets… → Get New Widgets…** interface.

For a package downloaded from a release:

```bash
kpackagetool6 -t Plasma/Applet -i Simple-Plasma-Agenda.plasmoid
```

Per-user installation lives under:

```text
~/.local/share/plasma/plasmoids/com.simple.plasma.agenda/
```

Then use: **Desktop → Add Widgets… → Simple Plasma Agenda**.

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

KOrganizer is the recommended path because it is well documented and because Simple Plasma Agenda opens it when you click an event.

1. Open **KOrganizer**.
2. Go to **Settings → Configure KOrganizer… → General → Calendars → Add…**. Alternatively, use **Add Calendar…** from the context menu in the **Calendar Manager** sidebar.
3. Select **Google Calendars and Tasks**.
4. Enter your Google account when requested.
5. Complete sign-in and authorization in the web page opened by the system.
6. Return to KOrganizer and wait until the Google resource is ready.
7. In Calendar Manager, make sure the Google calendars you want to use are enabled.
8. Verify that some real events are visible in KOrganizer.
9. Preferably open Plasma's **Digital Clock** calendar as well and verify that the same PIM events appear there.

Only at this point does it make sense to install or add Simple Plasma Agenda to the desktop. The widget displays what Akonadi and `pimevents` provide; if events are not visible upstream, the widget cannot fetch them independently.

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
