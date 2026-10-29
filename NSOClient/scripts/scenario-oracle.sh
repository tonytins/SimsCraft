#!/usr/bin/env bash
# Runs sso-oracle's SimsScript scenarios on both VMs and compares them: sso-oracle build compiles
# each scenario to an object, fso-oracle run-scenarios runs those objects on FreeSO's VM, and
# sso-oracle compare runs them on NSOClient's and sets the two side by side.
#
#   NSOClient/scripts/scenario-oracle.sh [--mock] [OUTPUT_DIR]     (default: $TMPDIR/scenario-oracle)
#
# The install is TSO_GAME_DIR, or with --mock, NSOClient/MockInstall; the scenarios use none of its
# content. Exits with 1 if any scenario differs or is inconclusive. Needs the .NET SDK and Swift.
# OUTPUT_DIR gets objects/ (what build wrote) and fso.records (FreeSO's record lines).
set -euo pipefail

repository="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
game="${TSO_GAME_DIR:-}"
if [[ "${1:-}" == "--mock" ]]; then
    game="$repository/NSOClient/MockInstall/TSOClient"
    shift
fi
if [[ -z "$game" ]]; then
    echo "scenario-oracle: set TSO_GAME_DIR, or pass --mock" >&2
    exit 2
fi
output="${1:-${TMPDIR:-/tmp}/scenario-oracle}"
rm -rf "$output/objects"
mkdir -p "$output"

sso=(swift run --package-path "$repository/NSOClient/ScriptOracle" sso-oracle)
"${sso[@]}" build "$output/objects"
dotnet build "$repository/NSOClient/FSO.Oracle" -c Release >/dev/null
dotnet run --project "$repository/NSOClient/FSO.Oracle" -c Release --no-build -- \
    run-scenarios --game "$game" --scenarios "$output/objects" >"$output/fso.records" 2>"$output/fso.log"
"${sso[@]}" compare --game "$game" --strict "$output/fso.records"
