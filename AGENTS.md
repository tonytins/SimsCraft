# AGENTS.md

Notes for coding agents working in SimsCraft. Read [CLAUDE.md](CLAUDE.md) first: it holds the
shared guidance, such as the project's goals, its layout, the commands, the rules for Simburbia's
libraries, and what to check before finishing. Keep this file to what's specific to agents.
For reviews, follow [REVIEW.md](REVIEW.md).

## Working with the owner

- One person maintains SimsCraft, alone. Make review easy: say what you did, what you skipped,
  and every claim you couldn't verify.
- A request that starts a discussion ("I was thinking", "discuss", a question) gets an answer,
  not code. Open design choices go to the owner rather than being decided quietly.
- Commit locally when a piece of work is ready, one commit per piece rather than per step, and
  wait for review. Never push, amend, or rewrite history unless asked.
- The working tree often holds the owner's own unfinished edits. Leave files you didn't change
  alone, and stage only your own work.

## Keeping the machine usable

- Build and test only the packages you changed and those that depend on them, one package at a
  time (`swift build -j 2`). Building everything at once has run the owner's machine out of
  memory. Don't clear `.build` folders without need.
- Don't run the full oracle review (`oracle-review.sh` on a real install) unless asked: it takes
  a long time. The mock review and a short `sb-oracle study` are fine for checking a change.
- Check visual changes off the owner's desktop: `simburbia --screenshot` on a private display,
  never driving their real one.

## Lines not to cross

- Never edit FreeSO's snapshot: `TSOClient/`, `Charvatia/`, `FSOInstaller/`, and `Other/`.
- Never commit the game's data. Tests use made-up files or `Simburbia/MockInstall`, and results
  hold names, sizes, chunk IDs, and GUIDs only.
- Run `dotnet` only for `Simburbia/FSO.Oracle`.
- Keep private notes and anything in `*.local` out of tracked files, and don't mention them there.

## Personal Configuration

Keep personal preferences and machine-specific guidance in git-ignored
`*.local` (such as ``AGENTS.local.md``) files or directories, rather than in shared project instructions.
Check for relevant local guidance before environment-specific work. You can
create or update these files for details such as:

- Coding preferences
- Local build and development environment
- Personal shortcuts or workflows
