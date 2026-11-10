<p align="center">
    <picture>
      <img alt="SimsCraft" src="docs/assets/logo.svg" width="200">
    </picture>
  </a>
</p>

<h1 align="center">SimsCraft</h1>

<p align="center">
  <b>an open-source Swift reimplementation of The Sims Online based on Swift and Raylib.</b><br>
  Designed for LAN and small scale use<br>
  Support for Beta, Base Game, and New & Improved
</p>

## Getting Around

| Folder | Holds |
| --- | --- |
| `TSOFiles/`, `TSOContent/`, `SimAntics/`, `SBClient/` | The Swift code: independent Swift packages at the repository root for the file formats, content, and the SimAntics VM, plus the client, tools, and SimsScript |
| [`FreeSO/TSOClient/`](./FreeSO/TSOClient/) | FreeSO's C# source at its beta/update-46 build (August 2017), the reference Simburbia is checked against. It's read, never changed |
| [`docs/`](./docs/README.md) | How FreeSO and Simburbia work, the plan, and the results, with a glossary of terms |

To build and test, you need Swift 6 (and the .NET 10 SDK to compare with FreeSO). You don't need
the game: tests run on [`MockInstall`](./MockInstall/README.md), a tiny made-up
install, and skip what needs the real one.

```sh
swift test --package-path SimAntics
```

Start with [docs/README.md](./docs/README.md). The rules for changing the code, for people and AI
assistants alike, are in [AGENTS.md](./AGENTS.md). The game's files are EA's and never go in the
repository.

## Licensing

SimsCraft, like its parent project FreeSO, is licensed under the MPL-2.0 (Mozilla Public License 2.0). This open-source license allows for free use, modification, and distribution of the codebase.

---

<p align="center">
  <i>It's all coming back to you! 🪃</i>
</p>