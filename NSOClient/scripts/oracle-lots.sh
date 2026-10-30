# Sourced by oracle-fixtures.sh and oracle-review.sh: the lot lists they write (lots.run,
# primitives.lot, rooms.lots) name each blueprint relative to where it comes from, so records
# made in one checkout, or kept from an earlier run, still find their lots:
#
#   results/blueprints/synthetic-000.xml     the results folder (the synthetic lots)
#   install/housedata/blueprints/x.xml       the TSO install
#   freeso/Blueprints/empty_lot_fso.xml      FreeSO's content folder
#   repository/NSOClient/Lots/x.xml          this repository

# resolve_lots RESULTS GAME REPOSITORY: reads a lot list on standard input and prints each lot's
# full path.
resolve_lots() {
    local results="$1" game="$2" repository="$3"
    sed -e "s|^results/|$results/|" \
        -e "s|^install/|$game/|" \
        -e "s|^freeso/|$repository/TSOClient/tso.content/Content/|" \
        -e "s|^repository/|$repository/|"
}
