# Sourced by oracle-fixtures.sh and oracle-review.sh: the lot lists they write (lots.run,
# primitives.lot, rooms.lots) name each blueprint relative to where it comes from, so records
# made in one checkout, or kept from an earlier run, still find their lots:
#
#   results/blueprints/synthetic-000.xml     the results folder (the synthetic lots)
#   install/housedata/blueprints/x.xml       the TSO install
#   freeso/Blueprints/empty_lot_fso.xml      FreeSO's content folder
#   repository/Simburbia/Lots/x.xml          this repository

# resolve_lots RESULTS GAME REPOSITORY: reads a lot list on standard input and prints each lot's
# full path.
resolve_lots() {
    local results="$1" game="$2" repository="$3"
    sed -e "s|^results/|$results/|" \
        -e "s|^install/|$game/|" \
        -e "s|^freeso/|$repository/TSOClient/tso.content/Content/|" \
        -e "s|^repository/|$repository/|"
}

# lot_sims FILE: the Sims run-lot joins to a lot after loading it, as "COUNT<tab>TEMPLATE" (a hex
# GUID, or - for FreeSO's template person). Most lots have none. MockInstall's Sim lot joins its
# made-up Sim, which arrives on tile 3,3, the join's fallback without a mailbox.
lot_sims() {
    case "$(basename "$1")" in
        mock-lot-sim.xml) printf '1\t4D4F4307\n' ;;
        *) printf '0\t-\n' ;;
    esac
}

# sims_options COUNT TEMPLATE: the run-lot options for them, both oracles taking the same.
sims_options() {
    local count="$1" template="$2"
    if (( count > 0 )); then
        printf '%s\n' --sims "$count"
        if [[ "$template" != - ]]; then printf '%s\n' --sim-template "$template"; fi
    fi
}
