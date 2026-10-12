"""Prepare installed macOS PingFang SC faces for LOOPBACK preview only.

No dependency, download or font installation. Never commit/publish the generated
font files: they belong under ignored build/, not assets/ or release artifacts.
"""
import argparse
import json
import struct
from pathlib import Path


def checksum(data):
    data = bytes(data) + b'\0' * (-len(data) % 4)
    return sum(struct.unpack('>' + 'I' * (len(data) // 4), data)) & 0xffffffff


def extract(source, destination):
    data = source.read_bytes()
    u16 = lambda at: struct.unpack_from('>H', data, at)[0]
    u32 = lambda at: struct.unpack_from('>I', data, at)[0]
    if data[:4] != b'ttcf':
        raise ValueError('Expected a TTC font collection')
    destination.mkdir(parents=True, exist_ok=True)
    result = []
    for index in range(u32(8)):
        start = u32(12 + index * 4)
        tables = {}
        for j in range(u16(start + 4)):
            at = start + 12 + j * 16
            tag = data[at:at + 4]
            offset, length = u32(at + 8), u32(at + 12)
            tables[tag] = data[offset:offset + length]
        names = tables[b'name']
        count, storage = struct.unpack_from('>HH', names, 2)
        postscript = None
        for j in range(count):
            platform, _, _, name_id, length, offset = struct.unpack_from('>6H', names, 6 + j * 12)
            if name_id == 6 and platform in (0, 3):
                postscript = names[storage + offset:storage + offset + length].decode('utf-16-be')
        if postscript not in ('PingFangSC-Regular', 'PingFangSC-Medium', 'PingFangSC-Semibold'):
            continue
        # TTC table offsets are collection-relative. Rebuild a standalone sfnt
        # table directory; font outlines and names remain unchanged.
        tags = sorted(tables)
        count = len(tags)
        power = 2 ** (count.bit_length() - 1)
        output = bytearray(data[start:start + 4])
        output += struct.pack('>HHHH', count, power * 16, power.bit_length() - 1, count * 16 - power * 16)
        output += b'\0' * (16 * count)
        head_offset = None
        for j, tag in enumerate(tags):
            table = bytearray(tables[tag])
            if tag == b'head':
                table[8:12] = b'\0' * 4
                head_offset = len(output)
            record = tag + struct.pack('>III', checksum(table), len(output), len(table))
            output[12 + j * 16:28 + j * 16] = record
            output += table + b'\0' * (-len(table) % 4)
        if head_offset is None:
            raise ValueError('Missing head table')
        struct.pack_into('>I', output, head_offset + 8, (0xb1b0afba - checksum(output)) & 0xffffffff)
        assert checksum(output) == 0xb1b0afba
        target = destination / (postscript + '.otf')
        target.write_bytes(output)
        result.append({'file': target.name, 'weight': struct.unpack_from('>H', tables[b'OS/2'], 4)[0], 'bytes': len(output)})
    if len(result) != 3:
        raise ValueError(f'Expected 3 SC faces, got {len(result)}')
    print(json.dumps({'source': str(source), 'local_preview_only': True, 'faces': result}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    if not args.output.is_absolute() or 'build' not in args.output.parts:
        parser.error('Output must be an absolute path under ignored build/')
    source = args.source
    if source is None:
        source = next(Path('/System/Library/AssetsV2').rglob('PingFang.ttc'), None)
    if source is None:
        parser.error('No locally installed PingFang.ttc found; no fonts downloaded')
    extract(source, args.output)
