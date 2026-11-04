#!/usr/bin/env bash
# Builds Simburbia's client for macOS, for Apple silicon and Intel in one app:
#
#   $DIST/simburbia-<version>-macos-universal.zip  holding Simburbia.app
#
# Usage: Simburbia/packaging/macos/package.sh
#
# Runs on a Mac with Xcode or its command line tools: Swift can't build a Mac client from another
# system. The app is signed ad hoc, not with a Developer ID, so Gatekeeper asks before a
# downloaded copy first opens: Control-click the app and choose Open. Not yet run on a Mac
# (raylib-swift hasn't been built there).

# shellcheck source=../env.sh
. "$(dirname "${BASH_SOURCE[0]}")/../env.sh"
parse_options "$@"
HERE="$ROOT/Simburbia/packaging/macos"

[[ "$(uname -s)" == Darwin ]] || fail "this script runs on a Mac; Swift can't build a Mac client from $(uname -s)."

build_client --arch arm64 --arch x86_64
BASENAME="simburbia-$VERSION-macos-universal"
echo "==> $APP $VERSION for macOS (arm64 and x86_64)"

# The client in Contents/MacOS; its lots and the mock install in Contents/Resources, where the
# client looks for them (ClientOptions.simburbiaFolder), and where signing expects data to be.
STAGE="$WORK/macos/$BASENAME"
stage "$STAGE"
APPDIR="$WORK/macos/$APP.app"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/Contents/MacOS" "$APPDIR/Contents/Resources"
mv "$STAGE/$EXE" "$APPDIR/Contents/MacOS/$EXE"
mv "$STAGE"/* "$APPDIR/Contents/Resources/"

# The icon, made from the PNG with macOS's own tools.
ICONSET="$WORK/macos/$EXE.iconset"
rm -rf "$ICONSET"
mkdir -p "$ICONSET"
for size in 16 32 128 256; do
    sips -z "$size" "$size" "$ROOT/Simburbia/packaging/simburbia.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z "$double" "$double" "$ROOT/Simburbia/packaging/simburbia.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APPDIR/Contents/Resources/$APP.icns"

sed -e "s/@VERSION@/$VERSION/g" -e "s/@BUILD_SHA@/$BUILD_SHA/g" "$HERE/Info.plist.in" >"$APPDIR/Contents/Info.plist"
plutil -lint "$APPDIR/Contents/Info.plist" >/dev/null || fail "Info.plist isn't valid."

codesign --force --deep --sign - "$APPDIR" || fail "couldn't sign the app."
smoke_test "$APPDIR/Contents/MacOS/$EXE"

OUT="$DIST/$BASENAME.zip"
rm -f "$OUT"
ditto -c -k --keepParent "$APPDIR" "$OUT"
echo "wrote $OUT"
echo "==> done"
