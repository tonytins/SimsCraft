# TSOFiles C API

`TSOFilesC` is a C module over the existing `TSOFiles` Swift implementation.
Its C functions are thin forwards to Swift C-ABI entry points. It does not
reimplement archive parsing or compression. Include
`Sources/TSOFilesC/include/TSOFilesC.h` and use the `TSOFilesC` SwiftPM product
from a dependent package.

The API exposes RefPack decompression and DBPF, FAR1, and FAR3 archive reads.
FAR1 open takes variant `0` for FAR1a and `1` for FAR1b. Archive entries are
addressed by zero-based index; FAR1 and FAR3 also support exact UTF-8 name
lookup, while FAR3 supports lookup by its file and type IDs.

Entry data and entry names are copied into library-allocated buffers. Names
contain UTF-8 bytes without a trailing NUL. Release all returned buffers with
`buffer_free`. Release archive handles with their matching DBPF, FAR1, or FAR3
close function. Byte-output pointers are initialized to null
(and their sizes to zero) before work starts, so callers can safely clean up
after an error.

Functions return `TSOFilesCStatus` values. In addition to invalid-argument and
out-of-range statuses, archive open reports format-specific not-archive and
truncated errors. FAR3 entry reads report missing entries and RefPack
decompression failures. Handle pointers must be live handles returned by this
API; invalid or already-released handles are not recoverable.

Run `swift test --package-path NSOClient/TSOFilesC` for the Swift API tests and
`swift run --package-path NSOClient/TSOFilesC TSOFilesCCSmoke` to compile and
run a C caller.
