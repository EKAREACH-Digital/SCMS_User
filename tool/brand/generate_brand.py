#!/usr/bin/env python3
"""Renders every Smart Canteen launcher-icon asset from one definition.

The mark is a covered serving dish with steam rising from it, set between an
upright fork and spoon — spoon rather than knife, which is how canteen food is
actually eaten here. It is drawn as geometry rather than scaled from a single
bitmap so that every density is crisp, down to the 20px iOS notification icon.

Drop a 1024px (or larger) square PNG at tool/brand/source.png to use that
artwork as the icon face instead of the drawn mark.

Run:  python3 tool/brand/generate_brand.py
Deps: pillow, numpy
"""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

APP = Path(__file__).resolve().parents[2]  # smart_canteen_user_frontend/
SOURCE = APP / "tool/brand/source.png"

# ── Brand ────────────────────────────────────────────────────────────────────
# Same stops as AppTheme.headerGradient, ordered light → dark so the tile reads
# as lit from the top-left.
GRADIENT = [
    (0.00, (0x4C, 0xAF, 0x50)),  # AppTheme.green
    (0.55, (0x2E, 0x7D, 0x32)),  # AppTheme.greenDark
    (1.00, (0x1B, 0x5E, 0x20)),
]
MARK_COLOR = (255, 255, 255)

RENDER = 2048  # everything is drawn here, then downsampled

# ── Mark geometry, in a 1024-unit design space ───────────────────────────────
# Cloche: dome + knob over a wide tray bar and a narrower foot.
DOME = (337, 495, 687, 785)  # bbox; chord 180°..360° = top half
KNOB = (512, 478, 30)  # cx, cy, r
TRAY = (288, 636, 736, 686)
TRAY_R = 25
FOOT = (332, 686, 692, 720)
FOOT_R = 17

# Fork: three tines over a neck, then a handle. Spoon: bowl plus handle.
FORK_TINES_Y = (372, 505)
FORK_TINE_X = (130, 178, 226)  # centres
FORK_TINE_W = 26
FORK_NECK = (117, 462, 239, 548)
FORK_NECK_R = 34
FORK_HANDLE = (156, 520, 200, 792)
FORK_HANDLE_R = 22

SPOON_BOWL = (784, 366, 908, 542)
SPOON_HANDLE = (824, 500, 868, 792)
SPOON_HANDLE_R = 22

# Steam: (centre x, top y, height, amplitude, waves), stroked with round caps.
STEAM = [
    (424, 318, 142, 19, 1.0),
    (512, 268, 176, 21, 1.0),
    (600, 318, 142, 19, 1.0),
]
STEAM_W = 24

MARK_BBOX = (117, 256, 908, 792)  # tight bounds of everything drawn above


# ── Drawing ──────────────────────────────────────────────────────────────────
def _mark_transform(box):
    """Maps design-space coords into `box`, preserving aspect and centring."""
    bx0, by0, bx1, by1 = box
    mx0, my0, mx1, my1 = MARK_BBOX
    scale = min((bx1 - bx0) / (mx1 - mx0), (by1 - by0) / (my1 - my0))
    ox = bx0 + ((bx1 - bx0) - (mx1 - mx0) * scale) / 2 - mx0 * scale
    oy = by0 + ((by1 - by0) - (my1 - my0) * scale) / 2 - my0 * scale
    return (lambda x, y: (ox + x * scale, oy + y * scale)), scale


