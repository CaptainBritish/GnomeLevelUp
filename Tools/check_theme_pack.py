"""Check a Lua theme pack's declarations and local assets before testing in WoW.

Requires Python 3.10+ and lupa (python -m pip install lupa).
Run from a GLU source checkout: python Tools/check_theme_pack.py /path/to/ThemePack
"""
import argparse
from pathlib import Path
import struct
import sys


ROOT = Path(__file__).resolve().parents[1]
TEXTURE_PIECES = ("topLeft", "top", "topRight", "left", "right", "bottomLeft", "bottom", "bottomRight")
BUILTIN_FONTS = {"FRIZQT", "ARIALN", "MORPHEUS", "SKURRI"}


def resolve_asset(root, relative):
    """Check exact spelling even on Windows, where exists() ignores case."""
    relative = relative.replace("\\", "/")
    parts = relative.split("/")
    if not relative or any(part in ("", ".", "..") or ":" in part for part in parts):
        raise ValueError("expected a relative path inside the theme addon")
    current = root
    for part in parts:
        if not current.is_dir():
            raise ValueError(f"missing file: {relative}")
        entries = {entry.name: entry for entry in current.iterdir()}
        if part not in entries:
            match = next((name for name in entries if name.casefold() == part.casefold()), None)
            if match:
                raise ValueError(f"filename case mismatch: {part!r}; the file is named {match!r}")
            raise ValueError(f"missing file: {relative}")
        current = entries[part]
        if not current.resolve().is_relative_to(root):
            raise ValueError("path points outside the theme addon")
    if not current.is_file():
        raise ValueError(f"expected a file: {relative}")
    return current


