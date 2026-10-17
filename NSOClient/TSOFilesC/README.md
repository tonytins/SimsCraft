# TSOFiles C API

`TSOFilesC` is a C module over the existing `TSOFiles` Swift implementation.
Its C functions are thin forwards to Swift C-ABI entry points. It does not
reimplement RefPack or DBPF parsing. Include `Sources/TSOFilesC/include/TSOFilesC.h`
and use the `TSOFilesC` SwiftPM product from a dependent package.

RefPack decompression and DBPF entry extraction return library-allocated byte
buffers. Release them with `tsofiles_c_buffer_free`. DBPF handles returned by
`tsofiles_c_dbpf_open` must be released with `tsofiles_c_dbpf_close`.

Functions return `TSOFilesCStatus` values. Byte-output pointers are initialized
to null (and their sizes to zero) before work starts, so callers can safely
clean up after an error. Pointers passed to handle operations must be a live
handle returned by this API; invalid or already-released handles are not
recoverable.

Run `swift test --package-path NSOClient/TSOFilesC` for the Swift API tests and
`swift run --package-path NSOClient/TSOFilesC TSOFilesCCSmoke` to compile and
run a C caller.
