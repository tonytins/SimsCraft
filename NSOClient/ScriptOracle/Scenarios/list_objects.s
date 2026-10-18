// list_objects.s - produces same output format as nso-oracle list-objects
// Format: GUID<TAB>label<TAB>resource<TAB>semi<TAB>treesByName<TAB>routines<TAB>tuning<TAB>entryPoints (or error/missing)
integer result;

default {
    initialize() { result = 0; }
    main() { }
}