def inspect_asset(path):
    """Return image dimensions and format warnings without decoding the artwork."""
    with path.open("rb") as stream:
        header = stream.read(20)
    size = path.stat().st_size
    suffix = path.suffix.lower()
    warnings = []
    if suffix == ".tga":
        if len(header) < 18 or header[1] != 0 or header[2] not in (2, 10):
            raise ValueError("expected an uncompressed or RLE true-colour TGA")
        width, height = struct.unpack_from("<HH", header, 12)
        depth = header[16]
        if depth not in (24, 32):
            raise ValueError("expected a 24-bit or 32-bit TGA")
        if size <= 18 + header[0]:
            raise ValueError("TGA has no image data")
        if header[2] == 2 and size < 18 + header[0] + width * height * (depth // 8):
            raise ValueError("TGA image data is truncated")
        if depth == 32 and header[17] & 15 == 0:
            warnings.append("32-bit TGA declares no alpha bits; check transparency in WoW")
    elif suffix == ".blp":
        if len(header) < 20 or header[:4] not in (b"BLP1", b"BLP2") or size <= 20:
            raise ValueError("invalid or truncated BLP header")
        width, height = struct.unpack_from("<II", header, 12)
    elif suffix == ".ogg":
        if header[:4] != b"OggS":
            raise ValueError("file is not an Ogg stream")
        return None, warnings
    elif suffix == ".mp3":
        if not (header[:3] == b"ID3" or len(header) >= 2 and header[0] == 255 and header[1] & 224 == 224):
            raise ValueError("file has no MP3 header")
        return None, warnings
    elif suffix in (".ttf", ".otf"):
        if header[:4] not in (b"\x00\x01\x00\x00", b"OTTO", b"true") or size <= 12:
            raise ValueError("invalid or truncated TrueType/OpenType font header")
        return None, warnings
    else:
        raise ValueError(f"unsupported asset extension: {suffix or '(none)'}")
    if not 1 <= width <= 8192 or not 1 <= height <= 8192:
        raise ValueError("image dimensions must be from 1 to 8192 pixels")
    return (width, height), warnings


def load_pack(pack, toc_name=None):
    try:
        from lupa.lua54 import LuaRuntime
    except ImportError as error:
        raise ValueError("install the Lua reader first: python -m pip install lupa") from error
    toc = resolve_asset(pack, toc_name or f"{pack.name}.toc")
    lua = LuaRuntime(register_eval=False, register_builtins=False, max_memory=32 * 1024 * 1024)
    lua.execute("""
        audit = { themes = {}, media = {}, errors = {} }
        local media = {}
        function media:Register(kind, name, path)
            audit.media[kind .. ':' .. name] = path
            return true
        end
        LibStub = function(name) if name == 'LibSharedMedia-3.0' then return media end end
        print = function() end
        debug.sethook(function() error('theme script exceeded the instruction limit') end, '', 1000000)
        os, io, package, require, dofile, loadfile, python, debug = nil, nil, nil, nil, nil, nil, nil, nil
    """)
    loader = lua.eval("""function(source, filename, addonName, namespace)
        local callback, reason = load(source, '@' .. filename)
        if not callback then error(reason) end
        return callback(addonName, namespace)
    end""")
    loader((ROOT / "ThemeList.lua").read_text(encoding="utf-8-sig"), "ThemeList.lua", "GnomeLevelUp", lua.table())
    lua.execute("""
        local register = GnomeLevelUpThemeAPI.RegisterTheme
        GnomeLevelUpThemeAPI.RegisterTheme = function(addonName, id, definition)
            local key, reason = register(addonName, id, definition)
            if key then
                audit.themes[#audit.themes + 1] = { id = id, definition = definition }
            else
                audit.errors[#audit.errors + 1] = reason
            end
            return key, reason
        end
    """)
    namespace = lua.table()
    for line in toc.read_text(encoding="utf-8-sig").splitlines():
        entry = line.strip()
        if not entry or entry.startswith("#"):
            continue
        if not entry.lower().endswith(".lua"):
            raise ValueError(f"{toc.name}: cannot audit non-Lua entry {entry!r}; use the Lua starter-pack structure")
        script = resolve_asset(pack, entry)
        loader(script.read_text(encoding="utf-8-sig"), entry, pack.name, namespace)
    # Retain the runtime alongside its tables for the duration of the audit.
    return lua, lua.globals().audit


def check_pack(pack, toc_name=None):
    pack = Path(pack).resolve()
    errors, warnings, checked = [], [], set()
    try:
        runtime, audit = load_pack(pack, toc_name)
    except Exception as error:
        return [f"pack: {error}"], warnings, 0
    errors.extend(str(reason) for _, reason in audit.errors.items())
    if not len(audit.themes):
        errors.append("pack: no themes registered successfully")

    def check_file(relative, field, dimensions=None, suffixes=None):
        try:
            asset = resolve_asset(pack, relative)
            if suffixes and asset.suffix.lower() not in suffixes:
                raise ValueError("expected " + " or ".join(sorted(suffixes)))
            actual, notes = inspect_asset(asset)
            checked.add(asset)
            warnings.extend(f"{field}: {note}" for note in notes)
            if dimensions and actual != dimensions:
                raise ValueError(f"declared dimensions {dimensions[0]}x{dimensions[1]} do not match file dimensions {actual[0]}x{actual[1]}")
        except (ValueError, OSError) as error:
            errors.append(f"{field}: {error}")

    for _, theme in audit.themes.items():
        definition = theme.definition
        prefix = str(theme.id)
        frame = definition["frame"]
        if not isinstance(frame, str):
            for piece in TEXTURE_PIECES:
                if frame[piece] is not None:
                    check_file(frame[piece], f"{prefix}.frame.{piece}", suffixes={".tga", ".blp"})
        background = definition["background"]
        if not isinstance(background, str):
            dimensions = None
            if background["width"] is not None and background["height"] is not None:
                dimensions = (background["width"], background["height"])
            check_file(background["texture"], f"{prefix}.background.texture", dimensions, {".tga", ".blp"})
        ring = definition["portraitRing"]
        divider = definition["divider"]
        if divider:
            check_file(divider["texture"], f"{prefix}.divider.texture", suffixes={".tga", ".blp"})
        if ring is not None and not isinstance(ring, str):
            check_file(ring["texture"], f"{prefix}.portraitRing.texture", suffixes={".tga", ".blp"})
        font = definition["font"]
        if font is not None and font not in BUILTIN_FONTS:
            check_file(font, f"{prefix}.font", suffixes={".ttf", ".otf"})
        sounds = definition["sounds"]
        if definition["soundsEnabled"] is False:
            if sounds is not None and len(sounds):
                warnings.append(f"{prefix}.sounds: ignored because soundsEnabled is false")
            continue
        for cue, sound in sounds.items() if sounds is not None else ():
            name = sound["media"]
            if name is None:
                continue  # Sound-kit IDs belong to the client, not this addon.
            path = audit.media["sound:" + name]
            if path is None:
                warnings.append(f"{prefix}.sounds.{cue}.media: external media {name!r} needs an in-game check")
                continue
            expected = "Interface\\AddOns\\" + pack.name + "\\"
            normalized = path.replace("/", "\\")
            if not normalized.startswith(expected):
                errors.append(f"{prefix}.sounds.{cue}: expected a sound file inside {pack.name}")
                continue
            check_file(normalized[len(expected):], f"{prefix}.sounds.{cue}", suffixes={".ogg", ".mp3"})
    return errors, warnings, len(checked)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", type=Path, help="Theme addon folder")
    parser.add_argument("--toc", help="Manifest filename if it differs from the folder name")
    args = parser.parse_args()
    errors, warnings, count = check_pack(args.pack, args.toc)
    for message in warnings:
        print("WARNING:", message)
    for message in errors:
        print("ERROR:", message)
    print(f"Checked {count} unique assets: {len(errors)} errors, {len(warnings)} warnings.")
    print("Still test rendering, font glyphs and audio in WoW.")
    return int(bool(errors))


if __name__ == "__main__":
    sys.exit(main())
