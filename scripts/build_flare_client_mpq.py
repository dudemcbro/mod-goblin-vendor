#!/usr/bin/env python3
"""Patch client Spell.dbc for Goblin Salvage Flare Gun use text/cooldown and build patch-X.MPQ."""
import argparse
import struct
import subprocess
from pathlib import Path

TARGET_SPELL_ID = 31333
NEW_RECOVERY_MS = 300000
NEW_CATEGORY_RECOVERY_MS = 300000
NEW_DESC_ENUS = "Summons GySgt Geargrind for 5 min."
NEW_DESC_ENGB = "Summons GySgt Geargrind for 5 min."
NEW_AURA_ENUS = ""
NEW_AURA_ENGB = ""


def run_mysql_rows(cmd: str) -> list[list[str]]:
    out = subprocess.check_output(cmd, shell=True, text=True)
    rows = []
    for line in out.splitlines():
        if line.strip():
            rows.append(line.rstrip("\n").split("\t"))
    return rows


def resolve_indices(mysql_cmd: str) -> dict[str, int]:
    q = (
        "SELECT COLUMN_NAME "
        "FROM INFORMATION_SCHEMA.COLUMNS "
        "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_dbc' "
        "ORDER BY ORDINAL_POSITION"
    )
    rows = run_mysql_rows(f"{mysql_cmd} -e \"{q}\"")
    if not rows:
        raise SystemExit("Failed to read spell_dbc columns")
    cols = [r[0] for r in rows]
    required = [
        "ID",
        "RecoveryTime",
        "CategoryRecoveryTime",
        "Description_Lang_enUS",
        "Description_Lang_enGB",
        "AuraDescription_Lang_enUS",
        "AuraDescription_Lang_enGB",
    ]
    missing = [c for c in required if c not in cols]
    if missing:
        raise SystemExit(f"Missing columns in spell_dbc: {missing}")
    return {c: cols.index(c) for c in required}


def add_string(string_block: bytes, s: str) -> tuple[bytes, int]:
    if not s:
        return string_block, 0
    b = s.encode("utf-8") + b"\x00"
    pos = string_block.find(b)
    if pos != -1:
        return string_block, pos
    off = len(string_block)
    return string_block + b, off


def patch_spell_dbc(src: Path, dst: Path, idx: dict[str, int]) -> None:
    with src.open("rb") as f:
        if f.read(4) != b"WDBC":
            raise SystemExit(f"Not a DBC file: {src}")
        record_count, field_count, record_size, string_block_size = struct.unpack("<4I", f.read(16))
        data = bytearray(f.read(record_count * record_size))
        string_block = f.read(string_block_size)

    fields = record_size // 4
    for key, col in idx.items():
        if col >= fields:
            raise SystemExit(f"Column index out of range for DBC fields: {key}={col}, fields={fields}")

    patched = False
    for i in range(record_count):
        off = i * record_size
        spell_id = struct.unpack_from("<I", data, off + idx["ID"] * 4)[0]
        if spell_id != TARGET_SPELL_ID:
            continue

        struct.pack_into("<I", data, off + idx["RecoveryTime"] * 4, NEW_RECOVERY_MS)
        struct.pack_into("<I", data, off + idx["CategoryRecoveryTime"] * 4, NEW_CATEGORY_RECOVERY_MS)

        string_block, d_us = add_string(string_block, NEW_DESC_ENUS)
        string_block, d_gb = add_string(string_block, NEW_DESC_ENGB)
        string_block, a_us = add_string(string_block, NEW_AURA_ENUS)
        string_block, a_gb = add_string(string_block, NEW_AURA_ENGB)

        struct.pack_into("<I", data, off + idx["Description_Lang_enUS"] * 4, d_us)
        struct.pack_into("<I", data, off + idx["Description_Lang_enGB"] * 4, d_gb)
        struct.pack_into("<I", data, off + idx["AuraDescription_Lang_enUS"] * 4, a_us)
        struct.pack_into("<I", data, off + idx["AuraDescription_Lang_enGB"] * 4, a_gb)

        patched = True
        break

    if not patched:
        raise SystemExit(f"Spell ID {TARGET_SPELL_ID} not found in {src}")

    dst.parent.mkdir(parents=True, exist_ok=True)
    with dst.open("wb") as f:
        f.write(b"WDBC")
        f.write(struct.pack("<4I", record_count, field_count, record_size, len(string_block)))
        f.write(data)
        f.write(string_block)


