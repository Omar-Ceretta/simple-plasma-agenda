# Changelog

## Italiano

### 0.2.21 — 2026-08-26

- Dimensione iniziale ridotta a **19 × 21** unità Kirigami.
- Coefficienti responsive ricalibrati per mantenere invariata la resa tipografica predefinita.
- Tooltip del titolo aggiornato a: **«Clicca su un evento per aprirne il giorno su KOrganizer»**.
- PASS completo su TUXEDO OS Debian-based / Plasma 6.7.2 e KDE neon User Edition 24.04 / Plasma 6.7.4.
- Aggiunto `scripts/install.sh`: installer assistito con rilevamento `dnf` / `apt` / `pacman` / `zypper`, consenso prima di `sudo` e checkpoint manuale prima dell’installazione del plasmoide.
- `install.sh` reso utilizzabile anche come script standalone: fuori dal repository scarica automaticamente `Simple-Plasma-Agenda.plasmoid` dall'ultima release GitHub.
- `scripts/package.sh` genera sia l'artefatto versionato sia il nome stabile `Simple-Plasma-Agenda.plasmoid` destinato alle release.
- README ampliato con installazione rapida via `curl`/`wget` e procedura passo passo per configurare Google Calendar in KOrganizer, con Merkuro indicato come alternativa.
- Aggiunto un selettore grafico temporaneo delle collection Akonadi, eseguito tramite `plasmawindowed`, per scegliere quali calendari fornire a `pimevents` senza usare l'Orologio digitale.
- Aggiunto `install.sh --calendars` per riaprire il selettore in seguito; la configurazione viene salvata con KConfig (`PIMEventsPlugin/calendars`) senza chiamare `PimCalendarsModel::saveConfig()`.
- Corretto il percorso Google in KOrganizer: **Aggiungi → Google Groupware → Configura → Applica/OK**.

### 0.2.20 — 2026-08-26

- Prima riduzione della geometria iniziale da **22 × 26** a **21 × 24**.
- Versione in `metadata.json` riallineata alla versione di sviluppo.
- Build intermedia, sostituita dalla 0.2.21 prima del test TUXEDO.

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

### 0.2.21 — 2026-08-26

- Reduced the initial size to **19 × 21** Kirigami grid units.
- Recalibrated responsive coefficients to preserve the default typography.
- Updated the title tooltip to: **“Clicca su un evento per aprirne il giorno su KOrganizer”**.
- Full PASS on TUXEDO OS Debian-based / Plasma 6.7.2 and KDE neon User Edition 24.04 / Plasma 6.7.4.
- Added `scripts/install.sh`: assisted installer with `dnf` / `apt` / `pacman` / `zypper` detection, confirmation before `sudo`, and a manual checkpoint before widget installation.
- Made `install.sh` usable as a standalone script: outside a repository checkout it automatically downloads `Simple-Plasma-Agenda.plasmoid` from the latest GitHub release.
- `scripts/package.sh` now creates both the versioned artifact and the stable `Simple-Plasma-Agenda.plasmoid` release asset.
- Expanded the README with quick `curl`/`wget` installation and step-by-step Google Calendar setup in KOrganizer, with Merkuro documented as an alternative.
- Added a temporary graphical Akonadi collection selector, run through `plasmawindowed`, to choose which calendars are exposed to `pimevents` without using the Digital Clock.
- Added `install.sh --calendars` to reopen the selector later; configuration is stored through KConfig (`PIMEventsPlugin/calendars`) without calling `PimCalendarsModel::saveConfig()`.
- Corrected the Google setup path in KOrganizer: **Add → Google Groupware → Configure → Apply/OK**.

### 0.2.20 — 2026-08-26

- First reduction of the initial geometry from **22 × 26** to **21 × 24**.
- Aligned `metadata.json` with the development version.
- Intermediate build superseded by 0.2.21 before the TUXEDO test.

### 0.2.19 — 2026-08-25

- Delayed the first automatic Google synchronization from 1.5 to **20 seconds** after widget startup.
- Manual refresh remains immediate; later automatic refreshes remain every 5 minutes.
- PASS on Kubuntu 26.04, Arch Linux and openSUSE Tumbleweed.

### 0.2.18 — 2026-08-25

- Improved event-click portability by explicitly launching KOrganizer before KWin window activation.

### 0.2.17 — 2026-08-25

- Replaced Qt-specific `qdbus` commands with `busctl --user`.
- Added hover, keyboard focus, Enter/Space activation and accessibility metadata.
