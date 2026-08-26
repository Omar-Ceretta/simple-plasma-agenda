#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.simple.plasma.agenda"
REPO_SLUG="Omar-Ceretta/simple-plasma-agenda"
DEFAULT_WIDGET_URL="https://github.com/${REPO_SLUG}/releases/latest/download/Simple-Plasma-Agenda.plasmoid"
WIDGET_URL="${SPA_PLASMOID_URL:-$DEFAULT_WIDGET_URL}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

log()  { printf '\n==> %s\n' "$*"; }
warn() { printf '\nWARNING: %s\n' "$*" >&2; }
die()  { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'USAGE'
Simple Plasma Agenda — assisted installer

Usage:
  ./scripts/install.sh
  ./scripts/install.sh --check
  ./scripts/install.sh --deps
  ./scripts/install.sh --widget
  ./scripts/install.sh --calendars
  ./scripts/install.sh --help

The same script can also be downloaded and run standalone.

Modes:
  (default)  Check the system, offer to install missing KDE PIM/Akonadi
             dependencies, start Akonadi, stop for calendar setup, then
             install/update the widget.
  --check    Read-only preflight report.
  --deps     Check and, if needed, offer to install KDE PIM/Akonadi only.
  --widget     Install/update only the widget. From a repository checkout it
               uses local files; standalone it downloads the latest release asset.
  --calendars  Open the temporary Akonadi calendar selector and update the global
               pimevents calendar list used by Simple Plasma Agenda.

The script never configures calendar accounts, passwords or credentials.
Calendar selection is performed locally from Akonadi collection metadata only.
USAGE
}

load_os_release() {
    [[ -r /etc/os-release ]] || die "/etc/os-release not found"
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_LIKE="${ID_LIKE:-}"
    OS_NAME="${PRETTY_NAME:-$OS_ID}"
}

is_debian_family() {
    [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_ID" == "kubuntu" || "$OS_ID" == "neon" || "$OS_ID" == "tuxedo" || " $OS_LIKE " == *" debian "* || " $OS_LIKE " == *" ubuntu "* ]]
}

detect_package_manager() {
    load_os_release

    case "$OS_ID" in
        fedora|rhel|centos|rocky|almalinux)
            command -v dnf >/dev/null 2>&1 || die "This system looks Fedora/RHEL-based, but dnf was not found."
            PKG_MANAGER="dnf"
            ;;
        arch|manjaro|endeavouros)
            command -v pacman >/dev/null 2>&1 || die "This system looks Arch-based, but pacman was not found."
            PKG_MANAGER="pacman"
            ;;
        opensuse-tumbleweed|opensuse-leap|opensuse|sles)
            command -v zypper >/dev/null 2>&1 || die "This system looks openSUSE-based, but zypper was not found."
            PKG_MANAGER="zypper"
            ;;
        *)
            if is_debian_family; then
                command -v apt-get >/dev/null 2>&1 || die "This system looks Debian/Ubuntu-based, but apt-get was not found."
                PKG_MANAGER="apt"
            elif command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
            elif command -v apt-get >/dev/null 2>&1; then
                PKG_MANAGER="apt"
            elif command -v pacman >/dev/null 2>&1; then
                PKG_MANAGER="pacman"
            elif command -v zypper >/dev/null 2>&1; then
                PKG_MANAGER="zypper"
            else
                die "No supported package manager found (dnf, apt, pacman, zypper)."
            fi
            ;;
    esac
}

package_list() {
    case "$PKG_MANAGER" in
        dnf|apt)
            printf '%s\n' "akonadi-server kdepim-runtime kdepim-addons korganizer"
            ;;
        pacman|zypper)
            printf '%s\n' "akonadi kdepim-runtime kdepim-addons korganizer"
            ;;
        *)
            die "Internal error: unsupported package manager '$PKG_MANAGER'."
            ;;
    esac
}

find_pimevents() {
    local path
    for path in /usr/lib /usr/lib64 /usr/lib/x86_64-linux-gnu; do
        [[ -d "$path" ]] || continue
        find "$path" -type f -path '*/plasmacalendarplugins/pimevents.so' -print -quit 2>/dev/null || true
    done | head -n 1
}

