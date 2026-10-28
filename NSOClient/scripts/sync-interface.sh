#!/usr/bin/env bash
# Translates CityLimits' reusable interface files into NSOClient/Interface with cs2swift.
#
# Usage: NSOClient/scripts/sync-interface.sh <CityLimits checkout> <cs2swift checkout>
#
# Replaces Sources/Interface/CityLimits wholly, so a file CityLimits drops goes too; the
# hand-written Swift in Sources/Interface/NewSO is never touched. Exits non-zero if any file
# fails to translate, leaving the previous translation in place.
set -euo pipefail

nsoclient="$(cd "$(dirname "$0")/.." && pwd)"
citylimits="$(cd "${1:?CityLimits checkout}" && pwd)"
cs2swift="$(cd "${2:?cs2swift checkout}" && pwd)"
interface="$citylimits/CityLimits.Interface"
target="$nsoclient/Interface/Sources/Interface/CityLimits"

# The generic windows and controls. CityLimits' map view, news ticker, and loading screen
# are built on its city; NewSO writes its own.
files=(
    UI/IMovableWindow.cs UI/WindowPlacement.cs UI/TextWrap.cs UI/ButtonRow.cs UI/TextField.cs
    UI/TextArea.cs UI/WindowFrame.cs UI/ConfirmPanel.cs UI/NoticePanel.cs
    Rendering/Camera.cs
)

swift build --package-path "$cs2swift" --product cs2swift >/dev/null
staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT
(cd "$interface" && "$cs2swift/.build/debug/cs2swift" -o "$staging" --reference "$nsoclient/Interface/Sync/NewSO.cs" "${files[@]}")

rm -rf "$target"
mv "$staging" "$target"
trap - EXIT
echo "CityLimits $(git -C "$citylimits" rev-parse --short HEAD) translated into $target"
