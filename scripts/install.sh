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
  ./scripts/install.sh --help

The same script can also be downloaded and run standalone.

Modes:
  (default)  Check the system, offer to install missing KDE PIM/Akonadi
             dependencies, start Akonadi, stop for calendar setup, then
             install/update the widget.
  --check    Read-only preflight report.
  --deps     Check and, if needed, offer to install KDE PIM/Akonadi only.
  --widget   Install/update only the widget. From a repository checkout it
             uses local files; standalone it downloads the latest release asset.

The script never configures calendar accounts, passwords or credentials.
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

    local pimevents
    pimevents="$(find_pimevents)"
    printf '%-24s %s\n' "pimevents:" "${pimevents:-NOT FOUND}"

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

Now configure at least one calendar before installing the widget.
KOrganizer is recommended because Simple Plasma Agenda also opens KOrganizer
when you click an event.

Example: Google Calendar in KOrganizer
  1. Open KOrganizer.
  2. Settings -> Configure KOrganizer... -> General -> Calendars -> Add...
     (or right-click the Calendar Manager sidebar -> Add Calendar...).
  3. Choose "Google Calendars and Tasks".
  4. Enter your Google account when requested.
  5. Complete the Google sign-in/authorization in the browser.
  6. Return to KOrganizer and wait until the Google resource is ready.
  7. Make sure the calendars you want are enabled in Calendar Manager.
  8. Verify that real events are visible in KOrganizer.
  9. Preferably also open Plasma's Digital Clock calendar and verify that
     the same PIM events are visible there.

Merkuro can use the same Akonadi resources. If you prefer it, the account page
is normally under Settings -> Configure Merkuro -> Accounts -> Add Account.
For the most predictable setup path, add the resource in KOrganizer first;
it should then also become available in Merkuro.

Other supported Akonadi resources include DAV/CalDAV (for example Nextcloud),
iCalendar files/folders and local calendars.

This checkpoint is intentionally manual: the installer never handles your
account password, OAuth choices, credentials or calendar-source selection.
CHECKPOINT
}

print_next_steps() {
    cat <<'NEXT'

Installation complete.

Desktop -> Add Widgets... -> Simple Plasma Agenda

If events later disappear from KOrganizer/Plasma, solve the Akonadi/PIM
configuration first: Simple Plasma Agenda only displays what pimevents exposes.
NEXT
}

full_install() {
    check_system
    if ! ensure_dependencies; then
        return 0
    fi
    start_akonadi
    calendar_checkpoint

    if ! confirm "Are calendar events visible and should Simple Plasma Agenda be installed now?"; then
        printf '\nWidget installation skipped. When ready, run this installer again with --widget.\n'
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
        *)
            usage
            die "Unknown option: $1"
            ;;
    esac
}

main "$@"