pimevents_calendar_selection() {
    command -v kreadconfig6 >/dev/null 2>&1 || return 0
    kreadconfig6 --file plasmashellrc --group PIMEventsPlugin --key calendars 2>/dev/null || true
}

detect_pim_calendars_qml_module() {
    local root qt_root
    local -a roots=(
        /usr/lib64/qt6/qml
        /usr/lib/qt6/qml
        /usr/lib/x86_64-linux-gnu/qt6/qml
        /usr/lib/aarch64-linux-gnu/qt6/qml
    )

    if command -v qtpaths6 >/dev/null 2>&1; then
        qt_root="$(qtpaths6 --query QT_INSTALL_QML 2>/dev/null || true)"
        [[ -n "$qt_root" ]] && roots=("$qt_root" "${roots[@]}")
    fi

    for root in "${roots[@]}"; do
        [[ -d "$root" ]] || continue
        if [[ -f "$root/org/kde/plasma/PimCalendars/qmldir" ]]; then
            printf '%s\n' 'org.kde.plasma.PimCalendars'
            return 0
        fi
        if [[ -f "$root/org/kde/CalendarEventsPlugin/qmldir" ]]; then
            printf '%s\n' 'org.kde.CalendarEventsPlugin'
            return 0
        fi
    done

    return 1
}

plasmoid_installed() {
    command -v kpackagetool6 >/dev/null 2>&1 && \
        kpackagetool6 -t Plasma/Applet -s "$APP_ID" >/dev/null 2>&1
}

pim_ready() {
    command -v akonadictl >/dev/null 2>&1 && \
        command -v korganizer >/dev/null 2>&1 && \
        [[ -n "$(find_pimevents)" ]]
}

check_plasma() {
    command -v plasmashell >/dev/null 2>&1 || die "plasmashell not found. Simple Plasma Agenda requires KDE Plasma 6."
    command -v kpackagetool6 >/dev/null 2>&1 || die "kpackagetool6 not found. Simple Plasma Agenda requires KDE Plasma 6."

    local version
    version="$(plasmashell --version 2>/dev/null | head -n 1 || true)"
    [[ "$version" == *" 6."* ]] || die "Plasma 6 is required; detected: ${version:-unknown}."
}

check_system() {
    detect_package_manager

    printf '\nSimple Plasma Agenda — preflight\n'
    printf '%-24s %s\n' "Distribution:" "$OS_NAME"
    printf '%-24s %s\n' "Package manager:" "$PKG_MANAGER"

    if command -v plasmashell >/dev/null 2>&1; then
        printf '%-24s %s\n' "Plasma:" "$(plasmashell --version 2>/dev/null | head -n 1 || true)"
    else
        printf '%-24s %s\n' "Plasma:" "MISSING"
    fi

    printf '%-24s %s\n' "kpackagetool6:" "$(command -v kpackagetool6 >/dev/null 2>&1 && printf OK || printf MISSING)"
    printf '%-24s %s\n' "busctl:" "$(command -v busctl >/dev/null 2>&1 && printf OK || printf MISSING)"
    printf '%-24s %s\n' "KOrganizer:" "$(command -v korganizer >/dev/null 2>&1 && printf OK || printf MISSING)"

    if command -v akonadictl >/dev/null 2>&1; then
        local akonadi_status control_status server_status
        akonadi_status="$(akonadictl status 2>&1 || true)"
        control_status="$(printf '%s\n' "$akonadi_status" | sed -n 's/^Akonadi Control: //p' | head -n 1)"
        server_status="$(printf '%s\n' "$akonadi_status" | sed -n 's/^Akonadi Server: //p' | head -n 1)"
        printf '%-24s %s\n' "Akonadi Control:" "${control_status:-UNKNOWN}"
        printf '%-24s %s\n' "Akonadi Server:" "${server_status:-UNKNOWN}"
    else
        printf '%-24s %s\n' "Akonadi Control:" "MISSING"
        printf '%-24s %s\n' "Akonadi Server:" "MISSING"
    fi

    local pimevents pim_selection
    pimevents="$(find_pimevents)"
    printf '%-24s %s\n' "pimevents:" "${pimevents:-NOT FOUND}"
    pim_selection="$(pimevents_calendar_selection)"
    printf '%-24s %s\n' "PIM calendars:" "${pim_selection:-not configured}"

    if plasmoid_installed; then
        printf '%-24s %s\n' "Simple Agenda:" "installed"
    else
        printf '%-24s %s\n' "Simple Agenda:" "not installed"
    fi
}

