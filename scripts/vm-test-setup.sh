#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.simple.plasma.agenda"
REPO_SLUG="Omar-Ceretta/simple-plasma-agenda"
DEFAULT_BRANCH="main"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

log()  { printf '\n==> %s\n' "$*"; }
warn() { printf '\nWARNING: %s\n' "$*" >&2; }
die()  { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<'USAGE'
Simple Plasma Agenda — VM test helper

Usage:
  ./scripts/vm-test-setup.sh deps
  ./scripts/vm-test-setup.sh install
  ./scripts/vm-test-setup.sh fresh
  ./scripts/vm-test-setup.sh check
  ./scripts/vm-test-setup.sh all
  ./scripts/vm-test-setup.sh download [branch]

Commands:
  deps      Install the Akonadi/PIM packages used for the full test experience.
  install   Install/update the plasmoid from the current repository checkout.
  fresh     Remove the installed package, clear Plasma QML cache, reinstall it,
            and restart plasmashell. Remove any desktop instance first if this
            is not a fresh VM.
  check     Print a compact pre-flight report.
  all       deps + start Akonadi + fresh + check.
  download  Download the GitHub branch archive into a temporary directory and
            install it. This requires the repository to be accessible from the VM.

Environment overrides:
  SPA_ARCHIVE_URL   Full ZIP URL to use instead of the default GitHub branch URL.
USAGE
}

load_os_release() {
    [[ -r /etc/os-release ]] || die "/etc/os-release not found"
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_LIKE="${ID_LIKE:-}"
}

is_debian_family() {
    [[ "$OS_ID" == "debian" || "$OS_ID" == "ubuntu" || "$OS_ID" == "kubuntu" || "$OS_ID" == "neon" || "$OS_ID" == "tuxedo" || " $OS_LIKE " == *" debian "* || " $OS_LIKE " == *" ubuntu "* ]]
}

install_deps() {
    load_os_release
    log "Detected distribution: ${PRETTY_NAME:-$OS_ID}"

    case "$OS_ID" in
        fedora)
            sudo dnf install -y \
                akonadi-server kdepim-runtime kdepim-addons korganizer \
                curl unzip
            ;;
        arch|manjaro|endeavouros)
            sudo pacman -Syu --needed --noconfirm \
                akonadi kdepim-runtime kdepim-addons korganizer \
                curl unzip
            ;;
        opensuse-tumbleweed|opensuse-leap|opensuse)
            sudo zypper --non-interactive refresh
            sudo zypper --non-interactive install \
                akonadi kdepim-runtime kdepim-addons korganizer \
                curl unzip
            ;;
        *)
            if is_debian_family; then
                sudo apt update
                sudo apt install -y \
                    akonadi-server kdepim-runtime kdepim-addons korganizer \
                    curl unzip
            else
                die "Unsupported distribution for automatic dependency install: ${PRETTY_NAME:-$OS_ID}. Use the manual commands in VM_TESTING.md."
            fi
            ;;
    esac

    log "Dependencies installed. Starting Akonadi if possible..."
    if command -v akonadictl >/dev/null 2>&1; then
        akonadictl start >/dev/null 2>&1 || true
    fi
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
    local source_dir="$1"
    local stage_root="$2"
    local staged="$stage_root/$APP_ID"

    mkdir -p "$staged"
    cp -a "$source_dir/metadata.json" "$staged/"
    cp -a "$source_dir/contents" "$staged/"
    printf '%s\n' "$staged"
}

install_package_dir() {
    local source_dir="$1"
    command -v kpackagetool6 >/dev/null 2>&1 || die "kpackagetool6 not found. Is Plasma 6 installed?"

    local tmp staged
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN
    staged="$(stage_package "$source_dir" "$tmp")"

    log "Installing $APP_ID with kpackagetool6"
    if kpackagetool6 -t Plasma/Applet -s "$APP_ID" >/dev/null 2>&1; then
        kpackagetool6 -t Plasma/Applet -u "$staged" || {
            warn "Upgrade failed; trying remove + install."
            kpackagetool6 -t Plasma/Applet -r "$APP_ID" >/dev/null 2>&1 || true
            kpackagetool6 -t Plasma/Applet -i "$staged"
        }
    else
        kpackagetool6 -t Plasma/Applet -i "$staged"
    fi

    rm -rf "$tmp"
    trap - RETURN
}

install_from_checkout() {
    local pkg
    pkg="$(find_package_dir "$REPO_ROOT")" || die "No metadata.json + contents/ found in repository root or $APP_ID/."
    install_package_dir "$pkg"
}

