# Super Metroid ROM Builds with Nix

Reproducible [Nix](https://nixos.org/) builds for patching and assembling customized Super Metroid ROMs from a clean original base ROM.

This repository provides Nix derivations for:

1. **[Hyper Metroid SUPER](#hyper-metroid-super)** — The 10th-anniversary remaster of the acclaimed overhaul hack by RealRed.
2. **[Super Metroid Redux (Custom)](#super-metroid-redux--custom-build)** — A modernized vanilla experience assembled with Asar and custom QoL patches.

---

## Requirements

To build either ROM, you need:

* [Nix](https://nixos.org/)
* A clean, legally obtained copy of the original Super Metroid ROM (Japan/USA):
  * **Expected format:** `Super Metroid (Japan, USA) (En,Ja).sfc`
  * **Expected SHA-1 checksum:**
    ```text
    da957f0d63d14cb441d215462904c4fa8519c613
    ```

> [!IMPORTANT]
> **No original ROMs are included, downloaded, or distributed by this repository.** You must supply your own clean ROM.

---

## Hyper Metroid SUPER

[Hyper Metroid SUPER](https://metroidconstruction.com/hack.php?id=823) is a complete overhaul ROM hack of *Super Metroid* created by **RealRed**, released in April 2025 as the 10th-anniversary remaster of the original 2015 *Hyper Metroid*.

It features:
* A brand new, re-envisioned Zebes map with reworked room designs and cohesive flow.
* Rebalanced weapons, physics, and enemy encounters.
* High-velocity exploration and refined progression.
* Replaces the older Project Base engine dependencies with custom mechanics tailored specifically for the hack.

### Links & Credits
* **Hack Page:** [Hyper Metroid SUPER on Metroid Construction](https://metroidconstruction.com/hack.php?id=823)
* **Original Hack:** [Hyper Metroid (2015) on Romhacking.net](https://www.romhacking.net/hacks/2005/)
* **Community:** [Metroid Construction](https://metroidconstruction.com/)

### Building Hyper Metroid SUPER

The derivation [`hyper-metroid.nix`](./hyper-metroid.nix) automatically detects whether your base ROM is unheadered or headered, validates the checksum, and applies the corresponding IPS patch:
* [`Hyper_Metroid_Super_UH.ips`](./Hyper_Metroid_Super_UH.ips) for unheadered ROMs (3,145,728 bytes).
* [`Hyper_Metroid_Super_H.ips`](./Hyper_Metroid_Super_H.ips) for headered ROMs (3,146,240 bytes).

If your base ROM is named `SuperMetroid.sfc` in the project root:
```bash
nix-build hyper-metroid.nix
```

Or specify a custom path to your ROM:
```bash
nix-build hyper-metroid.nix --arg rom /path/to/SuperMetroid.sfc
```

The resulting 4.0 MB ROM will be available at:
```text
./result/Hyper-Metroid-Super.sfc
```

---

## Super Metroid Redux — Custom Build

A customized build of [Super Metroid Redux](https://github.com/ShadowOne333/Super-Metroid-Redux) (pinned commit `25df6d1865fbf54507e5432d464e8d1dc67001ab`) that assembles the ROM directly using the bundled Asar binary and Python:

* **Heavy Physics:** Stronger gravity and responsive underwater movement (improving areas like Maridia).
* **Save Stations Refill Everything:** Restores health and ammo checkpoints.
* **Red Gate Optional Patch:** Applied via Python post-assembly (`patches/optional/Red Gate.ips`).
* **Easier Wall Jump:** Custom ASM patch by Benox50 (`patches/custom/EasierWJ.asm`, [Resource 545](https://metroidconstruction.com/resource.php?id=545)) with a 5-frame input window.

### Building Redux

```bash
nix-build default.nix --arg rom ./SuperMetroid.sfc
```

The resulting ROM will be available at:
```text
./result/Super-Metroid-Redux-Custom.sfc
```

---

## Save Files & Emulators

Both patched ROMs use the standard Super Metroid SRAM save format (`.srm`).

* **Tested Emulators:** Compatible with modern SNES emulators such as RetroArch (Snes9x / Mesen-S / bsnes cores), Ares, and desktop Snes9x.
* **Save Names:** In RetroArch, ensure your `.srm` save file matches the ROM's filename:
  ```text
  Hyper-Metroid-Super.sfc
  Hyper-Metroid-Super.srm
  ```
* **Save States:** RetroArch save states (`.state`) are not compatible between different hacks or vanilla Super Metroid. Always rely on battery SRAM saves (`.srm`) when migrating.

---

## Why Nix?

Using Nix makes ROM hacking and patching:
* **Fully reproducible:** Upstream sources, patches, and build tools are explicitly tracked or pinned.
* **Zero toolchain dependencies:** No need to install Flips, Lunar IPS, or compilers manually; Nix provides Python and dependencies automatically in an isolated sandbox.
* **Clean & safe:** The original clean ROM remains pristine and untouched outside the Nix store.

---

## Legal & Disclaimer

* This repository does **not** contain, distribute, or pirate any copyrighted game ROMs.
* You must supply your own legally acquired copy of the original Super Metroid game.
* Upstream projects and patches belong to their respective creators:
  * **Hyper Metroid SUPER** by [RealRed](https://metroidconstruction.com/hack.php?id=823).
  * **Super Metroid Redux** by [ShadowOne333 and contributors](https://github.com/ShadowOne333/Super-Metroid-Redux).
  * **Easier Wall Jump** by [Benox50](https://metroidconstruction.com/resource.php?id=545).