confirm() {
    local prompt="$1" answer
    [[ -t 0 ]] || return 1
    printf '\n%s [y/N] ' "$prompt"
    read -r answer
    case "$answer" in
        y|Y|yes|YES|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

show_dependency_plan() {
    local packages="$1"
    printf '\nSimple Plasma Agenda needs KDE PIM/Akonadi to receive calendar events.\n'
    printf 'Some required components are missing.\n\n'
    printf 'Detected system: %s\n' "$OS_NAME"
    printf 'Package manager: %s\n' "$PKG_MANAGER"
    printf 'Packages to ensure are installed:\n  %s\n' "$packages"

    case "$PKG_MANAGER" in
        pacman)
            printf '\nArch-based systems require a normal full repository upgrade;\n'
            printf 'the installer will use: pacman -Syu --needed ...\n'
            ;;
        apt)
            printf '\nThe installer will refresh APT package indexes before installing.\n'
            ;;
        zypper)
            printf '\nThe installer will refresh zypper repositories before installing.\n'
            ;;
    esac

    printf '\nNo calendar account, password or credential will be configured by this script.\n'
}

install_dependencies() {
    detect_package_manager
    command -v sudo >/dev/null 2>&1 || die "sudo is required for automatic system-package installation."
    local packages
    packages="$(package_list)"

    show_dependency_plan "$packages"
    if ! confirm "Continue with system package installation using sudo?"; then
        printf '\nNothing was installed. You can run this installer again later.\n'
        return 2
    fi

    log "Installing KDE PIM/Akonadi dependencies"
    # Intentional word splitting: package_list returns trusted literal package names.
    # shellcheck disable=SC2086
    case "$PKG_MANAGER" in
        dnf)
            sudo dnf install -y $packages
            ;;
        apt)
            sudo apt-get update
            # shellcheck disable=SC2086
            sudo apt-get install -y $packages
            ;;
        pacman)
            # shellcheck disable=SC2086
            sudo pacman -Syu --needed --noconfirm $packages
            ;;
        zypper)
            sudo zypper --non-interactive refresh
            # shellcheck disable=SC2086
            sudo zypper --non-interactive install $packages
            ;;
    esac
}

ensure_dependencies() {
    check_plasma

    if ! command -v busctl >/dev/null 2>&1; then
        die "busctl is missing. It is required by Simple Agenda's refresh and KOrganizer integration."
    fi

    if pim_ready; then
        log "KDE PIM/Akonadi and pimevents are already available; no system packages need to be installed."
        return 0
    fi

    install_dependencies || return $?

    if ! pim_ready; then
        warn "The package installation completed, but one or more required components are still missing."
        check_system
        die "Cannot continue automatically. See README.md for manual installation checks."
    fi
}

start_akonadi() {
    command -v akonadictl >/dev/null 2>&1 || return 0

    local status
    status="$(akonadictl status 2>&1 || true)"
    if printf '%s\n' "$status" | grep -q '^Akonadi Control: running$' && \
       printf '%s\n' "$status" | grep -q '^Akonadi Server: running$'; then
        log "Akonadi is already running."
        return 0
    fi

    log "Starting Akonadi for the current user"
    akonadictl start >/dev/null 2>&1 || warn "Akonadi did not start immediately; you can start it later with: akonadictl start"
}

manual_pimevents_fallback() {
    cat <<'FALLBACK'

The automatic calendar selector could not be started on this system.

Fallback using Plasma's Digital Clock:
  1. Open Digital Clock settings -> Calendar.
  2. Temporarily enable PIM Events.
  3. Select only the calendars you want Simple Plasma Agenda to display.
  4. Apply the settings.
  5. You may then disable PIM Events in the Digital Clock again.

The selection remains stored globally for pimevents and Simple Plasma Agenda
can continue to use it without displaying PIM events in the clock.
FALLBACK
}

