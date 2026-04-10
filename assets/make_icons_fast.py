"""Generate Ranchly icons - faster version using smaller size."""
import struct, zlib, math

def write_png(filename, size, draw_fn):
    pixels = []
    for y in range(size):
        for x in range(size):
            pixels.append(draw_fn(x, y, size))

    raw = b''
    for y in range(size):
        raw += b'\x00'
        for x in range(size):
            r, g, b, a = pixels[y * size + x]
            raw += bytes([r, g, b, a])

    def chunk(tag, data):
        c = zlib.crc32(tag + data) & 0xffffffff
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', c)

    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0))
    idat = chunk(b'IDAT', zlib.compress(raw, 1))  # fast compression
    iend = chunk(b'IEND', b'')

    with open(filename, 'wb') as f:
        f.write(sig + ihdr + idat + iend)
    print(f"Written {filename}")

def sheep_pixel(x, y, size, green_bg=True):
    cx, cy = size / 2, size / 2
    r = size / 2
    dx, dy = x - cx, y - cy

    # Background
    if green_bg:
        dist = math.sqrt(dx * dx + dy * dy)
        bg = (58, 107, 53, 255) if dist <= r else (0, 0, 0, 0)
    else:
        bg = (0, 0, 0, 0)

    # Normalised -1..1
    nx = (x / size - 0.5) * 2
    ny = (y / size - 0.5) * 2

    # Body ellipse
    in_body = ((nx) / 0.50) ** 2 + ((ny + 0.05) / 0.38) ** 2 <= 1

    # Head circle (upper right)
    in_head = (nx - 0.28) ** 2 + (ny + 0.35) ** 2 <= 0.18 ** 2

    # 4 legs (thin rectangles)
    leg_tops = [(-0.30, 0.30), (-0.12, 0.32), (0.08, 0.32), (0.26, 0.30)]
    in_leg = any(abs(nx - lx) < 0.065 and 0 <= ny - lt < 0.38 for lx, lt in leg_tops)

    if in_body or in_head or in_leg:
        return (255, 255, 255, 255)
    return bg

size = 256  # flutter_launcher_icons will upscale
write_png('icon.png', size, lambda x, y, s: sheep_pixel(x, y, s, green_bg=True))
write_png('icon_fg.png', size, lambda x, y, s: sheep_pixel(x, y, s, green_bg=False))
write_png('splash.png', size, lambda x, y, s: sheep_pixel(x, y, s, green_bg=False))
print("Done!")
