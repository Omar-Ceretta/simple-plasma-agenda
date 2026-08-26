# Changelog

## Italiano

### 0.2.21 — 2026-08-26

- Dimensione iniziale ridotta a **19 × 21** unità Kirigami.
- Coefficienti responsive ricalibrati per mantenere invariata la resa tipografica predefinita.
- Tooltip del titolo aggiornato a: **«Clicca su un evento per aprirne il giorno su KOrganizer»**.
- PASS completo su TUXEDO OS Debian-based / Plasma 6.7.2 e KDE neon User Edition 24.04 / Plasma 6.7.4.

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
