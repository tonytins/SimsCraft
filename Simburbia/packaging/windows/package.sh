#!/usr/bin/env bash
# Builds Simburbia's client for x86_64 Windows:
#
#   $DIST/simburbia-<version>-windows-x64.zip  the client in a folder; unzip it anywhere
#
# Usage: Simburbia/packaging/windows/package.sh
#
# Runs on Windows, in Git Bash, with the Swift 6 toolchain for Windows: Swift can't build a
# Windows client from another system. The Swift runtime is built in, so players need nothing
# installed. Not yet run on Windows (raylib-swift hasn't been built there).

# shellcheck source=../env.sh
. "$(dirname "${BASH_SOURCE[0]}")/../env.sh"
parse_options "$@"

case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*) ;;
    *) fail "this script runs on Windows, in Git Bash; Swift can't build a Windows client from $(uname -s)." ;;
esac

build_client --static-swift-stdlib
BASENAME="simburbia-$VERSION-windows-x64"
echo "==> $APP $VERSION for Windows x64"

STAGE="$WORK/windows/$BASENAME"
stage "$STAGE"
smoke_test "$STAGE/$EXE.exe"

OUT="$DIST/$BASENAME.zip"
rm -f "$OUT"
# Git Bash has no zip; PowerShell's archiver is on every Windows.
powershell.exe -NoProfile -Command "Compress-Archive -Path '$(cygpath -w "$STAGE")' -DestinationPath '$(cygpath -w "$OUT")'" \
    || fail "couldn't zip the client."
echo "wrote $OUT"
echo "==> done"