run_calendar_selector() {
    command -v plasmawindowed >/dev/null 2>&1 || return 10
    command -v kreadconfig6 >/dev/null 2>&1 || return 10
    command -v kwriteconfig6 >/dev/null 2>&1 || return 10

    local qml_module
    qml_module="$(detect_pim_calendars_qml_module)" || return 10

    local probe_id="com.simple.plasma.agenda.calendarprobe"
    local probe_dir="$HOME/.local/share/plasma/plasmoids/$probe_id"
    local tmp selection_file helper_file log_file initial_csv initial_js
    tmp="$(mktemp -d)"
    selection_file="$tmp/selection"
    helper_file="$tmp/save-selection.sh"
    log_file="$tmp/plasmawindowed.log"
    initial_csv="$(pimevents_calendar_selection)"
    initial_js=""

    if [[ -n "$initial_csv" ]]; then
        if [[ "$initial_csv" =~ ^[0-9]+(,[0-9]+)*$ ]]; then
            initial_js="$initial_csv"
        else
            warn "Ignoring an unexpected existing PIM Events calendar value: $initial_csv"
        fi
    fi

    rm -rf "$probe_dir"
    mkdir -p "$probe_dir/contents/ui"

    cat > "$probe_dir/metadata.json" <<'EOF'
{
    "KPlugin": {
        "Id": "com.simple.plasma.agenda.calendarprobe",
        "Name": "Simple Agenda Calendar Selector",
        "Version": "1.0"
    },
    "KPackageStructure": "Plasma/Applet",
    "X-Plasma-API-Minimum-Version": "6.0"
}
EOF

    cat > "$helper_file" <<EOF
#!/usr/bin/env bash
set -euo pipefail
value="\${1:-}"
if [[ "\$value" == "CANCEL" ]]; then
    printf '%s\n' CANCEL > '$selection_file'
    exit 0
fi
[[ "\$value" =~ ^[0-9]+(,[0-9]+)*\$ ]] || exit 2
printf '%s\n' "\$value" > '$selection_file'
EOF
    chmod +x "$helper_file"

    cat > "$probe_dir/contents/ui/main.qml" <<EOF
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import $qml_module
import org.kde.kitemmodels
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    width: 640
    height: 520

    property bool italian: Qt.locale().name.toLowerCase().startsWith("it")
    property var selected: ({})
    property var initialIds: [$initial_js]
    property string helperPath: "$helper_file"
    property string statusText: ""

    function isSelected(id) {
        return selected[id.toString()] === true;
    }

    function setSelected(id, checked) {
        var copy = {};
        for (var key in selected) {
            copy[key] = selected[key];
        }
        if (checked) {
            copy[id.toString()] = true;
        } else {
            delete copy[id.toString()];
        }
        selected = copy;
    }

    function selectedCount() {
        var count = 0;
        for (var key in selected) {
            if (selected[key] === true) count++;
        }
        return count;
    }

    function selectedCsv() {
        var ids = [];
        for (var key in selected) {
            if (selected[key] === true) ids.push(Number(key));
        }
        ids.sort(function(a, b) { return a - b; });
        return ids.join(",");
    }

    function submit(value) {
        statusText = italian ? "Salvataggio selezione…" : "Saving selection…";
        commandRunner.connectSource(helperPath + " " + value);
    }

    Component.onCompleted: {
        var copy = {};
        for (var i = 0; i < initialIds.length; ++i) {
            copy[initialIds[i].toString()] = true;
        }
        selected = copy;
    }

    PimCalendarsModel {
        id: calendarModel
    }

    KDescendantsProxyModel {
        id: flatModel
        model: calendarModel
    }

    Plasma5Support.DataSource {
        id: commandRunner
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source);
            if (data["exit code"] !== 0) {
                root.statusText = root.italian ? "Impossibile salvare la selezione." : "Could not save the selection.";
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        QQC2.Label {
            Layout.fillWidth: true
            text: root.italian
                ? "Calendari da mostrare in Simple Plasma Agenda"
                : "Calendars to show in Simple Plasma Agenda"
            font.bold: true
            font.pointSize: 13
            wrapMode: Text.WordWrap
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: root.italian
                ? "Seleziona solo le sorgenti che vuoi vedere nell’agenda. Questa scelta configura il backend PIM Events; non abilita gli eventi nell’orologio."
                : "Select only the sources you want in the agenda. This configures the PIM Events backend; it does not enable events in the clock."
            wrapMode: Text.WordWrap
        }

        ListView {
            id: calendarList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: flatModel
            spacing: 2

            delegate: QQC2.CheckBox {
                required property int collectionId
                required property string name
                required property bool isEnabled

                width: ListView.view.width
                visible: isEnabled
                height: visible ? implicitHeight + 6 : 0
                enabled: isEnabled
                text: name + "   (ID " + collectionId + ")"
                checked: root.isSelected(collectionId)
                onToggled: root.setSelected(collectionId, checked)
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            visible: root.statusText.length > 0
            text: root.statusText
        }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }

            QQC2.Button {
                text: root.italian ? "Annulla" : "Cancel"
                onClicked: root.submit("CANCEL")
            }

            QQC2.Button {
                text: root.italian ? "Conferma" : "Confirm"
                enabled: root.selectedCount() > 0
                highlighted: true
                onClicked: root.submit(root.selectedCsv())
            }
        }
    }
}
EOF

    log "Opening the Akonadi calendar selector"
    plasmawindowed "$probe_id" >"$log_file" 2>&1 &
    local probe_pid=$!

    while kill -0 "$probe_pid" 2>/dev/null; do
        [[ -s "$selection_file" ]] && break
        sleep 0.2
    done

    local selection=""
    if [[ -s "$selection_file" ]]; then
        selection="$(head -n 1 "$selection_file")"
        kill "$probe_pid" >/dev/null 2>&1 || true
        wait "$probe_pid" 2>/dev/null || true
    else
        wait "$probe_pid" 2>/dev/null || true
    fi

    if [[ -z "$selection" ]]; then
        warn "The calendar selector closed without returning a selection."
        if [[ -s "$log_file" ]]; then
            printf '\nSelector log (last lines):\n' >&2
            tail -n 12 "$log_file" >&2 || true
        fi
        rm -rf "$probe_dir" "$tmp"
        return 10
    fi

    rm -rf "$probe_dir" "$tmp"

    if [[ "$selection" == "CANCEL" ]]; then
        return 2
    fi
    [[ "$selection" =~ ^[0-9]+(,[0-9]+)*$ ]] || die "The calendar selector returned an invalid value."

    kwriteconfig6 --file plasmashellrc --group PIMEventsPlugin --key calendars "$selection"

    local saved
    saved="$(pimevents_calendar_selection)"
    [[ "$saved" == "$selection" ]] || die "Could not verify the PIM Events calendar configuration."

    log "PIM Events calendar selection saved: $selection"
    return 0
}

