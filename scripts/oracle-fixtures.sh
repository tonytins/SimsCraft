#!/usr/bin/env bash
# Runs every experiment on FreeSO, through fso-oracle, and writes its records: the
# fixtures the SBOracle tests read (TSO_ORACLE_DIR) and the FreeSO side of oracle-review.sh.
# The records depend on the install, so they stay out of the repository.
#
#   scripts/oracle-fixtures.sh [--mock] [OUTPUT_DIR]     (default: $TMPDIR/fso-oracle-fixtures)
#   TSO_ORACLE_DIR=OUTPUT_DIR swift test --package-path SBOracle
#
# Reads the install in TSO_GAME_DIR, or with --mock, MockInstall (whose lots are
# MockInstall/Lots). Needs the .NET SDK and python3. Set ORACLE_BUILT=1 to skip
# building fso-oracle. Writes:
#   objects.tsv                   list-objects: what loads for every object
#   lots.run, lots.digests        the lots with objects and the Sims joining each (tab-separated;
#                                 see lot_sims), and run-lot on each (lines prefixed with
#                                 its file name); lots.run, primitives.lot, and rooms.lots name
#                                 lots relative to where they come from (oracle-lots.sh)
#   lots.leftout                  the objects fso-oracle left out of each (file name, tab, GUID)
#   PRIMITIVE.requests.jsonl      generated cases for each ported primitive (OracleCases/make_cases.py)
#   PRIMITIVE.responses.jsonl     run-primitive responses to them
#   primitives.lot, primitives.leftout   the lot run-primitive loads, and the objects it left out
#   PRIMITIVE.sim-requests.jsonl  cases for primitives that need a Sim, run on the lot in sim-primitives.lot
#                                 (LOT, Sim count, template), with its left-out objects in sim-primitives.leftout
#   blueprints/, rooms.lots       synthetic lots (OracleCases/make_blueprints.py), and every lot
#                                 room-maps reads
#   rooms.jsonl                   room-maps for them
#   sprites.tsv                   sprites: every object sprite frame and drawing group, decoded
#   architecture.tsv              architecture: the sprite chunks each wall, wall style, and floor resolves to
#   operands.tsv                  operands: each operand Simburbia decodes but doesn't run, field by field
#   timings.tsv, *.log            seconds per command, and fso-oracle's messages
set -euo pipefail

repository="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repository/scripts/oracle-lots.sh"
mock=false
if [[ "${1:-}" == "--mock" ]]; then
    mock=true
    shift
fi
output="${1:-${TMPDIR:-/tmp}/fso-oracle-fixtures}"
if $mock; then
    game="$repository/MockInstall/TSOClient"
    lots_folder="MockInstall/Lots"
    primitive_lot="repository/MockInstall/Lots/mock-lot.xml"
    sim_primitive_lot="repository/MockInstall/Lots/mock-lot-sim.xml"
    sim_primitive_template=4D4F4307
else
    game="${TSO_GAME_DIR:?set TSO_GAME_DIR to your TSO install, or pass --mock}"
    lots_folder="Lots"
    primitive_lot="freeso/Blueprints/empty_lot_fso.xml"
    sim_primitive_lot="freeso/Blueprints/empty_lot_fso.xml"
    sim_primitive_template=-
