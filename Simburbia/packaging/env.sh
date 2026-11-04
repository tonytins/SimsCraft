# shellcheck shell=bash
# Shared setup for the packaging scripts, after CityLimits'. Source it:
# `. "$(dirname "${BASH_SOURCE[0]}")/../env.sh"`.
#
# Sets:
#   ROOT         the repository's root
#   APP          Simburbia, the name players see
#   EXE          simburbia, the client's executable
#   PACKAGE      the client's Swift package (Simburbia/SBClient)
#   DIST         where the packages go (default: $ROOT/dist/release)
#   WORK         where they are put together (default: $ROOT/dist/work)
#   BUILD_SHA    the commit being packaged
#
# VERSION is set by build_client, from the built client's --version (GitVersion's
# major.minor.patch); SIMBURBIA_VERSION overrides it.
#
# Swift builds for the machine it runs on, so each script runs on its own platform: Linux on
# Linux, Windows on Windows (in Git Bash), macOS on a Mac.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP=Simburbia
EXE=simburbia
PACKAGE="$ROOT/Simburbia/SBClient"
export ROOT APP EXE PACKAGE

fail() {
    echo "packaging: $*" >&2
    exit 1
}

command -v swift >/dev/null || fail "swift isn't installed; a Swift 6 toolchain is needed to build."
command -v git >/dev/null || fail "git isn't installed; the client's version is counted from its history."

DIST="${DIST:-$ROOT/dist/release}"
WORK="${WORK:-$ROOT/dist/work}"
mkdir -p "$DIST" "$WORK"
DIST="$(cd "$DIST" && pwd)"
WORK="$(cd "$WORK" && pwd)"
export DIST WORK

BUILD_SHA="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
export BUILD_SHA

# Builds the client in release, with any extra arguments for swift build, sets BIN to the built
# executable, and VERSION from it.
build_client() {
    swift build --package-path "$PACKAGE" -c release --product "$EXE" "$@" \
        || fail "couldn't build the client."
    BIN="$(swift build --package-path "$PACKAGE" -c release "$@" --show-bin-path)/$EXE"
    [[ -x "$BIN" || -x "$BIN.exe" ]] || fail "the build has no $EXE in $(dirname "$BIN")."
    if [[ -z "${SIMBURBIA_VERSION:-}" ]]; then
        # "Simburbia 0.1.1003+main.1a2b3c4d5e6f": the part before any build metadata.
        SIMBURBIA_VERSION="$("$BIN" --version | awk '{ print $2 }' | cut -d+ -f1)"
    fi
    VERSION="$SIMBURBIA_VERSION"
    [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]] || fail "couldn't read the client's version; got '$VERSION'."
    export BIN VERSION
}

# Puts what a player needs in a folder: the client, its interface documents, its lots, and the
# mock install (only the files git tracks, so nothing local slips in), and the readme and licence.
stage() {
    local dest="$1" file
    rm -rf "$dest"
    mkdir -p "$dest"
    if [[ -f "$BIN.exe" ]]; then cp "$BIN.exe" "$dest/"; else cp "$BIN" "$dest/"; fi
    while IFS= read -r file; do
        mkdir -p "$dest/$(dirname "${file#Simburbia/}")"
        cp "$ROOT/$file" "$dest/${file#Simburbia/}"
    done < <(git -C "$ROOT" ls-files Simburbia/Interface Simburbia/Lots Simburbia/MockInstall)
    # The smoke test runs headless, which never reads the interface, so its documents are checked here.
    for file in topbar help momi inspector; do
        [[ -f "$dest/Interface/$file.xml" ]] || fail "the package has no Interface/$file.xml."
    done
    cp "$ROOT/README.md" "$dest/README.md"
    cp "$ROOT/Simburbia/LICENSE" "$dest/LICENSE"
}

# Checks a staged client runs: its version, and a game hour of the mock lot with no window or
# install, which proves it finds the files packaged beside it.
smoke_test() {
    local exe="$1" log
    "$exe" --version >/dev/null || fail "the packaged client didn't start."
    # Captured whole rather than piped to grep -q, whose early exit would end the script with a
    # SIGPIPE under pipefail.
    log="$(env -u TSO_GAME_DIR -u TSO_CLASSIC_DIR -u TSO_BETA_DIR "$exe" --headless --ticks 9000 2>&1)" \
        || fail "the packaged client couldn't run the mock lot:"$'\n'"$log"
    [[ "$log" == *"ran 9000 ticks"* ]] || fail "the packaged client didn't finish the mock lot:"$'\n'"$log"
}

# Prints a file's SHA-256.
sha256() {
    if command -v sha256sum >/dev/null; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# Downloads a file once, and refuses it unless its SHA-256 is the one given. A file already there
# is checked too, so a damaged or swapped download is never used.
download_verified() {
    local url="$1" dest="$2" expected="$3" executable="${4:-false}" got
    if [[ ! -f "$dest" ]]; then
        echo "Downloading $url"
        curl -fL --retry 3 -o "$dest.part" "$url" || fail "couldn't download $url."
        mv "$dest.part" "$dest"
    fi
    got="$(sha256 "$dest")"
    if [[ "$got" != "$expected" ]]; then
        rm -f "$dest"
        fail "$(basename "$dest") has SHA-256 $got, not $expected; it was deleted, so the next run downloads it again."
    fi
    if [[ "$executable" = true ]]; then chmod +x "$dest"; fi
}

# The scripts' options: -h or --help.
parse_options() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h | --help) awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"; exit 0 ;;
            *) fail "unknown option '$1'; see --help." ;;
        esac
    done
}