def draw_mark(img: Image.Image, box, color) -> None:
    """Draws the mark to fill `box` (x0, y0, x1, y1) in the given colour."""
    d = ImageDraw.Draw(img)
    pt, s = _mark_transform(box)

    def rrect(rect, radius):
        x0, y0, x1, y1 = rect
        d.rounded_rectangle([pt(x0, y0), pt(x1, y1)], radius=radius * s,
                            fill=color)

    # ── Cloche ──
    d.chord([pt(DOME[0], DOME[1]), pt(DOME[2], DOME[3])], 180, 360, fill=color)
    kx, ky, kr = KNOB
    d.ellipse([pt(kx - kr, ky - kr), pt(kx + kr, ky + kr)], fill=color)
    rrect(TRAY, TRAY_R)
    rrect(FOOT, FOOT_R)

    # ── Fork ──
    ty0, ty1 = FORK_TINES_Y
    for tx in FORK_TINE_X:
        rrect((tx - FORK_TINE_W / 2, ty0, tx + FORK_TINE_W / 2, ty1),
              FORK_TINE_W / 2)
    rrect(FORK_NECK, FORK_NECK_R)
    rrect(FORK_HANDLE, FORK_HANDLE_R)

    # ── Spoon ──
    d.ellipse([pt(SPOON_BOWL[0], SPOON_BOWL[1]),
               pt(SPOON_BOWL[2], SPOON_BOWL[3])], fill=color)
    rrect(SPOON_HANDLE, SPOON_HANDLE_R)

    # ── Steam ──
    # Stamped rather than stroked with line(): PIL's polyline joints leave
    # visible nicks on the outside of a tight curve at this stroke width.
    cap = STEAM_W / 2 * s
    for cx, top, height, amp, waves in STEAM:
        for i in range(241):
            t = i / 240
            px, py = pt(cx + amp * math.sin(2 * math.pi * waves * t),
                        top + height * t)
            d.ellipse([px - cap, py - cap, px + cap, py + cap], fill=color)


def gradient_bg(size: int) -> Image.Image:
    """Diagonal brand gradient with a soft highlight in the upper left."""
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32)
    t = (xx + yy) / (2.0 * (size - 1))

    stops = np.array([p for p, _ in GRADIENT], dtype=np.float32)
    cols = np.array([c for _, c in GRADIENT], dtype=np.float32)
    rgb = np.stack([np.interp(t, stops, cols[:, i]) for i in range(3)], axis=-1)

    hx, hy = 0.30 * size, 0.18 * size
    dist = np.sqrt((xx - hx) ** 2 + (yy - hy) ** 2) / (0.95 * size)
    glow = np.clip(1.0 - dist, 0.0, 1.0) ** 2 * 0.13
    rgb = rgb + (255.0 - rgb) * glow[..., None]

    arr = np.dstack([rgb.astype(np.uint8),
                     np.full((size, size), 255, np.uint8)])
    return Image.fromarray(arr, "RGBA")


def squircle_mask(size: int, exponent: float = 4.6) -> Image.Image:
    """Superellipse mask — the modern rounded-square icon silhouette."""
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32)
    u = np.abs((xx - (size - 1) / 2) / ((size - 1) / 2))
    v = np.abs((yy - (size - 1) / 2) / ((size - 1) / 2))
    return Image.fromarray(
        (((u ** exponent + v ** exponent) <= 1.0) * 255).astype(np.uint8), "L")


def _source_face() -> Image.Image | None:
    """The supplied artwork, squared and resized to RENDER, if there is one."""
    if not SOURCE.exists():
        return None
    im = Image.open(SOURCE).convert("RGBA")
    side = min(im.size)
    left, top = (im.width - side) // 2, (im.height - side) // 2
    return im.crop((left, top, left + side, top + side)).resize(
        (RENDER, RENDER), Image.LANCZOS)


def render_icon(fill: float, rounded: bool) -> Image.Image:
    """Full icon tile: gradient, mark, optional squircle crop."""
    face = _source_face()
    if face is not None:
        img = face
    else:
        img = gradient_bg(RENDER)
        inset = (1.0 - fill) / 2 * RENDER
        draw_mark(img, (inset, inset, RENDER - inset, RENDER - inset),
                  MARK_COLOR + (255,))
    if rounded:
        img = img.copy()
        img.putalpha(squircle_mask(RENDER))
    return img


