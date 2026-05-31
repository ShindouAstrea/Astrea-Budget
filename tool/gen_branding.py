#!/usr/bin/env python3
"""Genera el branding de Astrea Budget (icono + splash) por código.

Arte 100% original (formas geométricas dibujadas con Pillow): sin dependencias
de imágenes con copyright. La paleta sale de lib/core/theme/app_colors.dart.

Concepto: una ESTRELLA FUGAZ con una AUREOLA / órbita de MONEDAS ($) a su
alrededor y una ESTELA que se DESVANECE (dinero + brillo + movimiento).
Para regenerar tras cambiar colores o diseño:  python3 tool/gen_branding.py

Salidas en assets/branding/:
  icon_foreground.png  -> capa frontal del adaptive icon de Android (transparente)
  icon_background.png  -> capa de fondo del adaptive icon (degradado)
  icon_full.png        -> icono compuesto (iOS / web / macOS / Windows)
  splash_logo_light.png-> logo para splash en tema claro
  splash_logo_dark.png -> logo para splash en tema oscuro
"""
import math
import os
from PIL import Image, ImageDraw, ImageFont, ImageChops

# --- Paleta (sincronizada con AppColors) ---
BRAND       = (0x25, 0x63, 0xEB)   # #2563EB azul confianza
BRAND_LIGHT = (0x3B, 0x82, 0xF6)   # #3B82F6
BRAND_DEEP  = (0x1D, 0x4E, 0xD8)   # #1D4ED8
ACCENT      = (0xF9, 0x73, 0x16)   # #F97316 naranja (estela)
ACCENT_HI   = (0xFB, 0xBF, 0x7A)   # naranja claro (brillo interior de la estela)
GOLD        = (0xFC, 0xD3, 0x4D)   # dorado de monedas/aureola sobre fondo azul/oscuro
AMBER       = (0xF5, 0x9E, 0x0B)   # ámbar de monedas/aureola sobre fondo claro
SOFT_BLUE   = (0x5E, 0x93, 0xF2)   # azul suave para la estrella en el splash claro
WHITE       = (0xFF, 0xFF, 0xFF)

SS = 4  # supersampling para antialiasing
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")
FONTS = ["/System/Library/Fonts/Supplemental/Arial Bold.ttf",
         "/System/Library/Fonts/HelveticaNeue.ttc"]


def font(size):
    for p in FONTS:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, max(1, int(size)))
            except Exception:
                continue
    return ImageFont.load_default()


def star_points(cx, cy, r_out, r_in, points=5, rot=-math.pi / 2):
    pts = []
    step = math.pi / points
    for i in range(points * 2):
        r = r_out if i % 2 == 0 else r_in
        a = rot + i * step
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def vgradient(size, top, bottom):
    """Degradado vertical barato (rampa 1px reescalada)."""
    ramp = Image.new("RGBA", (1, 256))
    p = ramp.load()
    for y in range(256):
        t = y / 255
        p[0, y] = (round(top[0] + (bottom[0] - top[0]) * t),
                   round(top[1] + (bottom[1] - top[1]) * t),
                   round(top[2] + (bottom[2] - top[2]) * t), 255)
    return ramp.resize(size, Image.BILINEAR)


def downscale(img, final):
    return img.resize((final, final), Image.LANCZOS)


def faded_tail(base, s, ux, uy, ox, oy, length, wb, color, power=1.4, steps=220):
    """Estela cónica que se desvanece a transparente (máscara por círculos)."""
    work = 1024
    sc = work / s
    mask = Image.new("L", (work, work), 0)
    for i in range(steps):
        t = i / (steps - 1)
        cx = (ox - ux * length * t) * sc
        cy = (oy - uy * length * t) * sc
        rad = wb * (1 - t) * sc
        if rad < 0.5:
            continue
        a = int(255 * (1 - t) ** power)
        circ = Image.new("L", (work, work), 0)
        ImageDraw.Draw(circ).ellipse([cx - rad, cy - rad, cx + rad, cy + rad], fill=a)
        mask = ImageChops.lighter(mask, circ)
    solid = Image.new("RGBA", (s, s), color + (255,))
    solid.putalpha(mask.resize((s, s), Image.BILINEAR))
    base.alpha_composite(solid)


