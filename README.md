<p align="center">
    <picture>
      <img alt="SimsCraft" src="docs/assets/logo.svg" width="200">
    </picture>
  </a>
</p>

<h1 align="center">SimsCraft</h1>

<p align="center">
  <b>an open-source Swift reimplementation of The Sims based on Swift and Raylib.</b><br>
  Designed for LAN and small scale use<br>
  Support for Beta, Base Game, and New & Improved
</p>

## Getting Around

| Folder | Holds |
| --- | --- |
| [`NSOClient/`](./NSOClient/) | The Swift code: independent Swift packages for the file formats (TSOFiles), content (TSOContent), and the SimAntics VM (SimAntics), plus tools and SimsScript |
| [`TSOClient/`](./TSOClient/) | FreeSO's C# source at its beta/update-46 build (August 2017), the reference NSOClient is checked against. It's read, never changed |
| [`docs/`](./docs/README.md) | How FreeSO and NSOClient work, the plan, and the results, with a glossary of terms |

To build and test, you need Swift 6 (and the .NET 10 SDK to compare with FreeSO). You don't need
the game: tests run on [`NSOClient/MockInstall`](./NSOClient/MockInstall/README.md), a tiny made-up
install, and skip what needs the real one.

```sh
swift test --package-path NSOClient/SimAntics
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