def render_mark_only(fill: float, color) -> Image.Image:
    """Mark on transparency — Android's foreground and monochrome layers."""
    img = Image.new("RGBA", (RENDER, RENDER), (0, 0, 0, 0))
    inset = (1.0 - fill) / 2 * RENDER
    draw_mark(img, (inset, inset, RENDER - inset, RENDER - inset), color)
    return img


def save(img: Image.Image, path: Path, size: int, flatten=None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS)
    if flatten is not None:
        bg = Image.new("RGBA", out.size, flatten)
        bg.alpha_composite(out)
        out = bg.convert("RGB")
    out.save(path)


# ── Outputs ──────────────────────────────────────────────────────────────────
IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20, "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60, "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58, "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40, "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120, "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180, "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152, "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

# density -> (legacy launcher px, adaptive layer px)
ANDROID_DENSITIES = {
    "mdpi": (48, 108), "hdpi": (72, 162), "xhdpi": (96, 216),
    "xxhdpi": (144, 324), "xxxhdpi": (192, 432),
}

ADAPTIVE_XML = (
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
    '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
    '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
    '</adaptive-icon>\n'
)


def main() -> None:
    print("source: " + ("tool/brand/source.png" if SOURCE.exists()
                        else "drawn geometry"))

    squircle = render_icon(fill=0.74, rounded=True)
    full_bleed = render_icon(fill=0.68, rounded=False)  # OS applies its own mask
    # 0.55, not more: this mark is ~1.5x wider than tall, so at anything larger
    # the fork and spoon fall outside the circle a round launcher mask cuts.
    adaptive_fg = render_mark_only(0.55, MARK_COLOR + (255,))
    monochrome = render_mark_only(0.55, MARK_COLOR + (255,))
    adaptive_bg = gradient_bg(RENDER)

    ios = APP / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for name, px in IOS_ICONS.items():
        # iOS icons must be opaque; the system rounds the corners itself.
        save(full_bleed, ios / name, px, flatten=(0x1B, 0x5E, 0x20, 255))
    print(f"iOS       {len(IOS_ICONS)} icons")

    res = APP / "android/app/src/main/res"
    circle = Image.new("L", (RENDER, RENDER), 0)
    ImageDraw.Draw(circle).ellipse([0, 0, RENDER - 1, RENDER - 1], fill=255)
    round_icon = squircle.copy()
    round_icon.putalpha(circle)

    for density, (legacy, layer) in ANDROID_DENSITIES.items():
        m = res / f"mipmap-{density}"
        save(squircle, m / "ic_launcher.png", legacy)
        save(round_icon, m / "ic_launcher_round.png", legacy)
        save(adaptive_fg, m / "ic_launcher_foreground.png", layer)
        save(adaptive_bg, m / "ic_launcher_background.png", layer)
        save(monochrome, m / "ic_launcher_monochrome.png", layer)

    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(parents=True, exist_ok=True)
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        (anydpi / name).write_text(ADAPTIVE_XML)
    print(f"Android   {len(ANDROID_DENSITIES)} densities + adaptive/monochrome")

    web = APP / "web"
    save(squircle, web / "favicon.png", 32)
    save(squircle, web / "icons/Icon-192.png", 192, flatten=(255, 255, 255, 255))
    save(squircle, web / "icons/Icon-512.png", 512, flatten=(255, 255, 255, 255))
    save(full_bleed, web / "icons/Icon-maskable-192.png", 192,
         flatten=(0x1B, 0x5E, 0x20, 255))
    save(full_bleed, web / "icons/Icon-maskable-512.png", 512,
         flatten=(0x1B, 0x5E, 0x20, 255))
    print("Web       favicon + 4 PWA icons")

    out = APP / "tool/brand/preview"
    save(squircle, out / "app_icon_1024.png", 1024)
    save(render_mark_only(0.92, (0x1B, 0x5E, 0x20, 255)),
         out / "mark_green_512.png", 512)
    print("Preview   tool/brand/preview/")


if __name__ == "__main__":
    main()
