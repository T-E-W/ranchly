"""Generate Ranchly app icons using only stdlib (no Pillow needed)."""
import struct, zlib, math

def png(w, h, pixels):
    """pixels: list of (r,g,b,a) tuples, row-major."""
    def chunk(tag, data):
        c = zlib.crc32(tag + data) & 0xffffffff
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', c)

    raw = b''
    for y in range(h):
        raw += b'\x00'
        for x in range(w):
            r,g,b,a = pixels[y*w+x]
            raw += bytes([r,g,b,a])

    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))  # RGBA
    idat = chunk(b'IDAT', zlib.compress(raw))
    iend = chunk(b'IEND', b'')
    return sig + ihdr + idat + iend

def make_icon(size, filename, fg_only=False):
    cx, cy = size / 2, size / 2
    r = size / 2
    pixels = []
    for y in range(size):
        for x in range(size):
            dx, dy = x - cx, y - cy
            dist = math.sqrt(dx*dx + dy*dy)

            if fg_only:
                # Transparent background, white sheep
                bg = (0, 0, 0, 0)
            else:
                # Green circle background
                if dist <= r:
                    bg = (58, 107, 53, 255)  # #3a6b35
                else:
                    bg = (0, 0, 0, 0)

            # Normalised coordinates for sheep drawing
            nx = (x / size - 0.5) * 2   # -1 to 1
            ny = (y / size - 0.5) * 2

            # Sheep body: rounded blob
            body_x, body_y = 0.0, 0.1
            body_rx, body_ry = 0.45, 0.35
            in_body = ((nx - body_x)/body_rx)**2 + ((ny - body_y)/body_ry)**2 <= 1

            # Head: smaller circle upper-right
            head_cx, head_cy = 0.32, -0.28
            head_r = 0.2
            in_head = (nx - head_cx)**2 + (ny - head_cy)**2 <= head_r**2

            # Legs: 4 rectangles
            leg_w = 0.07
            leg_h = 0.3
            legs = [
                (-0.28, 0.38), (-0.1, 0.4), (0.1, 0.4), (0.25, 0.38)
            ]
            in_leg = any(abs(nx - lx) < leg_w and (ny - ly) >= 0 and (ny - ly) < leg_h
                        for lx, ly in legs)

            # Ear
            ear_cx, ear_cy = 0.45, -0.38
            in_ear = (nx - ear_cx)**2 + (ny - ear_cy)**2 <= 0.07**2

            in_sheep = in_body or in_head or in_leg or in_ear

            if in_sheep:
                pixel = (255, 255, 255, 255)  # white sheep
            else:
                pixel = bg

            pixels.append(pixel)

    data = png(size, size, pixels)
    with open(filename, 'wb') as f:
        f.write(data)
    print(f"Written {filename} ({size}x{size})")

# Main icon (1024x1024 with green bg)
make_icon(1024, 'icon.png')
# Foreground only for adaptive icon
make_icon(1024, 'icon_fg.png', fg_only=True)
# Splash (512x512 just white sheep on transparent)
make_icon(512, 'splash.png', fg_only=True)

print("Done!")
