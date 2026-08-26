# Simple Plasma Agenda — VM quick testing

## Italiano

Questo file è un aiuto temporaneo per i test in VM, non documentazione destinata all'utente finale.

### Percorso rapido

Dalla root del repository:

```bash
chmod +x scripts/vm-test-setup.sh
./scripts/vm-test-setup.sh all
```

`all`:

1. rileva la distribuzione da `/etc/os-release`;
2. installa le dipendenze PIM/Akonadi usate nei test completi;
3. avvia Akonadi quando possibile;
4. reinstalla il plasmoide, pulisce la cache QML, riavvia Plasma e stampa un preflight.

L'autenticazione degli account calendario resta manuale.

> Se il plasmoide è già sul desktop, rimuovi quell'istanza prima di usare `fresh` o `all`.

```bash
rm -rf ~/.cache/plasmashell/qmlcache
systemctl --user restart plasma-plasmashell.service
```

### Comandi dello script

```bash
./scripts/vm-test-setup.sh deps
./scripts/vm-test-setup.sh install
./scripts/vm-test-setup.sh fresh
./scripts/vm-test-setup.sh check
./scripts/vm-test-setup.sh all
./scripts/vm-test-setup.sh download [branch]
```

### Dipendenze per distribuzione

Fedora:

```bash
sudo dnf install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
```

Debian / Ubuntu / Kubuntu / KDE neon / TUXEDO OS:

```bash
sudo apt update
sudo apt install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
```

Arch Linux:

```bash
sudo pacman -Syu --needed akonadi kdepim-runtime kdepim-addons korganizer curl unzip
```

openSUSE:

```bash
sudo zypper refresh
sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer curl unzip
```

### Configurazione calendario: passaggio manuale

Apri KOrganizer e configura almeno una risorsa Akonadi. Prima di testare Simple Plasma Agenda, verifica che gli eventi siano visibili in KOrganizer e, preferibilmente, nell'Orologio digitale di Plasma.

# Open KOrganizer and go to:

Settings → Configure KOrganizer… → General → Calendars → Add…

Alternatively, in KOrganizer's Calendar Manager sidebar, use Add Calendar….

### Preflight

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

### Checklist VM

- eventi visibili in KOrganizer;
- stessi eventi nell'Orologio digitale di Plasma;
- stessi eventi in Simple Plasma Agenda;
- 1 / 3 / 5 / 7 / 14 / 21 / 28 giorni;
- densità e dimensioni testo;
- attenuazione eventi conclusi;
- hover;
- Tab / Shift+Tab e Invio/Spazio;
- clic evento → giorno corretto in KOrganizer;
- refresh Google manuale;
- refresh Google automatico;
- logout/login con auto-refresh attivo;
- `akonadictl status` ancora `running / running` dopo il login;
- più sorgenti calendario insieme, quando disponibili.

### VM già completate

- Fedora KDE 44 — PASS;
- Kubuntu 26.04 LTS / Plasma 6.6.4 — PASS;
- Arch Linux + KDE — PASS;
- openSUSE Tumbleweed / Plasma 6.7.4 — PASS;
- TUXEDO OS Debian base `forky` / Plasma 6.7.2 — PASS;
- KDE neon User Edition 24.04 / Plasma 6.7.4 — PASS.

---

## English

This file is a temporary helper for VM testing, not end-user documentation.

### Fast path

From the repository root:

```bash
chmod +x scripts/vm-test-setup.sh
./scripts/vm-test-setup.sh all
```

`all`:

1. detects the distribution from `/etc/os-release`;
2. installs the PIM/Akonadi dependencies used for full tests;
3. starts Akonadi when possible;
4. reinstalls the widget, clears the QML cache, restarts Plasma and prints a preflight report.

Calendar-account authentication remains manual.

> If the widget is already on the desktop, remove that instance before using `fresh` or `all`.

```bash
rm -rf ~/.cache/plasmashell/qmlcache
systemctl --user restart plasma-plasmashell.service
```

### Script commands

```bash
./scripts/vm-test-setup.sh deps
./scripts/vm-test-setup.sh install
./scripts/vm-test-setup.sh fresh
./scripts/vm-test-setup.sh check
./scripts/vm-test-setup.sh all
./scripts/vm-test-setup.sh download [branch]
```

### Distribution dependencies

Fedora:

```bash
sudo dnf install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
```

Debian / Ubuntu / Kubuntu / KDE neon / TUXEDO OS:

```bash
sudo apt update
sudo apt install -y akonadi-server kdepim-runtime kdepim-addons korganizer curl unzip
```

Arch Linux:

```bash
sudo pacman -Syu --needed akonadi kdepim-runtime kdepim-addons korganizer curl unzip
```

openSUSE:

```bash
sudo zypper refresh
sudo zypper install akonadi kdepim-runtime kdepim-addons korganizer curl unzip
```

### Calendar setup: manual step

Open KOrganizer and configure at least one Akonadi resource. Before testing Simple Plasma Agenda, verify that events are visible in KOrganizer and, preferably, in Plasma's Digital Clock.

Open KOrganizer and go to:

Settings → Configure KOrganizer… → General → Calendars → Add…

Alternatively, in KOrganizer's Calendar Manager sidebar, use Add Calendar….

### Preflight

```bash
cat /etc/os-release
plasmashell --version
akonadictl status
command -v busctl
find /usr -type f -path '*/plasmacalendarplugins/pimevents.so' -print 2>/dev/null
```

### VM checklist

- events visible in KOrganizer;
- same events in Plasma's Digital Clock;
- same events in Simple Plasma Agenda;
- 1 / 3 / 5 / 7 / 14 / 21 / 28 day ranges;
- density and text-size settings;
- completed-event dimming;
- hover;
- Tab / Shift+Tab and Enter/Space;
- event click → correct day in KOrganizer;
- manual Google refresh;
- automatic Google refresh;
- logout/login with auto-refresh enabled;
- `akonadictl status` still `running / running` after login;
- multiple calendar sources together when available.

### Completed VMs

- Fedora KDE 44 — PASS;
- Kubuntu 26.04 LTS / Plasma 6.6.4 — PASS;
- Arch Linux + KDE — PASS;
- openSUSE Tumbleweed / Plasma 6.7.4 — PASS;
- TUXEDO OS Debian base `forky` / Plasma 6.7.2 — PASS;
- KDE neon User Edition 24.04 / Plasma 6.7.4 — PASS.
