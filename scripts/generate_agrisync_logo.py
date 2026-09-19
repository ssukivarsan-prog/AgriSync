import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
ASSETS_DIR = ROOT / "frontend" / "assets" / "images"
WEB_ICONS_DIR = ROOT / "frontend" / "web" / "icons"
WEB_DIR = ROOT / "frontend" / "web"

ASSETS_DIR.mkdir(parents=True, exist_ok=True)
WEB_ICONS_DIR.mkdir(parents=True, exist_ok=True)

def create_agrisync_logo(size=1024):
    """Draws a premium, modern agricultural AI logo emblem for AgriSync."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    margin = int(size * 0.04)
    r = int(size * 0.22)
    
    # 1. Gradient Background Squircle
    bg_top = (10, 34, 22, 255)       # Deep Emerald Obsidian (#0A2216)
    bg_bot = (27, 67, 50, 255)       # Rich Vibrant Forest (#1B4332)
    
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([margin, margin, size - margin, size - margin], radius=r, fill=255)
    
    gradient = Image.new("RGBA", (size, size))
    for y in range(size):
        interp = y / size
        r_c = int(bg_top[0] * (1 - interp) + bg_bot[0] * interp)
        g_c = int(bg_top[1] * (1 - interp) + bg_bot[1] * interp)
        b_c = int(bg_top[2] * (1 - interp) + bg_bot[2] * interp)
        for x in range(size):
            gradient.putpixel((x, y), (r_c, g_c, b_c, 255))
            
    img.paste(gradient, (0, 0), mask)
    draw = ImageDraw.Draw(img)
    
    # 2. Glowing Outer Border
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=r,
        outline=(82, 183, 136, 160),
        width=int(size * 0.014)
    )

    cx, cy = size // 2, int(size * 0.42)
    scale = size / 512.0

    # 3. Synchronized Sync Rings (AgriSync Sync Emblem)
    ring_r = int(140 * scale)
    draw.ellipse(
        [cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r],
        outline=(116, 198, 157, 100),
        width=int(5 * scale)
    )

    # Sync Nodes (Orbiting Nodes)
    angles = [0, 90, 180, 270]
    for a in angles:
        rad = math.radians(a)
        nx = cx + int(ring_r * math.cos(rad))
        ny = cy + int(ring_r * math.sin(rad))
        node_r = int(10 * scale)
        draw.ellipse([nx - node_r, ny - node_r, nx + node_r, ny + node_r], fill=(216, 243, 220, 255))
        draw.ellipse([nx - node_r*0.6, ny - node_r*0.6, nx + node_r*0.6, ny + node_r*0.6], fill=(45, 106, 79, 255))

    # 4. Central Twin Leaf Sprout (Vibrant Green & Lime)
    # Right Leaf
    right_leaf = [
        (cx, cy + int(50 * scale)),
        (cx + int(90 * scale), cy + int(10 * scale)),
        (cx + int(115 * scale), cy - int(65 * scale)),
        (cx + int(35 * scale), cy - int(85 * scale)),
        (cx, cy - int(45 * scale))
    ]
    draw.polygon(right_leaf, fill=(82, 183, 136, 255))

    # Left Leaf (Slightly larger, dark emerald contrast)
    left_leaf = [
        (cx, cy + int(50 * scale)),
        (cx - int(95 * scale), cy + int(15 * scale)),
        (cx - int(120 * scale), cy - int(70 * scale)),
        (cx - int(40 * scale), cy - int(95 * scale)),
        (cx, cy - int(45 * scale))
    ]
    draw.polygon(left_leaf, fill=(45, 106, 79, 255))

    # Center Leaf Stem / Vein Glow Line
    stem_pts = [
        (cx, cy + int(90 * scale)),
        (cx, cy - int(105 * scale))
    ]
    draw.line(stem_pts, fill=(216, 243, 220, 255), width=int(8 * scale))

    # AI Circuit / Node Connections on Leaf
    circuit_pts = [
        (cx, cy - int(20 * scale)), (cx + int(45 * scale), cy - int(45 * scale)),
        (cx, cy + int(10 * scale)), (cx - int(50 * scale), cy - int(15 * scale)),
    ]
    draw.line([circuit_pts[0], circuit_pts[1]], fill=(183, 228, 199, 230), width=int(4 * scale))
    draw.line([circuit_pts[2], circuit_pts[3]], fill=(183, 228, 199, 230), width=int(4 * scale))

    # 5. Crisp Text Branding: "AGRISYNC"
    text_y = int(size * 0.76)
    
    try:
        font_main = ImageFont.truetype("arialbd.ttf", int(86 * scale))
        font_sub = ImageFont.truetype("arial.ttf", int(32 * scale))
    except Exception:
        font_main = ImageFont.load_default()
        font_sub = ImageFont.load_default()

    # Draw Text "AGRISYNC"
    text_main = "AGRISYNC"
    bbox_m = draw.textbbox((0, 0), text_main, font=font_main)
    w_m = bbox_m[2] - bbox_m[0]
    draw.text(((size - w_m) // 2, text_y), text_main, fill=(255, 255, 255, 255), font=font_main)

    # Subtitle "SMART FARMING AI"
    text_sub = "SMART FARMING AI"
    bbox_s = draw.textbbox((0, 0), text_sub, font=font_sub)
    w_s = bbox_s[2] - bbox_s[0]
    draw.text(((size - w_s) // 2, text_y + int(96 * scale)), text_sub, fill=(183, 228, 199, 230), font=font_sub)

    return img

def main():
    print("Generating official AgriSync AI branding logo suite...")
    master = create_agrisync_logo(1024)
    
    # Save master logo
    master.save(ASSETS_DIR / "logo_1024.png")
    master.resize((512, 512), Image.Resampling.LANCZOS).save(ASSETS_DIR / "logo_512.png")
    master.resize((256, 256), Image.Resampling.LANCZOS).save(ASSETS_DIR / "logo_256.png")
    master.resize((128, 128), Image.Resampling.LANCZOS).save(ASSETS_DIR / "logo_128.png")
    master.resize((64, 64), Image.Resampling.LANCZOS).save(ASSETS_DIR / "logo_64.png")
    
    # Web icons
    master.resize((512, 512), Image.Resampling.LANCZOS).save(WEB_ICONS_DIR / "Icon-512.png")
    master.resize((192, 192), Image.Resampling.LANCZOS).save(WEB_ICONS_DIR / "Icon-192.png")
    master.resize((32, 32), Image.Resampling.LANCZOS).save(WEB_DIR / "favicon.png")
    
    print("AgriSync logo branding suite generated successfully!")

if __name__ == "__main__":
    main()
