#!/usr/bin/env bash
# Compares nso-oracle and sso-oracle on each install.

set -euo pipefail

repository="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mock=false
case "${1:-}" in
    --mock) mock=true; shift ;;
esac

installs=()
if $mock; then
    installs+=("mock=$repository/NSOClient/MockInstall/TSOClient")
else
    [[ -n "${TSO_GAME_DIR:-}" ]] && installs+=("production=$TSO_GAME_DIR")
    [[ -n "${TSO_BETA_DIR:-}" ]] && installs+=("beta=$TSO_BETA_DIR")
fi
if (( ${#installs[@]} == 0 )); then
    echo "script-oracle-review: set TSO_GAME_DIR, TSO_BETA_DIR, or both, or pass --mock" >&2
    exit 2
fi

echo "Building both oracles..."
swift build --package-path "$repository/NSOClient/NSOOracle" -c release >/dev/null
swift build --package-path "$repository/NSOClient/ScriptOracle" -c release >/dev/null
nso_binary="$(swift build --package-path "$repository/NSOClient/NSOOracle" -c release --show-bin-path)/nso-oracle"
sso_binary="$(swift build --package-path "$repository/NSOClient/ScriptOracle" -c release --show-bin-path)/sso-oracle"

for install in "${installs[@]}"; do
    name="${install%%=*}"
    game="${install#*=}"
    echo "[$name] Comparing nso-oracle vs sso-oracle..."
    # Generate records for comparison
    echo "not fully implemented - stubs exist" >&2
    exit 1
done
