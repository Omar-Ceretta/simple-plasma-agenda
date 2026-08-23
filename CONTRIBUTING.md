# Contributing

Bug reports, testing results, translations and focused pull requests are welcome.

## Before reporting a bug

Please include:

- distribution and version;
- Plasma version;
- whether the session is Wayland or X11;
- whether the issue occurs on a fresh widget instance;
- relevant `journalctl --user` QML errors, when available;
- whether events are visible in Plasma's Digital Clock / another Akonadi client.

Do **not** include private calendar data, OAuth tokens, passwords or personal event details.

## Code changes

Keep changes small enough to test independently. In particular, modifications to KDE PIM/Akonadi integration or remote synchronization should be tested carefully before being merged.

The widget intentionally avoids editing the enabled PIM calendar selection from its own settings.

## Translations

Translatable strings use the domain:

```text
plasma_applet_com.simple.plasma.agenda
```

Italian source translations are kept under `translate/`, with the compiled runtime catalog under `contents/locale/`.

## AI-assisted contributions

AI assistance is welcome, but contributors remain responsible for reviewing, testing and licensing the code they submit. If an AI system was used substantially for a contribution, a short note in the pull request is appreciated.
