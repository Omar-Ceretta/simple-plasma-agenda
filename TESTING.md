# Testing matrix

This file records **actual testing separately from planned testing**. A platform should be marked as passed only after the listed checks have been performed on that environment.

Legend: ✅ passed · ⚠️ partial/issues · ❌ failed · ⏳ planned/not yet tested

| Environment | Type | Plasma version | Agenda display | Google manual sync | Google 5-min auto sync | Status / notes |
|---|---|---:|---|---|---|---|
| Fedora KDE 44 | Main development system | _record exact version_ | ✅ | ✅ | ✅ | Existing configured system; not a fresh install |
| Fedora KDE 44 | Fresh VM | _TBD_ | ⏳ | ⏳ | ⏳ | Planned clean-install test |
| Kubuntu | Fresh VM | _TBD_ | ⏳ | ⏳ | ⏳ | Planned |
| Arch Linux + KDE Plasma | Fresh VM | _TBD_ | ⏳ | ⏳ | ⏳ | Planned |
| TUXEDO OS | Fresh VM | _TBD_ | ⏳ | ⏳ | ⏳ | Planned |
| openSUSE Tumbleweed KDE | Fresh VM | _TBD_ | ⏳ | ⏳ | ⏳ | Planned |
| KDE neon | Fresh VM | _TBD_ | ⏳ | ⏳ | ⏳ | Optional additional Plasma-focused test |

## Minimum checklist for each environment

- widget appears in *Add Widgets*;
- widget can be added and removed without Plasma errors;
- events already present in Akonadi are shown;
- Today / Tomorrow / localized dates are correct;
- week separators appear correctly;
- 3 / 5 / 7 / 14 day ranges work;
- solid and translucent modes render correctly;
- system/light/dark color modes render correctly;
- manual refresh does not freeze or crash Plasma;
- if Google/Akonadi is configured, manual forced synchronization works;
- if Google/Akonadi is configured, five-minute automatic synchronization works;
- Plasma restart preserves the widget and its settings;
- logs are checked for new QML errors attributable to Simple Plasma Agenda.

## Notes on non-Google sources

The agenda itself is designed to display any events exposed by KDE PIM/Akonadi. Forced remote synchronization is currently implemented and tested only for Akonadi Google resources. CalDAV/Nextcloud, iCalendar, EWS and other resources should be recorded here only after practical testing.
