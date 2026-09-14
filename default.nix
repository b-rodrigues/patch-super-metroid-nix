{ pkgs ? import <nixpkgs> {}
, rom
}:

let
  src = pkgs.fetchFromGitHub {
    owner = "ShadowOne333";
    repo = "Super-Metroid-Redux";
    rev = "25df6d1865fbf54507e5432d464e8d1dc67001ab";
    hash = "sha256-D43tv68MONpumx6ynskdLiKCuMovDOsIZx9zmiFVAic=";
  };
in

pkgs.stdenv.mkDerivation {
  pname = "super-metroid-redux-custom";
  version = "1.0";

  inherit src;

  nativeBuildInputs = [
    pkgs.coreutils
    pkgs.patchelf
    pkgs.python3
  ];

  unpackPhase = ''
    cp -r "$src" source
    chmod -R u+w source
    cd source
  '';

  patchPhase = ''
    mkdir -p rom out

    cp ${rom} "rom/Super Metroid (Japan, USA) (En,Ja).sfc"
    cp ${rom} rom/SuperMetroid.sfc

    actual_sha1="$(sha1sum rom/SuperMetroid.sfc | cut -d' ' -f1)"
    expected_sha1="da957f0d63d14cb441d215462904c4fa8519c613"

    if [ "$actual_sha1" != "$expected_sha1" ]; then
      echo "ERROR: Base ROM SHA-1 mismatch."
      echo "Expected: $expected_sha1"
      echo "Actual:   $actual_sha1"
      exit 1
    fi

    echo "Base ROM SHA-1 checksum verified."

    patchelf \
      --set-interpreter "${pkgs.glibc}/lib/ld-linux-x86-64.so.2" \
      --set-rpath "${pkgs.glibc}/lib:${pkgs.stdenv.cc.cc.lib}/lib:$(pwd)/bin/asar-linux" \
      bin/asar-linux/asar-standalone

    echo "Checking Asar..."
    bin/asar-linux/asar-standalone --version

    # Enable optional.asm from main.asm.
    sed -i 's/^;incsrc "optional.asm"/incsrc "optional.asm"/' \
      code/main.asm

    # Enable Save Refills Everything.
    sed -i 's/^;incsrc "Optional\/SaveRefillsEverything.asm"/incsrc "Optional\/SaveRefillsEverything.asm"/' \
      code/optional.asm

    # Heavy Physics is enabled by !heavy = 0.
    grep -q '^!heavy = 0' code/main.asm
  '';

  buildPhase = ''
    mkdir -p out

    cp rom/SuperMetroid.sfc out/Super-Metroid-Redux.sfc
    chmod u+w out/Super-Metroid-Redux.sfc

    echo "ROM before Asar:"
    pwd
    ls -l out/Super-Metroid-Redux.sfc
    stat out/Super-Metroid-Redux.sfc
    file out/Super-Metroid-Redux.sfc
    sha1sum out/Super-Metroid-Redux.sfc

    echo "Asar binary:"
    file bin/asar-linux/asar-standalone
    ldd bin/asar-linux/asar-standalone || true

    echo "Building Super Metroid Redux..."

    bin/asar-linux/asar-standalone \
      "code/main.asm" \
      "out/Super-Metroid-Redux.sfc"

    echo "Redux assembly completed."

    python3 <<'PY'
import struct

path = "patches/optional/Red Gate.ips"
rom_path = "out/Super-Metroid-Redux.sfc"

with open(path, "rb") as f:
    data = f.read()

if data[:5] != b"PATCH":
    raise SystemExit("Invalid IPS file")

pos = 5

with open(rom_path, "r+b") as rom:
    while True:
        if pos + 3 > len(data):
            raise SystemExit("Truncated IPS record")

        if data[pos:pos + 3] == b"EOF":
            pos += 3

            # Optional IPS final-size field.
            if pos + 3 <= len(data):
                final_size = int.from_bytes(data[pos:pos + 3], "big")
                rom.truncate(final_size)

            break

        offset = int.from_bytes(data[pos:pos + 3], "big")
        pos += 3

        if pos + 2 > len(data):
            raise SystemExit("Truncated IPS record length")

        size = int.from_bytes(data[pos:pos + 2], "big")
        pos += 2

        rom.seek(offset)

        if size != 0:
            if pos + size > len(data):
                raise SystemExit("Truncated IPS data")

            rom.write(data[pos:pos + size])
            pos += size
        else:
            if pos + 3 > len(data):
                raise SystemExit("Truncated IPS RLE record")

            rle_size = int.from_bytes(data[pos:pos + 2], "big")
            value = data[pos + 2]
            pos += 3

            rom.write(bytes([value]) * rle_size)

print("Red Gate IPS patch applied.")
PY

    cp out/Super-Metroid-Redux.sfc \
       out/Super-Metroid-Redux-Final.sfc
  '';

  installPhase = ''
    mkdir -p "$out"

    cp out/Super-Metroid-Redux-Final.sfc \
       "$out/Super-Metroid-Redux-Custom.sfc"
  '';

  dontStrip = true;
}