fi
lots=()
for lot in "$repository/$lots_folder"/*.xml; do lots+=("repository/$lots_folder/$(basename "$lot")"); done
# TSO's own blueprints, the job lots 1.1097.1.0 ships (older installs have none), read from the
# install, never copied here. They join the room maps; their lot runs wait for Sims, since each
# one's controller reaches online_jobs_call at once.
install_lots=()
for lot in "$game"/housedata/blueprints/*.xml; do
    if [[ -f "$lot" ]]; then install_lots+=("install/housedata/blueprints/$(basename "$lot")"); fi
done
empty_lot="freeso/Blueprints/empty_lot_fso.xml"
# Kept in step with the SBOracle tests (lotRunsMatchFreeSO).
# A full in-game day (150 ticks a game minute), compared every game hour.
lot_ticks=216000
lot_every=9000
sim_primitive_sims=1
# Primitives whose cases need a Sim, run on the Sim lot (sim-primitives.lot).
sim_primitives=(set_motive_deltas sim_expression)
primitives=(expression sleep test_object_type refresh set_to_next random_number play_sound create_object_instance find_location_for run_tree_by_name stackobj_notify_out_of_idle get_distance_to get_direction_to transfer_funds remove_object_instance set_balloon_headline idle_for_input breakpoint special_effect stop_all_sounds get_terrain_info)

mkdir -p "$output"
rm -f "$output/timings.tsv" "$output/lots.digests" "$output/lots.leftout"
oracle() {
    dotnet run --project "$repository/FSO.Oracle" -c Release --no-build -- "$@" --game "$game"
}
# timed NAME COMMAND...: runs COMMAND and records its seconds in timings.tsv.
timed() {
    local name="$1" start end
    shift
    start=$(date +%s.%N)
    "$@"
    end=$(date +%s.%N)
    printf '%s\t%s\n' "$name" "$(awk "BEGIN { printf \"%.1f\", $end - $start }")" >>"$output/timings.tsv"
}
# The objects fso-oracle reported leaving out of a lot, from its messages: one GUID a line.
left_out() {
    grep -o 'object 0x[0-9A-Fa-f]*; left out' "$1" | awk '{ print substr($2, 1, length($2) - 1) }' || true
}

if [[ "${ORACLE_BUILT:-}" != 1 ]]; then
    echo "Building fso-oracle..."
    dotnet build "$repository/FSO.Oracle" -c Release >/dev/null
fi

echo "Listing objects..."
timed list-objects oracle list-objects >"$output/objects.tsv" 2>"$output/objects.log"

echo "Running each lot..."
# Each lot with the Sims that join it (lot_sims), tab-separated.
for lot in "$empty_lot" "${lots[@]}"; do printf '%s\t%s\n' "$lot" "$(lot_sims "$lot")"; done >"$output/lots.run"
run_lots() {
    local lot file sims template
    while IFS=$'\t' read -r lot sims template; do
        file="$(basename "$lot")"
        mapfile -t joining < <(sims_options "${sims:-0}" "${template:--}")
        oracle run-lot --blueprint "$lot" --ticks "$lot_ticks" --every "$lot_every" "${joining[@]}" 2>"$output/lot.log" | sed "s|^|$file |"
        cat "$output/lot.log" >>"$output/lots.log"
        left_out "$output/lot.log" | sed "s|^|$file\t|" >>"$output/lots.leftout"
    done < <(resolve_lots "$output" "$game" "$repository" <"$output/lots.run")
}
: >"$output/lots.log"
timed run-lot run_lots >"$output/lots.digests"

# The cases name the lot's objects by GUID, in object ID order (1 is the caller, 2 the stack
# object), and its multi-tile masters, so they're read from the lot run-primitive loads.
echo "$primitive_lot" >"$output/primitives.lot"
primitive_lot_path="$(echo "$primitive_lot" | resolve_lots "$output" "$game" "$repository")"
lot=$(echo '{"opcode":2,"stackObject":2}' | oracle run-primitive --blueprint "$primitive_lot_path" 2>"$output/primitives.log")
left_out "$output/primitives.log" >"$output/primitives.leftout"
ORACLE_GUIDS=$(echo "$lot" | python3 -I -c 'import json, sys; print(",".join(entry[1] for entry in json.load(sys.stdin)["lot"]))')
ORACLE_MASTERS=$(echo "$lot" | python3 -I -c 'import json, sys; print(",".join(group[1] for group in json.load(sys.stdin)["groups"] if group[1]))')
export ORACLE_GUIDS ORACLE_MASTERS
for primitive in "${primitives[@]}"; do
    echo "Running $primitive cases..."
    python3 -I "$repository/SimAntics/OracleCases/make_cases.py" "$primitive" "$output/$primitive.requests.jsonl"
    timed "run-primitive $primitive" oracle run-primitive --blueprint "$primitive_lot_path" \
        <"$output/$primitive.requests.jsonl" >"$output/$primitive.responses.jsonl" 2>"$output/$primitive.log"
done

# Primitives that need a Sim run on their own lot, so the cases above keep theirs: the mock Sim on
# MockInstall's Sim lot, or FreeSO's template person joining the empty lot on a real install. The
# lot and its Sims are recorded as "LOT<tab>COUNT<tab>TEMPLATE"; the cases learn the Sim's object
# ID (ORACLE_SIM) from the lot as loaded.
printf '%s\t%s\t%s\n' "$sim_primitive_lot" "$sim_primitive_sims" "$sim_primitive_template" >"$output/sim-primitives.lot"
sim_lot_path="$(echo "$sim_primitive_lot" | resolve_lots "$output" "$game" "$repository")"
mapfile -t sim_joining < <(sims_options "$sim_primitive_sims" "$sim_primitive_template")
sim_lot=$(echo '{"opcode":2}' | oracle run-primitive --blueprint "$sim_lot_path" "${sim_joining[@]}" 2>"$output/sim-primitives.log" || true)
left_out "$output/sim-primitives.log" >"$output/sim-primitives.leftout"
if ORACLE_SIM=$(echo "$sim_lot" | python3 -I -c 'import json, sys; print(json.load(sys.stdin)["sims"][0][0])' 2>/dev/null); then
    ORACLE_GUIDS=$(echo "$sim_lot" | python3 -I -c 'import json, sys; print(",".join(entry[1] for entry in json.load(sys.stdin)["lot"]))')
    export ORACLE_GUIDS ORACLE_SIM
    for primitive in "${sim_primitives[@]}"; do
        echo "Running $primitive cases with a Sim..."
        python3 -I "$repository/SimAntics/OracleCases/make_cases.py" "$primitive" "$output/$primitive.sim-requests.jsonl"
        timed "run-primitive $primitive" oracle run-primitive --blueprint "$sim_lot_path" "${sim_joining[@]}" \
            <"$output/$primitive.sim-requests.jsonl" >"$output/$primitive.responses.jsonl" 2>"$output/$primitive.log"
    done
else
    # FreeSO couldn't join a Sim here (the unpatched discs lack its skeleton): no Sim cases.
    echo "FreeSO couldn't join a Sim to $sim_primitive_lot; skipping the Sim primitives (see sim-primitives.log)"
fi

echo "Room maps..."
python3 -I "$repository/SimAntics/OracleCases/make_blueprints.py" "$output/blueprints" >/dev/null
# FreeSO's empty_lot.xml and TSO's job lots name a DTD; fso-oracle drops it, as .NET since Core refuses one.
{ sed 's|.*/|results/blueprints/|' "$output/blueprints/blueprints.txt"; echo "$empty_lot"; echo "freeso/Blueprints/empty_lot.xml"
  if (( ${#install_lots[@]} > 0 )); then printf '%s\n' "${install_lots[@]}"; fi
  for lot in "$repository"/Lots/*.xml "$repository"/MockInstall/Lots/*.xml; do
      echo "repository/${lot#"$repository/"}"
  done; } >"$output/rooms.lots"
timed room-maps oracle room-maps < <(resolve_lots "$output" "$game" "$repository" <"$output/rooms.lots") \
    >"$output/rooms.jsonl" 2>"$output/rooms.log"

echo "Sprites..."
timed sprites oracle sprites >"$output/sprites.tsv" 2>"$output/sprites.log"

echo "Architecture..."
timed architecture oracle architecture >"$output/architecture.tsv" 2>"$output/architecture.log"

echo "Operands..."
timed operands oracle operands >"$output/operands.tsv" 2>"$output/operands.log"

echo "Done. Compare with: TSO_ORACLE_DIR=$output swift test --package-path SBOracle"