restart_plasma() {
    log "Clearing Plasma QML cache"
    rm -rf "$HOME/.cache/plasmashell/qmlcache"

    log "Restarting plasmashell"
    if systemctl --user restart plasma-plasmashell.service 2>/dev/null; then
        return 0
    fi
    if systemctl --user restart plasma-plasmashell 2>/dev/null; then
        return 0
    fi

    warn "Could not restart plasmashell through systemd. Restart it manually if the old QML is still cached."
}

fresh_install() {
    command -v kpackagetool6 >/dev/null 2>&1 || die "kpackagetool6 not found."
    warn "If the widget is already on the desktop, remove that instance before a clean reinstall."

    kpackagetool6 -t Plasma/Applet -r "$APP_ID" >/dev/null 2>&1 || true
    rm -rf "$HOME/.local/share/plasma/plasmoids/$APP_ID" 2>/dev/null || true
    install_from_checkout
    restart_plasma
}

download_archive() {
    local url="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fL --retry 3 --connect-timeout 15 "$url" -o "$out"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$out" "$url"
    else
        die "Neither curl nor wget is installed."
    fi
}

install_from_github() {
    local branch="${1:-$DEFAULT_BRANCH}"
    local url="${SPA_ARCHIVE_URL:-https://github.com/$REPO_SLUG/archive/refs/heads/$branch.zip}"
    local tmp zip root pkg

    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN
    zip="$tmp/repo.zip"

    log "Downloading $url"
    download_archive "$url" "$zip"
    unzip -q "$zip" -d "$tmp/unpacked"

    root="$(find "$tmp/unpacked" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    [[ -n "$root" ]] || die "Could not find extracted repository directory."
    pkg="$(find_package_dir "$root")" || die "Downloaded repository does not contain metadata.json + contents/."

    install_package_dir "$pkg"
    restart_plasma

    rm -rf "$tmp"
    trap - RETURN
}

check_system() {
    load_os_release
    printf '\nSimple Plasma Agenda — VM pre-flight\n'
    printf '%-24s %s\n' "Distribution:" "${PRETTY_NAME:-$OS_ID}"

    if command -v plasmashell >/dev/null 2>&1; then
        printf '%-24s %s\n' "Plasma:" "$(plasmashell --version 2>/dev/null | head -n1)"
    else
        printf '%-24s %s\n' "Plasma:" "MISSING"
    fi

    if command -v kpackagetool6 >/dev/null 2>&1; then
        printf '%-24s %s\n' "kpackagetool6:" "OK"
    else
        printf '%-24s %s\n' "kpackagetool6:" "MISSING"
    fi

    if command -v busctl >/dev/null 2>&1; then
        printf '%-24s %s\n' "busctl:" "$(command -v busctl)"
    else
        printf '%-24s %s\n' "busctl:" "MISSING (agenda display may work; refresh/click actions will not)"
    fi

    if command -v korganizer >/dev/null 2>&1; then
        printf '%-24s %s\n' "KOrganizer:" "$(command -v korganizer)"
    else
        printf '%-24s %s\n' "KOrganizer:" "MISSING (event click action unavailable)"
    fi

    if command -v akonadictl >/dev/null 2>&1; then
        printf '%-24s ' "Akonadi:"
        akonadictl status 2>&1 | head -n1 || true
    else
        printf '%-24s %s\n' "Akonadi:" "MISSING"
    fi

    local pimevents
    pimevents="$(find /usr/lib /usr/lib64 -type f -path '*/plasmacalendarplugins/pimevents.so' -print -quit 2>/dev/null || true)"
    printf '%-24s %s\n' "pimevents:" "${pimevents:-NOT FOUND}"

    if kpackagetool6 -t Plasma/Applet -s "$APP_ID" >/dev/null 2>&1; then
        printf '%-24s %s\n' "Simple Agenda:" "installed"
    else
        printf '%-24s %s\n' "Simple Agenda:" "not installed"
    fi

    cat <<'NEXT'

Next manual step (cannot be automated safely):
  Open KOrganizer and add/authenticate at least one calendar resource
  (Google, CalDAV/Nextcloud, iCalendar, etc.), then verify events are visible.

After that:
  Desktop → Add Widgets… → Simple Plasma Agenda
NEXT
}

main() {
    local cmd="${1:-}"
    case "$cmd" in
        deps)
            install_deps
            ;;
        install)
            install_from_checkout
            ;;
        fresh)
            fresh_install
            ;;
        check)
            check_system
            ;;
        all)
            install_deps
            fresh_install
            check_system
            ;;
        download)
            install_from_github "${2:-$DEFAULT_BRANCH}"
            ;;
        -h|--help|help|"")
            usage
            ;;
        *)
            usage
            die "Unknown command: $cmd"
            ;;
    esac
}

main "$@"
