---
name: c-guidelines
description: "C design and coding conventions covering API design, naming, comments, control flow, memory ownership, error handling, input validation, and tests. Use when writing, reviewing, refactoring, or explaining C code or C APIs."
---

# C Programming Guidelines

These are conventions for writing C, not rigid rules. Follow the project's existing conventions when they differ, and call out any important tension. Prefer simple, explicit code over abstractions that make ownership, control flow, or failure behavior harder to see.

## When to Use

- Writing, reviewing, or refactoring C code and public C APIs.
- Investigating C memory-safety, undefined-behavior, or crash risks.
- Designing C interfaces, tests, or resource-lifetime rules.

Do not apply these conventions mechanically to C++, Objective-C, or another language just because its files use a related extension.

## Design and Clarity

- Design for one clear purpose per function. Keep functions small enough that inputs, effects, ownership, and failure paths are apparent.
- Iterate on APIs and implementation. Prefer the simplest design that satisfies compatibility and lifetime requirements.
- Ask the owner when a significant behavioral or API decision has multiple reasonable outcomes.
- Name variables and parameters for their role, not merely their C type. Use clear, consistent project naming; avoid cryptic and nonstandard abbreviations.
- Use established terms accurately and keep comments sparse. Comments should explain non-obvious constraints and current behavior, not repeat code or preserve change history.
- Document public declarations, especially ownership, valid inputs, output initialization, lifetime, and how errors are reported.

## Modern C Practices

- Use the newest C standard supported by the project toolchain. Prefer C17 when portability or toolchain support is uncertain; use C23 only when the project supports it.
- Include the standard header that declares each library function or type. Keep headers self-contained, use include guards, and provide function prototypes.
- Use `const` for data a function does not modify. Use `static` for file-private functions and objects.
- Use `size_t` for object sizes and array indices. Keep signedness and integer conversions explicit, and do not assume `int` or `long` has a particular width.
- Avoid non-standard extensions and platform-specific behavior unless required by the target; isolate and document such requirements.
- Prefer fixed-width integer types from `<stdint.h>` when a binary format or ABI requires an exact width. Do not use C bit-fields to describe on-disk or wire layouts.
- Avoid global mutable state. Pass dependencies and state explicitly, especially in reusable libraries.

## Control Flow and API Shape

- Keep control flow flat. Validate preconditions early and return through a clear error path rather than nesting the main operation deeply.
- Use `switch` for mutually exclusive cases when it makes intent clearer; handle every relevant enum or state explicitly.
- Make side effects visible in function names and signatures. Do not hide allocation, mutation, I/O, or cleanup behind surprising helpers.
- Keep interfaces narrow and cohesive. Split unrelated capabilities rather than building one generic interface with unclear responsibilities.
- Use opaque structs when callers should not depend on representation. Keep implementation details private to the source file where practical.
- Avoid variadic functions and untyped `void *` interfaces unless there is a clear C interoperability or ABI need. Document any unavoidable type and lifetime requirements.

## Never Crash

C code in this repository must not crash on invalid, truncated, or hostile input. Never rely on assertions or unchecked assumptions as input validation, and never terminate the process from reusable library code with `exit`, `abort`, or equivalent. Return an explicit error to the caller and preserve a clear distinction between success and failure.

- Validate pointers, lengths, counts, and enum values before dereferencing or using them.
- Before indexing or slicing, prove the index is in range and that the requested byte count remains. Check arithmetic before adding, multiplying, or converting sizes; prevent overflow before allocation or pointer arithmetic.
- Treat values read from files, archives, network buffers, and caller-owned structures as untrusted. Enforce format and resource limits before allocating or looping.
- Do not form pointers outside an object's bounds. Forming a pointer one past the end is permitted where the C standard allows it, but it must never be dereferenced.
- Avoid undefined behavior: do not read uninitialized data, violate alignment or effective-type rules, shift by an invalid amount, overflow signed integers, or depend on evaluation order.
- Initialize output parameters to a documented safe state before work that can fail. On failure, do not expose partial results unless the API explicitly promises them.
- Keep cleanup correct on every return path. Use a single cleanup section or small helpers when they make ownership and release order clearer.
- Do not replace malformed input with plausible defaults or silently truncate it. Report the failure through the established error mechanism.
- Add a focused regression test for each crash, memory-safety, or malformed-input fix.

## Memory and Resource Ownership

- Make ownership explicit: document who allocates, who frees, and how long borrowed pointers remain valid.
- Pair each successful allocation or acquired resource with exactly one release on every applicable path. Avoid leaks, double frees, and use-after-free.
- Check allocation and I/O results before use. Handle allocation failure without dereferencing a null pointer or losing already-owned resources.
- Prefer caller-provided buffers or a clearly documented allocate-and-return contract. Do not make callers guess the required size.
- Avoid returning pointers to stack storage or to temporary/internal storage whose lifetime is not guaranteed.
- Use `memcpy` only when ranges and non-overlap requirements are satisfied; use `memmove` when overlap is possible. Do not use string functions on data that is not known to be NUL-terminated.

## Errors

- Follow the repository's established error convention, such as status codes, an output error value, or a documented sentinel. Keep success and failure unambiguous.
- Propagate failures to a layer that can handle them. Do not swallow errors, return success-shaped fallback values, or print-and-continue in library code.
- Report enough context for callers to act, without exposing uninitialized or partial output.
- Use `errno` only when the API's underlying C or POSIX operation defines it, and capture it before another call can change it.
- Reserve logging, printing, and process-level policy for executable or application boundaries. A library should return errors instead.

## Testing and Validation

- Add focused tests for success cases, boundary values, invalid arguments, truncation, overflow, and resource failures relevant to the change.
- Cover both internal parsing/processing steps and the public API that callers use.
- Keep tests deterministic and independent of external game data or machine-specific state unless the existing test setup explicitly provides those inputs.
- Run the narrowest relevant test and build first, then expand validation as required by the project.
- For code that reads untrusted data, consider compiler warnings and available address, undefined-behavior, and memory sanitizers where the project's toolchain supports them.
- Review the final diff for unchecked indexing, arithmetic overflow, lifetime errors, implicit conversions, and any path that can crash or conceal failure.
