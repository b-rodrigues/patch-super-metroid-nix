# Super Metroid Redux — Nix Build

A reproducible [Nix](https://nixos.org/) build for creating a customized **Super Metroid Redux** ROM.

This build starts from a legally obtained, clean Super Metroid ROM and applies:

* [Super Metroid Redux](https://github.com/ShadowOne333/Super-Metroid-Redux)
* **Heavy Physics**
* **Save Stations Refill Everything**
* **Red Gate** optional patch

The upstream `make.sh` script is intentionally **not used**. The ROM is assembled directly with the Asar binary included in the Redux repository, and the Red Gate IPS patch is applied using Python.

## Features

### Super Metroid Redux

The base patch is taken from the pinned upstream commit:

```text
25df6d1865fbf54507e5432d464e8d1dc67001ab
```

Pinning the commit makes the build reproducible rather than depending on whatever happens to be in the upstream repository at build time.

### Heavy Physics

Heavy Physics is enabled by default.

This gives Samus a more responsive movement model with stronger gravity and altered underwater movement. In particular, areas such as Maridia feel substantially less sluggish compared with vanilla Super Metroid.

### Save Stations Refill Everything

Save stations restore additional resources when saving, making them more useful as checkpoints during a playthrough.

### Red Gate

The optional:

```text
patches/optional/Red Gate.ips
```

patch is applied after the main Redux assembly.

## Requirements

You need:

* Nix
* A clean, legally obtained copy of the original Super Metroid ROM
* The ROM must have the expected SHA-1 checksum:

```text
da957f0d63d14cb441d215462904c4fa8519c613
```

The expected ROM is the standard:

```text
Super Metroid (Japan, USA) (En,Ja).sfc
```

**The ROM itself is not included in this repository.**

## Building

Place your clean ROM somewhere accessible to Nix and run:

```bash
nix-build default.nix --arg rom ./SuperMetroid.sfc
```

For example, if the ROM is named:

```text
SuperMetroid.sfc
```

in the current directory, the command above will build the customized ROM.

The resulting ROM will be available through the Nix build result:

```text
./result/Super-Metroid-Redux-Custom.sfc
```

## What the build does

The Nix derivation:

1. Fetches the pinned Super Metroid Redux source.
2. Verifies the supplied base ROM's SHA-1 checksum.
3. Enables Redux's optional patch system.
4. Enables Heavy Physics.
5. Enables Save Stations Refill Everything.
6. Copies the clean ROM to the build directory.
7. Runs the bundled Asar assembler directly.
8. Applies `Red Gate.ips`.
9. Installs the resulting ROM as:

```text
Super-Metroid-Redux-Custom.sfc
```

No ROM is downloaded, embedded, or distributed by this repository.

## Save Files

The resulting ROM is intended to use the normal Super Metroid SRAM save format.

If you already have a vanilla Super Metroid save file, it may be possible to continue your existing game with the Redux ROM.

On RetroArch, make sure the save file is associated with the Redux ROM's filename. For example:

```text
Super-Metroid-Redux-Custom.sfc
Super-Metroid-Redux-Custom.srm
```

**Back up your original save file before attempting this.**

RetroArch save states are different from normal SRAM saves and should not be treated as interchangeable between vanilla Super Metroid and Redux.

## Emulator

The resulting ROM should work with compatible SNES emulators.

The build has been tested with **RetroArch on Android**.

A normal `.srm` save file can be transferred successfully from vanilla Super Metroid to the Redux build.

## Why Nix?

The goal of this repository is to make the customized ROM build:

* reproducible
* declarative
* independent of the upstream `make.sh`
* easy to rebuild
* explicit about the exact Redux revision being used

The original ROM remains outside the repository and is supplied by the user at build time.

## Legal

This repository does **not** contain or distribute the Super Metroid ROM.

You must provide your own legally obtained copy of the original game.

The Super Metroid Redux source is maintained by its respective authors:

https://github.com/ShadowOne333/Super-Metroid-Redux

Please respect the licenses and distribution terms of all software and patches used by this project.
 