configure_pimevents_calendars() {
    local rc=0
    run_calendar_selector || rc=$?
    if [[ $rc -eq 0 ]]; then
        return 0
    fi

    if [[ $rc -eq 2 ]]; then
        printf '\nCalendar selection cancelled.\n'
        return 2
    fi

    warn "The automatic calendar selector is unavailable; using the Plasma fallback instructions."
    manual_pimevents_fallback
    if ! confirm "Have you configured at least one PIM Events calendar?"; then
        return 2
    fi

    local selection
    selection="$(pimevents_calendar_selection)"
    if [[ -z "$selection" ]]; then
        warn "No PIM Events calendar selection was found."
        return 2
    fi

    log "Existing PIM Events calendar selection: $selection"
    return 0
}

find_package_dir() {
    local base="$1"

    if [[ -f "$base/metadata.json" && -d "$base/contents" ]]; then
        printf '%s\n' "$base"
        return 0
    fi

    if [[ -f "$base/$APP_ID/metadata.json" && -d "$base/$APP_ID/contents" ]]; then
        printf '%s\n' "$base/$APP_ID"
        return 0
    fi

    return 1
}

stage_package() {
    local source_dir="$1" stage_root="$2" staged
    staged="$stage_root/$APP_ID"
    mkdir -p "$staged"
    cp -a "$source_dir/metadata.json" "$staged/"
    cp -a "$source_dir/contents" "$staged/"
    [[ -f "$source_dir/LICENSE" ]] && cp -a "$source_dir/LICENSE" "$staged/"
    [[ -f "$source_dir/NOTICE.md" ]] && cp -a "$source_dir/NOTICE.md" "$staged/"
    printf '%s\n' "$staged"
}

download_file() {
    local url="$1" output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fL --retry 2 --connect-timeout 15 -o "$output" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$output" "$url"
    else
        die "Neither curl nor wget is available. Install one of them or run the installer from a repository checkout."
    fi

    [[ -s "$output" ]] || die "Downloaded package is empty."
}

