# Changelog

## Italiano

### 0.2.21 — widget 2026-08-26; installer/documentazione aggiornati fino al 2026-08-27

- Dimensione iniziale ridotta a **19 × 21** unità Kirigami, con coefficienti responsive ricalibrati.
- Tooltip del titolo aggiornato a **«Clicca su un evento per aprirne il giorno su KOrganizer»**.
- Aggiunto `scripts/install.sh`, utilizzabile dal repository o come script standalone: rileva `dnf` / `apt` / `pacman` / `zypper`, chiede conferma prima di `sudo` e scarica l'asset stabile della release quando necessario.
- L'installer usa un wizard in 5 passaggi, verifica realmente KOrganizer, apre l'app per la configurazione dell'account e propone un aggiornamento completo se rileva librerie di sistema non allineate.
- Aggiunto un selettore temporaneo delle collection Akonadi (`--calendars`) che configura `PIMEventsPlugin/calendars` senza interrogare il database Akonadi; quando la selezione cambia, Plasma viene ricaricato solo su conferma e senza reboot.
- Su **openSUSE Tumbleweed** l'installer esegue `zypper refresh` + `zypper dist-upgrade` prima dell'installazione PIM; su **Leap** usa il normale percorso `zypper` stabile.
- `scripts/package.sh` genera sia l'artefatto versionato sia `Simple-Plasma-Agenda.plasmoid` con nome stabile per le release.
- Installer validato end-to-end su **Fedora KDE 44, Arch Linux, Kubuntu 26.04, openSUSE Tumbleweed e openSUSE Leap 16.0**; smoke test PASS su **TUXEDO OS Debian base**. Il plasmoide 0.2.21 è inoltre PASS su **KDE neon User Edition 24.04**.
- Documentazione snellita e riallineata al flusso di installazione realmente testato.

### 0.2.20 — 2026-08-26

- Prima riduzione della geometria iniziale da **22 × 26** a **21 × 24**.
- Versione in `metadata.json` riallineata alla versione di sviluppo.
- Build intermedia, sostituita dalla 0.2.21.

### 0.2.19 — 2026-08-25

- Prima sincronizzazione Google automatica ritardata da 1,5 a **20 secondi** dopo l'avvio del plasmoide.
- Refresh manuale ancora immediato; auto-refresh successivi ogni 5 minuti.
- PASS su Kubuntu 26.04, Arch Linux e openSUSE Tumbleweed.

### 0.2.18 — 2026-08-25

- Migliorata la portabilità del clic evento: avvio esplicito di KOrganizer prima dell'attivazione finestra via KWin.

### 0.2.17 — 2026-08-25

- Sostituiti i comandi Qt-specifici `qdbus` con `busctl --user`.
- Aggiunti hover, focus da tastiera, attivazione Invio/Spazio e metadati di accessibilità.

---

## English

### 0.2.21 — widget 2026-08-26; installer/docs updated through 2026-08-27

- Reduced the initial size to **19 × 21** Kirigami grid units and recalibrated responsive coefficients.
- Updated the title tooltip to **“Clicca su un evento per aprirne il giorno su KOrganizer”**.
- Added `scripts/install.sh`, usable from a checkout or standalone: it detects `dnf` / `apt` / `pacman` / `zypper`, asks before `sudo`, and downloads the stable release asset when needed.
- The installer uses a 5-step wizard, performs a real KOrganizer runtime check, opens the app for account setup, and offers a full system update when it detects out-of-sync libraries.
- Added a temporary Akonadi collection selector (`--calendars`) that configures `PIMEventsPlugin/calendars` without querying the Akonadi database; when the selection changes, Plasma is reloaded only after confirmation and without a reboot.
- On **openSUSE Tumbleweed** the installer runs `zypper refresh` + `zypper dist-upgrade` before PIM installation; on **Leap** it uses the normal stable `zypper` path.
- `scripts/package.sh` now creates both the versioned artifact and the stable `Simple-Plasma-Agenda.plasmoid` release name.
- Installer validated end-to-end on **Fedora KDE 44, Arch Linux, Kubuntu 26.04, openSUSE Tumbleweed and openSUSE Leap 16.0**; smoke test PASS on **TUXEDO OS, Debian base**. The 0.2.21 widget is also PASS on **KDE neon User Edition 24.04**.
- Documentation was trimmed and aligned with the installation flow actually tested.

### 0.2.20 — 2026-08-26

- First reduction of the initial geometry from **22 × 26** to **21 × 24**.
- Aligned `metadata.json` with the development version.
- Intermediate build superseded by 0.2.21.

### 0.2.19 — 2026-08-25

- Delayed the first automatic Google synchronization from 1.5 to **20 seconds** after widget startup.
- Manual refresh remains immediate; later automatic refreshes remain every 5 minutes.
- PASS on Kubuntu 26.04, Arch Linux and openSUSE Tumbleweed.

### 0.2.18 — 2026-08-25

- Improved event-click portability by explicitly launching KOrganizer before KWin window activation.

### 0.2.17 — 2026-08-25

- Replaced Qt-specific `qdbus` commands with `busctl --user`.
- Added hover, keyboard focus, Enter/Space activation and accessibility metadata.
