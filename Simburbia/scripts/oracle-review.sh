#!/usr/bin/env bash
# Runs the same experiments through fso-oracle (FreeSO) and sb-oracle (Simburbia) on each install,
# reports whether their records agree, and with --review writes docs/results/sb-review.md. Run it after a phase or milestone,
# not every session: it reruns every object and every primitive case on every install.
#
#   Simburbia/scripts/oracle-review.sh [--review | --mock] [OUTPUT_DIR]     (default: $TMPDIR/oracle-review)
#
# Installs come from TSO_GAME_DIR ("production"), TSO_CLASSIC_DIR ("classic"), and TSO_BETA_DIR
# ("beta"); any of them, and with
# --review, Simburbia/MockInstall ("mock") too, so the report has a section anyone can reproduce.
# --mock runs on the mock install alone, as CI does: it never writes the review, and it fails on
# any disagreement.
# Needs the .NET SDK, Swift, and python3. Each install gets OUTPUT_DIR/NAME/fso/, FreeSO's
# records from oracle-fixtures.sh (also a TSO_ORACLE_DIR for the SBOracle tests), and
# OUTPUT_DIR/NAME/nso/, Simburbia's records of the same experiments in the same files, each with
# timings.tsv.
#
# With ORACLE_REUSE=1, an install whose FreeSO records are already complete in OUTPUT_DIR (the last
# file oracle-fixtures.sh writes, operands.tsv, exists) keeps them instead of running FreeSO again,
# so an interrupted review can resume. Use it only with records from the same commit.
set -euo pipefail

repository="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repository/Simburbia/scripts/oracle-lots.sh"
review=false
mock=false
case "${1:-}" in
    --review) review=true; shift ;;
    --mock) mock=true; shift ;;
esac
output="${1:-${TMPDIR:-/tmp}/oracle-review}"

installs=()
if $mock; then
    installs+=("mock=$repository/Simburbia/MockInstall/TSOClient")
