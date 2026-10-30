# Install notes

What the differences between the copies of *The Sims Online* mean for NewSO, and content on them
that relies on something unusual. [install-differences.md](install-differences.md) lists what
changed, file by file; `tsofiles-check` writes it, and writing it again would lose anything added
by hand, so notes go here instead. Like the rest of this folder, this page holds names, counts,
and object IDs, never the game's own data.

The copies are 1.1097.1.0 (`TSO_GAME_DIR`, after New & Improved, the closest to what FreeSO was
built against), the 2002 copy (1.145.1.0, `TSO_CLASSIC_DIR`), and the 2002 beta (1.3.2.121,
`TSO_BETA_DIR`).

## The skill objects' alpha

Measured 2026-10-29. Three objects' sprites store an alpha of 200 in every pixel that has one,
though the field holds 5 bits (0 to 31):

| File | Copies | Frames |
| --- | --- | ---: |
| `objspf7.far/skillcheater.spf` | all three | 60 |
| `objspf9.far/skillcontroller.spf` | 1.1097.1.0 | 12 |
| `objspf9.far/skilltrainer.spf` | 1.1097.1.0 | 12 |

FreeSO scales alpha by 8.2258… and casts it to a byte, which wraps: 200 becomes 109, about 43%
opaque. The skill objects were repurposed for TSO's online play, so how they looked is uncertain,
and FreeSO's result is the best evidence. NewSO wraps the same way. It briefly saturated at 255
instead (DIFF-27, withdrawn); the oracle review's 84 sprite disagreements on 1.1097.1.0 and 60 on
the older copies were these frames.

The sprites came before the objects. `skillcheater.spf` ships with the beta, but the objects
themselves (`skillcheater.iff`, `skillcontroller.iff`, and `skilltrainer.iff` in `objiff.far`),
the other two sprite files, and their semi-global (`globals/skillcontrollersemiglobal.iff`) are
only in 1.1097.1.0. TSO's patch notes don't name any of them, so which patch added them isn't
known.

## Hidden objects

Some objects aren't meant to be seen: their own code hides them through object data 34
(`Hidden`), which FreeSO's `VMEntity` turns into an invisible `WorldUI`. On the owner's house on
1.1097.1.0 (2026-10-29), the five portals (pedestrian, two NPC, two car) and the mailbox's Part B
hide themselves as the lot starts. `newso` leaves hidden objects out of what it draws and picks.
Whether the older copies' versions of these objects hide themselves the same way hasn't been
checked.