def coin_dollar(d, cx, cy, r, fill, detail):
    """Moneda legible: disco + canto interno + signo $."""
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=fill)
    d.ellipse([cx - r * 0.82, cy - r * 0.82, cx + r * 0.82, cy + r * 0.82],
              outline=detail, width=max(2, int(r * 0.10)))
    d.text((cx, cy - r * 0.06), "$", font=font(r * 1.45), fill=detail, anchor="mm")


def draw_logo(base, s, *, star_fill, orbit, coin_fill, coin_detail, scale=1.0):
    """Estrella fugaz con aureola de monedas sobre `base` (RGBA)."""
    c = s / 2
    ang = math.radians(-45)
    ux, uy = math.cos(ang), math.sin(ang)
    Rs = s * 0.20 * scale
    Hx = c + ux * s * 0.10 * scale
    Hy = c + uy * s * 0.10 * scale
    L = s * 0.44 * scale

    # estela desvanecida (nace detrás de la estrella)
    ox, oy = Hx - ux * Rs * 0.55, Hy - uy * Rs * 0.55
    faded_tail(base, s, ux, uy, ox, oy, L, Rs * 0.48, ACCENT)
    faded_tail(base, s, ux, uy, ox, oy, L * 0.80, Rs * 0.21, ACCENT_HI)

    # aureola (capa propia, inclinada) detrás de la estrella
    pad = int(Rs * 5)
    layer = Image.new("RGBA", (pad, pad), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    cc = pad / 2
    rx, ry = Rs * 1.78, Rs * 0.84
    ld.ellipse([cc - rx, cc - ry, cc + rx, cc + ry], outline=orbit,
               width=max(3, int(Rs * 0.085)))
    for deg in (18, 142, 262):
        a = math.radians(deg)
        coin_dollar(ld, cc + rx * math.cos(a), cc + ry * math.sin(a),
                    Rs * 0.34, coin_fill, coin_detail)
    layer = layer.rotate(-18, resample=Image.BICUBIC, expand=False)
    base.alpha_composite(layer, (int(Hx - cc), int(Hy - cc)))

    # estrella de 5 puntas, al frente
    ImageDraw.Draw(base).polygon(
        star_points(Hx, Hy, Rs, Rs * 0.42, points=5), fill=star_fill)


def save(img, name):
    path = os.path.normpath(os.path.join(OUT, name))
    img.save(path)
    print("  ✓", os.path.relpath(path))


def main():
    os.makedirs(OUT, exist_ok=True)
    print("Generando branding de Astrea Budget…")
    K = 1024 * SS  # lienzo del icono
    J = 768 * SS   # lienzo del splash

    # 1. Fondo del adaptive icon (degradado a sangre completa).
    save(downscale(vgradient((K, K), BRAND_LIGHT, BRAND_DEEP), 1024),
         "icon_background.png")

    # 2. Capa frontal del adaptive icon: logo dentro de la zona segura.
    fg = Image.new("RGBA", (K, K), (0, 0, 0, 0))
    draw_logo(fg, K, star_fill=WHITE, orbit=GOLD, coin_fill=GOLD,
              coin_detail=BRAND_DEEP, scale=0.62)
    save(downscale(fg, 1024), "icon_foreground.png")

    # 3. Icono compuesto (iOS/web/macOS/Windows): degradado + logo.
    full = vgradient((K, K), BRAND_LIGHT, BRAND_DEEP)
    draw_logo(full, K, star_fill=WHITE, orbit=GOLD, coin_fill=GOLD,
              coin_detail=BRAND_DEEP, scale=0.80)
    save(downscale(full, 1024), "icon_full.png")

    # 4. Splash claro: estrella azul suave + aureola ámbar (sobre fondo claro).
    light = Image.new("RGBA", (J, J), (0, 0, 0, 0))
    draw_logo(light, J, star_fill=SOFT_BLUE, orbit=AMBER, coin_fill=AMBER,
              coin_detail=WHITE, scale=0.78)
    save(downscale(light, 768), "splash_logo_light.png")

    # 5. Splash oscuro: estrella blanca + aureola dorada (contrastan en oscuro).
    dark = Image.new("RGBA", (J, J), (0, 0, 0, 0))
    draw_logo(dark, J, star_fill=WHITE, orbit=GOLD, coin_fill=GOLD,
              coin_detail=BRAND_DEEP, scale=0.78)
    save(downscale(dark, 768), "splash_logo_dark.png")

    print("Listo.")


if __name__ == "__main__":
    main()