else
    [[ -n "${TSO_GAME_DIR:-}" ]] && installs+=("production=$TSO_GAME_DIR")
    [[ -n "${TSO_CLASSIC_DIR:-}" ]] && installs+=("classic=$TSO_CLASSIC_DIR")
    [[ -n "${TSO_BETA_DIR:-}" ]] && installs+=("beta=$TSO_BETA_DIR")
    if $review && (( ${#installs[@]} > 0 )); then installs+=("mock=$repository/Simburbia/MockInstall/TSOClient"); fi
fi
if (( ${#installs[@]} == 0 )); then
    echo "oracle-review: set TSO_GAME_DIR, TSO_CLASSIC_DIR, or TSO_BETA_DIR, or pass --mock" >&2
    exit 2
fi
# Kept in step with oracle-fixtures.sh.
# A full in-game day (150 ticks a game minute), compared every game hour.
lot_ticks=216000
lot_every=9000

echo "Building both oracles..."
dotnet build "$repository/Simburbia/FSO.Oracle" -c Release >/dev/null
swift build --package-path "$repository/Simburbia/SBOracle" -c release >/dev/null
nso_binary="$(swift build --package-path "$repository/Simburbia/SBOracle" -c release --show-bin-path)/sb-oracle"

for install in "${installs[@]}"; do
    name="${install%%=*}"
    game="${install#*=}"
    fso_folder="$output/$name/fso"
    folder="$output/$name/nso"
    mkdir -p "$folder"
    rm -f "$folder"/*.jsonl "$folder"/*.digests "$folder"/*.tsv "$folder/log.txt"

    echo "[$name] FreeSO's side..."
    if [[ "${ORACLE_REUSE:-}" == 1 && -f "$fso_folder/operands.tsv" ]]; then
        echo "[$name] Reusing FreeSO's records in $fso_folder"
    elif [[ "$name" == mock ]]; then
        ORACLE_BUILT=1 "$repository/Simburbia/scripts/oracle-fixtures.sh" --mock "$fso_folder" | sed "s|^|[$name] |"
    else
        ORACLE_BUILT=1 TSO_GAME_DIR="$game" "$repository/Simburbia/scripts/oracle-fixtures.sh" "$fso_folder" | sed "s|^|[$name] |"
    fi

    nso() { "$nso_binary" "$1" --game "$game" "${@:2}"; }
    # timed NAME COMMAND...: runs COMMAND, with its messages in log.txt, and records its seconds.
    timed() {
        local label="$1" start end
        shift
        start=$(date +%s.%N)
        "$@" 2>>"$folder/log.txt"
        end=$(date +%s.%N)
        printf '%s\t%s\n' "$label" "$(awk "BEGIN { printf \"%.1f\", $end - $start }")" >>"$folder/timings.tsv"
    }

    echo "[$name] Simburbia's side..."
    timed list-objects nso list-objects >"$folder/objects.tsv"
    # Each lot with the objects fso-oracle left out of it left out here too.
    run_lots() {
        local lot file leave sims template
        while IFS=$'\t' read -r lot sims template; do
            file="$(basename "$lot")"
            mapfile -t leave < <(awk -F'\t' -v f="$file" '$1 == f { print "--leave-out"; print $2 }' "$fso_folder/lots.leftout")
            mapfile -t joining < <(sims_options "${sims:-0}" "${template:--}")
            nso run-lot --blueprint "$lot" --ticks "$lot_ticks" --every "$lot_every" "${leave[@]}" "${joining[@]}" | sed "s|^|$file |"
        done < <(resolve_lots "$fso_folder" "$game" "$repository" <"$fso_folder/lots.run")
    }
    timed run-lot run_lots >"$folder/lots.digests"
    mapfile -t leave < <(awk '{ print "--leave-out"; print $1 }' "$fso_folder/primitives.leftout")
    for requests in "$fso_folder"/*.requests.jsonl; do
        primitive="$(basename "$requests" .requests.jsonl)"
        timed "run-primitive $primitive" nso run-primitive \
            --blueprint "$(resolve_lots "$fso_folder" "$game" "$repository" <"$fso_folder/primitives.lot")" "${leave[@]}" \
            <"$requests" >"$folder/$primitive.responses.jsonl"
    done
    timed room-maps "$nso_binary" room-maps < <(resolve_lots "$fso_folder" "$game" "$repository" <"$fso_folder/rooms.lots") \
        >"$folder/rooms.jsonl"
    timed sprites nso sprites >"$folder/sprites.tsv"
    timed architecture nso architecture >"$folder/architecture.tsv"
    timed operands nso operands >"$folder/operands.tsv"

    # The randomized study: sampled objects on lots, a game day on both sides, for a time budget
    # (ORACLE_STUDY_MINUTES, 5 by default). With --review, each install's ledger in docs/results
    # carries over, so a run samples what earlier ones haven't; the mock install, as CI runs it,
    # takes a fixed seed for a minute.
    study=(study --game "$game" --fso-objects "$fso_folder/objects.tsv" --out "$folder/study"
           --fso-oracle "$repository/Simburbia/FSO.Oracle/bin/Release/net10.0/fso-oracle")
    # On a real install, the samples also go on the floor plans of TSO's own job lots, emptied.
    if [[ "$name" != mock ]]; then
        study+=(--floor-plan "$repository/TSOClient/tso.content/Content/Blueprints/empty_lot_fso.xml")
        for plan in "$game"/housedata/blueprints/*.xml; do
            if [[ -f "$plan" ]]; then study+=(--floor-plan "$plan"); fi
        done
    fi
    if [[ "$name" == mock ]]; then
        study+=(--seed 1 --minutes 1 --ledger "$folder/ledger.tsv")
    elif $review; then
        study+=(--minutes "${ORACLE_STUDY_MINUTES:-5}" --ledger "$repository/docs/results/sb-study-$name.tsv")
    else
        study+=(--minutes "${ORACLE_STUDY_MINUTES:-5}" --ledger "$folder/ledger.tsv")
    fi
    timed study "$nso_binary" "${study[@]}" >"$folder/study.log"

    arguments=(compare --fso "$fso_folder" --nso "$folder" --install "$name" --study "$folder/study/study.tsv")
    if $mock; then arguments+=(--strict); fi
    if $review; then
        arguments+=(--review "$repository/docs/results/sb-review.md"
                    --commit "$(git -C "$repository" rev-parse --short HEAD)")
    fi
    "$nso_binary" "${arguments[@]}"
done
