{ pkgs ? import <nixpkgs> {}
, rom ? ./SuperMetroid.sfc
}:

pkgs.stdenv.mkDerivation {
  pname = "hyper-metroid-super";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [
    pkgs.python3
  ];

  # Do not copy entire working directory contents if not needed,
  # or only unpack the ips patches
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    python3 <<'PY'
import hashlib
import os
import sys

rom_input = "${rom}"
patch_uh = "${./Hyper_Metroid_Super_UH.ips}"
patch_h = "${./Hyper_Metroid_Super_H.ips}"
out_dir = "out"
os.makedirs(out_dir, exist_ok=True)
out_rom = os.path.join(out_dir, "Hyper-Metroid-Super.sfc")

with open(rom_input, "rb") as f:
    rom_data = f.read()

rom_size = len(rom_data)
sha1_hash = hashlib.sha1(rom_data).hexdigest()
print(f"Input ROM: {rom_input}")
print(f"ROM size: {rom_size} bytes")
print(f"ROM SHA-1: {sha1_hash}")

expected_unheadered_sha1 = "da957f0d63d14cb441d215462904c4fa8519c613"

# Check if headered or unheadered
if rom_size % 1024 == 512 or rom_size == 3146240:
    print("Detected headered Super Metroid ROM (512-byte SMC header).")
    # Verify unheadered payload if possible
    unheadered_payload = rom_data[512:]
    if hashlib.sha1(unheadered_payload).hexdigest() == expected_unheadered_sha1:
        print("Verified base ROM checksum (ignoring header).")
    patch_file = patch_h
elif rom_size == 3145728 or rom_size % 1024 == 0:
    print("Detected unheadered Super Metroid ROM.")
    if sha1_hash == expected_unheadered_sha1:
        print("Verified base ROM SHA-1 checksum successfully.")
    else:
        print(f"WARNING: Base ROM SHA-1 ({sha1_hash}) does not match standard Super Metroid (JU) ({expected_unheadered_sha1}).")
    patch_file = patch_uh
else:
    print(f"Unknown ROM size {rom_size}, attempting unheadered patch...")
    patch_file = patch_uh

print(f"Applying IPS patch: {patch_file}")

with open(patch_file, "rb") as f:
    ips = f.read()

if ips[:5] != b"PATCH":
    raise SystemExit("Invalid IPS patch file header (expected 'PATCH')")

rom = bytearray(rom_data)
pos = 5

while True:
    if pos + 3 > len(ips):
        raise SystemExit("Truncated IPS file before EOF")

    if ips[pos:pos + 3] == b"EOF":
        pos += 3
        # Optional IPS 3-byte truncation field
        if pos + 3 <= len(ips):
            final_size = int.from_bytes(ips[pos:pos + 3], "big")
            del rom[final_size:]
        break

    offset = int.from_bytes(ips[pos:pos + 3], "big")
    pos += 3

    if pos + 2 > len(ips):
        raise SystemExit("Truncated IPS record size")

    size = int.from_bytes(ips[pos:pos + 2], "big")
    pos += 2

    if size != 0:
        if pos + size > len(ips):
            raise SystemExit("Truncated IPS record data")
        chunk = ips[pos:pos + size]
        pos += size
        if offset + size > len(rom):
            rom.extend(b"\x00" * (offset + size - len(rom)))
        rom[offset:offset + size] = chunk
    else:
        if pos + 3 > len(ips):
            raise SystemExit("Truncated IPS RLE record")
        rle_size = int.from_bytes(ips[pos:pos + 2], "big")
        val = ips[pos + 2]
        pos += 3
        if offset + rle_size > len(rom):
            rom.extend(b"\x00" * (offset + rle_size - len(rom)))
        rom[offset:offset + rle_size] = bytes([val]) * rle_size

with open(out_rom, "wb") as f:
    f.write(rom)

print(f"Successfully generated: {out_rom} ({len(rom)} bytes)")
PY

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp out/Hyper-Metroid-Super.sfc "$out/Hyper-Metroid-Super.sfc"
    runHook postInstall
  '';

  dontStrip = true;
}