def build_crypt_table() -> list[int]:
    crypt = [0] * 0x500
    seed = 0x00100001
    for i in range(0x100):
        for j in range(5):
            seed = (seed * 125 + 3) % 0x2AAAAB
            temp1 = (seed & 0xFFFF) << 16
            seed = (seed * 125 + 3) % 0x2AAAAB
            temp2 = (seed & 0xFFFF)
            crypt[i + j * 0x100] = (temp1 | temp2) & 0xFFFFFFFF
    return crypt


CRYPT_TABLE = build_crypt_table()


def hash_string(string: str, hash_type: int) -> int:
    seed1 = 0x7FED7FED
    seed2 = 0xEEEEEEEE
    for ch in string.upper().replace("/", "\\"):
        value = CRYPT_TABLE[(hash_type << 8) + ord(ch)]
        seed1 = (value ^ (seed1 + seed2)) & 0xFFFFFFFF
        seed2 = (ord(ch) + seed1 + seed2 + ((seed2 << 5) & 0xFFFFFFFF) + 3) & 0xFFFFFFFF
    return seed1 & 0xFFFFFFFF


def encrypt_table(data: bytes, key: int) -> bytes:
    if len(data) % 4 != 0:
        raise SystemExit("MPQ table length must be multiple of 4")
    seed1 = key & 0xFFFFFFFF
    seed2 = 0xEEEEEEEE
    out = bytearray()
    for i in range(0, len(data), 4):
        value = struct.unpack_from("<I", data, i)[0]
        seed2 = (seed2 + CRYPT_TABLE[0x400 + (seed1 & 0xFF)]) & 0xFFFFFFFF
        enc = (value ^ (seed1 + seed2)) & 0xFFFFFFFF
        out += struct.pack("<I", enc)
        seed1 = (((~seed1) << 21) + 0x11111111 | (seed1 >> 11)) & 0xFFFFFFFF
        seed2 = (value + seed2 + ((seed2 << 5) & 0xFFFFFFFF) + 3) & 0xFFFFFFFF
    return bytes(out)


def build_mpq(mpq_path: Path, dbc_path: Path) -> None:
    filename = "DBFilesClient\\Spell.dbc"
    file_bytes = dbc_path.read_bytes()

    header_size = 32
    hash_table_size = 1
    block_table_size = 1
    hash_table_offset = header_size
    block_table_offset = hash_table_offset + hash_table_size * 16
    file_offset = block_table_offset + block_table_size * 16
    archive_size = file_offset + len(file_bytes)

    hash_a = hash_string(filename, 1)
    hash_b = hash_string(filename, 2)
    hash_entry = struct.pack("<IIHHI", hash_a, hash_b, 0, 0, 0)
    hash_table = encrypt_table(hash_entry, hash_string("(hash table)", 3))

    flags = 0x80000000 | 0x01000000
    block_entry = struct.pack("<IIII", file_offset, len(file_bytes), len(file_bytes), flags)
    block_table = encrypt_table(block_entry, hash_string("(block table)", 3))

    header = struct.pack(
        "<4sI I H H I I I I",
        b"MPQ\x1A",
        header_size,
        archive_size,
        0,
        3,
        hash_table_offset,
        block_table_offset,
        hash_table_size,
        block_table_size,
    )

    mpq_path.parent.mkdir(parents=True, exist_ok=True)
    with mpq_path.open("wb") as f:
        f.write(header)
        f.write(hash_table)
        f.write(block_table)
        f.write(file_bytes)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--dbc-in", required=True, help="the server's Spell.dbc (<core>/env/dist/bin/dbc/Spell.dbc)")
    p.add_argument("--dbc-out", default="client/DBFilesClient/Spell.dbc")
    p.add_argument("--mpq-out", default="client/patch-X.MPQ")
    # Credentials come from ~/.my.cnf or MYSQL_PWD, never from this file.
    p.add_argument("--mysql", default="mysql -D acore_world -N -B",
                   help="mysql command for the world database (default: %(default)s)")
    args = p.parse_args()

    dbc_in = Path(args.dbc_in)
    dbc_out = Path(args.dbc_out)
    mpq_out = Path(args.mpq_out)

    if not dbc_in.exists():
        raise SystemExit(f"DBC not found: {dbc_in}")

    idx = resolve_indices(args.mysql)
    patch_spell_dbc(dbc_in, dbc_out, idx)
    build_mpq(mpq_out, dbc_out)
    print(f"Patched DBC: {dbc_out}")
    print(f"Wrote MPQ: {mpq_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
