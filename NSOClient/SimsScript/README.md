# SimsScript (proof of concept)

Text forms of SimAntics behavior, so objects can be read, edited, and written on any platform
instead of only in a visual editor. Everything compiles to ordinary BHAV and `OBJf` chunks, so the
FreeSO VM, NSOClient's VM, and lockstep multiplayer run the result unchanged.

This is a proof of concept for a later milestone (Yatesport, roadmap decision 5). It shows the
idea is feasible; it isn't a usable language yet.

## Reading an object

`Listing` writes routines to be read, one line per instruction, with the names the files give
their numbers: calls by the called routine's label, parameters and locals by the routine's `TPRP`,
the object's attributes by its `STR#` 256, and constants by their `TRCN` labels with their
values. Primitives show their operands in words, both the ones NSOClient runs and
the ones it only decodes so far (SimAntics' `PrimitiveTable.unportedOperands`, checked field by
field against FreeSO); an opcode FreeSO registers no layout for keeps its bytes, marked "not
ported yet". A made-up example:

```text
4096 "init": 1 parameter (brightness)
  0: call "setup" (temp 0)                                           then 1, else unset
  1: "glow" (my attribute 2) := "Default Glow" (constant = 50)       then 2, else unset
  2: clear flag 11 of my flags                                       then return true, else unset
```

`unset` is branch target 253: FreeSO goes on along the other branch, while the SimAntics Wiki
describes it as an error in the original engine. A listing doesn't convert back to routines;
`Assembly` does. The `simsscript` command lists an install's objects:

```sh
swift run --package-path NSOClient/SimsScript simsscript list 0x4D4F4301        # by GUID
swift run --package-path NSOClient/SimsScript simsscript list mockchair --routine 4096
```

`OBJECT` is a GUID or a name (the object's file name or its catalog name); `--semi-global` adds
the semi-global's routines. The install is `--game`, else `$TSO_GAME_DIR`, else MockInstall.

## Assembly

`Assembly` writes routines as text and reads them back, one line per instruction:

```text
bhav 4096 "main" version 0x8002 type 0 arguments 4 locals 2 flags 0x0000
  0: expression temps 0 := literal 5 -> 1 / return-false
  1: call 4097 1 0 0 0 -> return-true / return-false
  2: primitive 44 0a00000100000000 -> 2 / 3
```

Expression and calls are readable; other primitives keep their 8 operand bytes in hex until
they're ported, so nothing is lost. Every routine in the beta (15,723) converts to text and
back unchanged.

## The language

`ScriptCompiler` compiles a small LSL-like language:

```text
integer count;                    // object variables are attributes, in order

add(integer amount) {             // functions are private routines (up to 4 parameters)
    count += amount;
}

default {                         // events are entry points: initialize, main, cleanup, ...
    initialize() { count = 0; }
    main() {
        integer i = 3;            // locals
        while (i > 0) { add(2); i -= 1; }
        if (count >= 6 && !(count == 7)) { return TRUE; }
    }
}
```

Values are 16-bit integers with SimAntics arithmetic (it wraps; dividing by zero gives -1). A
function returns only true or false, so a call can be a condition. Primitives are exposed as built-ins for common operations. Still missing: strings, `state`s, interactions, and a full decompiler.

## How feasibility is tested

- Assembly round trip over every routine in the install (`RealAssemblyTests`, needs `TSO_GAME_DIR`).
- Every object's routines list, one line per instruction (`RealListingTests`, needs `TSO_GAME_DIR`).
- Operand encoders re-encode every Expression and call operand to its bytes (SimAntics tests).
- Compiled scripts run as objects on the Swift VM and leave the expected values (`CompilerTests`).
