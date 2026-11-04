# Packaging

Scripts that build Simburbia's client into the packages players download, one folder for each
platform, after CityLimits' `packaging/`. They write to `dist/release/` at the repository's root,
which git ignores, and put the packages together in `dist/work/`.

| Script | Builds | Runs on |
| --- | --- | --- |
| `linux/package.sh` | `simburbia-<version>-linux-x86_64.AppImage` and `.tar.gz` | Linux |
| `windows/package.sh` | `simburbia-<version>-windows-x64.zip`, the client in a folder | Windows, in Git Bash |
| `macos/package.sh` | `simburbia-<version>-macos-universal.zip`, holding `Simburbia.app` | macOS |

```sh
Simburbia/packaging/linux/package.sh
```

Swift builds for the machine it runs on, so each script runs on its own platform; unlike .NET,
it can't build the Windows or Mac client from Linux. Only the Linux script has been run so far:
the Windows and macOS ones wait until raylib-swift has been built on those systems.

## What they share

`env.sh` sets up every script. It builds the client in release, reads the version from the built
client (`simburbia --version`, the major.minor.patch GitVersion works out; see
[the client's page](../../docs/sb/client.md#versions)), and stages a folder with:

- the client;
- `Interface/`, `Lots/`, and `MockInstall/`, only the files git tracks, which the client finds
  beside itself (in `Contents/Resources` in the Mac app): the windows' UIScript documents, and the
  lots, so it opens the mock lot with no game installed;
- the readme and the licence (AGPL-3.0).

FreeSO's content folder isn't packaged: the client finds it through `FSO_CONTENT_DIR`, or in a
`Content` folder put beside it.

Each script then runs the staged client: its version, and a game hour of the mock lot with no
window and no install, which shows it found its files. Tools are downloaded only at pinned
versions, and a file whose SHA-256 isn't the published one is refused.

| Variable | Default | Meaning |
| --- | --- | --- |
| `SIMBURBIA_VERSION` | the client's own | The version the packages are named for |
| `DIST` | `dist/release` | Where the packages go |
| `WORK` | `dist/work` | Where they're put together, and the downloaded tools kept |

The icon, `simburbia.png`, is a placeholder.

## Linux

The client is built with the Swift runtime inside it (`--static-swift-stdlib`), so a player
needs only what every desktop Linux has: X11, libxml2, and the C and C++ libraries. Building
needs the X11 and GL headers raylib compiles against; on an atomic distribution they come from
Homebrew, through `CPATH` and `LIBRARY_PATH` (see the client's page).

The AppImage carries its own runtime, so it runs without FUSE. It's built with appimagetool 1.9.1
and the type 2 runtime from 2025-11-08, CityLimits' pins, downloaded on the first run. `AppRun`
starts the client from inside the image, and `simburbia.desktop` is its menu entry.

## Windows

Built on Windows with the Swift toolchain, with the Swift runtime inside the client, and zipped
with PowerShell. `simburbia.exe` has no icon yet: Swift has no step that embeds one. There's no
installer.

## macOS

`Simburbia.app` holds the client in `Contents/MacOS`, its lots and the mock install in
`Contents/Resources`, the icon made from `simburbia.png`, and `Info.plist`, from
`Info.plist.in`. It's one app for Apple silicon and Intel.

The app is signed ad hoc, not with a Developer ID, so Gatekeeper asks before a downloaded copy
first opens: Control-click the app and choose Open. Signing with a Developer ID and notarizing
need an Apple developer account.