install_widget() {
    check_plasma

    local source_dir="" tmp package_path=""
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN

    if source_dir="$(find_package_dir "$REPO_ROOT" 2>/dev/null)"; then
        log "Using widget files from the local repository checkout"
        package_path="$(stage_package "$source_dir" "$tmp")"
    else
        package_path="$tmp/Simple-Plasma-Agenda.plasmoid"
        log "Downloading the latest Simple Plasma Agenda release"
        printf 'Source: %s\n' "$WIDGET_URL"
        download_file "$WIDGET_URL" "$package_path"
    fi

    if plasmoid_installed; then
        log "Updating Simple Plasma Agenda"
        kpackagetool6 -t Plasma/Applet -u "$package_path" || die "Widget update failed. The existing installation was left in place."
    else
        log "Installing Simple Plasma Agenda"
        kpackagetool6 -t Plasma/Applet -i "$package_path"
    fi

    rm -rf "$tmp"
    trap - RETURN
}

calendar_checkpoint() {
    cat <<'CHECKPOINT'

System prerequisites are ready.

Now configure at least one calendar in KOrganizer before installing the widget.
Simple Plasma Agenda uses KOrganizer when you click an event, so it is the
recommended first-setup path.

Example: Google Calendar in KOrganizer
  1. Open KOrganizer.
  2. Settings -> Configure KOrganizer... -> General -> Calendars -> Add...
     (or right-click the Calendar Manager sidebar -> Add Calendar...).
  3. Choose "Google Groupware".
  4. Select the new Google Groupware resource and choose "Configure".
  5. Complete the Google sign-in/authorization in the browser.
  6. Return to KOrganizer and use Apply / OK.
  7. Wait until the Google resource is ready.
  8. Verify that real events are visible in KOrganizer.

After this checkpoint, the installer will open a small local selector showing
Akonadi calendar names. Choose only the calendars you want Simple Plasma Agenda
to display. This configures pimevents directly; Plasma's Digital Clock does not
need to display PIM events.

Merkuro can use the same Akonadi resources. If you prefer it, the account page
is normally under Settings -> Configure Merkuro -> Accounts -> Add Account.
For the most predictable first setup, KOrganizer remains recommended.

Other supported Akonadi resources include DAV/CalDAV (for example Nextcloud),
iCalendar files/folders and local calendars.

The installer never handles your account password, OAuth choices or credentials.
CHECKPOINT
}

print_next_steps() {
    cat <<'NEXT'

Installation complete.

Desktop -> Add Widgets... -> Simple Plasma Agenda

To change which Akonadi calendars Simple Plasma Agenda receives later, run:
  install.sh --calendars
(or ./scripts/install.sh --calendars from a repository checkout).

The calendar list is stored for Plasma's pimevents backend. PIM Events does not
need to remain enabled in the Digital Clock.
NEXT
}

full_install() {
    check_system
    if ! ensure_dependencies; then
        return 0
    fi
    start_akonadi
    calendar_checkpoint

    if ! confirm "Are real calendar events visible in KOrganizer?"; then
        printf '\nSetup paused. Configure a calendar in KOrganizer, then run the installer again.\n'
        return 0
    fi

    if ! configure_pimevents_calendars; then
        printf '\nWidget installation skipped because no PIM Events calendar selection was confirmed.\n'
        return 0
    fi

    install_widget
    check_system
    print_next_steps
}

main() {
    case "${1:-}" in
        --help|-h|help)
            usage
            return 0
            ;;
    esac

    [[ ${EUID:-$(id -u)} -ne 0 ]] || die "Do not run this installer as root. Run it as your normal Plasma user; sudo will be requested only when needed."

    case "${1:-}" in
        "")
            full_install
            ;;
        --check)
            check_system
            ;;
        --deps)
            check_system
            if ensure_dependencies; then
                start_akonadi
                check_system
            fi
            ;;
        --widget)
            install_widget
            ;;
        --calendars)
            check_plasma
            pim_ready || die "KDE PIM/Akonadi and pimevents must be installed before calendar selection."
            start_akonadi
            configure_pimevents_calendars || true
            ;;
        *)
            usage
            die "Unknown option: $1"
            ;;
    esac
}

main "$@"
