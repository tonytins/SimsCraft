# ScriptOracle (sso-oracle)

Experiments written in SimsScript. A scenario is a small object, in the language SimsScript
compiles, with a header that says how long to run it and which object variables it should leave:

```text
// Arithmetic: SimAntics' 16-bit rules.
// @ticks 0
// @expect divided = -1
integer divided;

default {
    initialize() { divided = 7 / 0; }
}
```

Plain comment lines describe the scenario. `@ticks N` is how many ticks to run after the object's
initialize (0 to 30,000; default 1). `@expect NAME = VALUE` is a variable's value at the end. An
unknown directive is an error, so a typo doesn't drop a check silently.

The scenarios that ship with it are in `Sources/ScriptOracleCore/Scenarios/`.

```sh
swift run --package-path NSOClient/ScriptOracle sso-oracle check         # compile each one
swift run --package-path NSOClient/ScriptOracle sso-oracle run           # run each on NSOClient's VM
swift run --package-path NSOClient/ScriptOracle sso-oracle build DIR     # write the compiled objects
```

`--scenarios DIR` reads a folder of your own instead.

## How a scenario runs

Each scenario compiles to an ordinary object: an IFF with an `OBJD` (a normal object with the
scenario's GUID, its variable count, and a function table), the `OBJf` table, and the routines.
`build` writes them as `NAME.iff`, a folder FreeSO's content can load as `Content/Objects`, with
`scenarios.tsv` listing each GUID, name, and tick count.

`run` loads them as standalone objects and runs each as `fso-oracle run-objects` runs an object:
the lot (FreeSO's `empty_lot_fso.xml` unless `--blueprint` says otherwise) loads with its objects
taken out, ticks once, and is reseeded; the object is created out of the world, which runs its
`initialize`; then the lot ticks `@ticks` times. Each scenario prints a record line,

```text
counting 5c000002 attributes count=212
```

then whether it met its expectations. `--records-only` prints just the records. The install is
`--game`, else `$TSO_GAME_DIR`, else `MockInstall`; the scenarios use none of its content.

Scenario GUIDs start at `0x5C000001`, in name order. TSO's own GUIDs span the whole 32-bit range,
so `run` refuses one the install already has rather than running the wrong object.

## Both VMs

`nso-oracle` and `fso-oracle` compare what NSOClient and FreeSO do with TSO's own objects.
`sso-oracle` asks smaller, readable questions whose answers both VMs must agree on: `build` writes
the compiled objects, `fso-oracle run-scenarios` runs them on FreeSO's VM and prints the same
record lines, and `compare` sets the two side by side:

```sh
NSOClient/scripts/scenario-oracle.sh --mock     # or with TSO_GAME_DIR set, without --mock
```

```text
arithmetic agrees
counting agrees
2 agree, 0 differ, 0 inconclusive
```

A scenario that one side couldn't measure (NSOClient hit an error, FreeSO couldn't create the
object, or FreeSO has no record) is inconclusive, never agreement. FreeSO suppresses errors inside
an object's thread, so only NSOClient's show; the comparison rests on the attributes.
