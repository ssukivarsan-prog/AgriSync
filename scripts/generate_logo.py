import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
ASSETS_DIR = ROOT / "frontend" / "assets" / "images"
WEB_ICONS_DIR = ROOT / "frontend" / "web" / "icons"
WEB_DIR = ROOT / "frontend" / "web"

ASSETS_DIR.mkdir(parents=True, exist_ok=True)
WEB_ICONS_DIR.mkdir(parents=True, exist_ok=True)

def create_agrivyn_logo(size=1024):
    """Draws an ultra-crisp, modern agricultural AI logo emblem for AgriVyn."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Base Container: Smooth Rounded Shield / Squircle
    margin = int(size * 0.04)
    r = int(size * 0.22)
    
    # Draw radial/gradient styled background squircle
    bg_color_top = (15, 40, 24, 255)     # #0F2818 Deep forest obsidian
    bg_color_bot = (30, 81, 40, 255)     # #1E5128 Rich natural green
    
    # Render smooth vertical gradient in squircle mask
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=r,
        fill=255
    )
    
    gradient = Image.new("RGBA", (size, size))
    for y in range(size):
        interp = y / size
        r_c = int(bg_color_top[0] * (1 - interp) + bg_color_bot[0] * interp)
        g_c = int(bg_color_top[1] * (1 - interp) + bg_color_bot[1] * interp)
        b_c = int(bg_color_top[2] * (1 - interp) + bg_color_bot[2] * interp)
        for x in range(size):
            gradient.putpixel((x, y), (r_c, g_c, b_c, 255))
            
    img.paste(gradient, (0, 0), mask)
    
    # Re-obtain draw handle on composite
    draw = ImageDraw.Draw(img)
    
    # 2. Subtle Outer Glowing Border
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=r,
        outline=(82, 183, 136, 120),  # #52B788 soft sage glow
        width=int(size * 0.012)
    )

    # 3. Geometric AI Sprout & Leaf Anatomy (Centered)
    cx, cy = size // 2, int(size * 0.44)
    scale = size / 512.0

    # Draw Circuit Connection Tracks behind leaves
    circuit_color = (116, 198, 157, 180) # #74C69D
    node_points = [
        (cx - int(120 * scale), cy - int(90 * scale)),
        (cx - int(70 * scale), cy - int(140 * scale)),
        (cx + int(70 * scale), cy - int(140 * scale)),
        (cx + int(120 * scale), cy - int(90 * scale)),
        (cx - int(140 * scale), cy + int(10 * scale)),
        (cx + int(140 * scale), cy + int(10 * scale)),
    ]

    # Circuit lines
    circuit_lines = [
        ((cx, cy + int(60 * scale)), (cx - int(120 * scale), cy - int(90 * scale))),
        ((cx, cy + int(60 * scale)), (cx + int(120 * scale), cy - int(90 * scale))),
        ((cx - int(120 * scale), cy - int(90 * scale)), (cx - int(70 * scale), cy - int(140 * scale))),
        ((cx + int(120 * scale), cy - int(90 * scale)), (cx + int(70 * scale), cy - int(140 * scale))),
        ((cx, cy + int(60 * scale)), (cx - int(140 * scale), cy + int(10 * scale))),
        ((cx, cy + int(60 * scale)), (cx + int(140 * scale), cy + int(10 * scale))),
    ]

    for p1, p2 in circuit_lines:
        draw.line([p1, p2], fill=(82, 183, 136, 100), width=int(3 * scale))

    # Circuit nodes
    for px, py in node_points:
        draw.ellipse([px - int(7 * scale), py - int(7 * scale), px + int(7 * scale), py + int(7 * scale)],
                     fill=(216, 243, 220, 230), outline=(45, 106, 79, 255), width=int(2 * scale))

    # 4. Central Sprout Stem (V-Shape Base)
    stem_pts = [
        (cx, cy + int(130 * scale)),
        (cx - int(14 * scale), cy + int(50 * scale)),
        (cx, cy - int(20 * scale)),
        (cx + int(14 * scale), cy + int(50 * scale)),
    ]
    draw.polygon(stem_pts, fill=(233, 196, 106, 255)) # Golden harvest core

    # 5. Primary Left Foliar Leaf (Organic Polygon Bezier Simulation)
    left_leaf = []
    for deg in range(0, 185, 5):
        rad = math.radians(deg)
        r_val = 110 * math.sin(rad) * scale
        x = cx - int(r_val * math.sin(rad * 0.8) + (deg * 0.65 * scale))
        y = (cy + int(50 * scale)) - int(r_val * math.cos(rad * 0.8) + (deg * 0.8 * scale))
        left_leaf.append((x, y))
    left_leaf.append((cx, cy + int(50 * scale)))
    
    draw.polygon(left_leaf, fill=(45, 106, 79, 255)) # Rich secondary green
    draw.line(left_leaf, fill=(116, 198, 157, 255), width=int(4 * scale))

    # 6. Primary Right Foliar Leaf (Slightly larger, dynamic tilt)
    right_leaf = []
    for deg in range(0, 185, 5):
        rad = math.radians(deg)
        r_val = 125 * math.sin(rad) * scale
        x = cx + int(r_val * math.sin(rad * 0.8) + (deg * 0.72 * scale))
        y = (cy + int(50 * scale)) - int(r_val * math.cos(rad * 0.8) + (deg * 0.85 * scale))
        right_leaf.append((x, y))
    right_leaf.append((cx, cy + int(50 * scale)))

    draw.polygon(right_leaf, fill=(82, 183, 136, 255)) # Vibrant sage leaf
    draw.line(right_leaf, fill=(216, 243, 220, 255), width=int(4 * scale))

    # 7. Golden Central Bud / Seed of Intelligence
    bud_pts = [
        (cx, cy - int(95 * scale)),
        (cx - int(24 * scale), cy - int(45 * scale)),
        (cx, cy - int(10 * scale)),
        (cx + int(24 * scale), cy - int(45 * scale)),
    ]
    draw.polygon(bud_pts, fill=(233, 196, 106, 255), outline=(255, 255, 255, 220), width=int(2 * scale))

    # Core glowing neural nexus
    draw.ellipse([cx - int(10 * scale), cy - int(55 * scale), cx + int(10 * scale), cy - int(35 * scale)],
                 fill=(255, 255, 255, 255))

    # 8. Brand Typography Banner: "AGRI VYN"
    # Draw cleanly styled typography blocks for cross-platform render without external font dependency
    title_y = int(size * 0.76)
    
    # Try loading truetype font or fallback to crisp geometric vector typography
    try:
        font_main = ImageFont.truetype("arialbd.ttf", int(size * 0.082))
        font_sub = ImageFont.truetype("arial.ttf", int(size * 0.034))
        
        # AGRI VYN
        text_title = "AGRI VYN"
        bbox_t = draw.textbbox((0, 0), text_title, font=font_main)
        w_t = bbox_t[2] - bbox_t[0]
        draw.text(((size - w_t) // 2, title_y), text_title, fill=(255, 255, 255, 255), font=font_main)

        # SMART FARMING AI
        text_sub = "SMART FARMING AI"
        bbox_s = draw.textbbox((0, 0), text_sub, font=font_sub)
        w_s = bbox_s[2] - bbox_s[0]
        draw.text(((size - w_s) // 2, title_y + int(size * 0.09)), text_sub, fill=(233, 196, 106, 240), font=font_sub)
    except Exception:
        pass

    return img

def main():
    print("Generating official AgriVyn AI branding logo suite...")
    
    # High-resolution master (1024x1024)
    master_logo = create_agrivyn_logo(1024)
    master_path = ASSETS_DIR / "logo.png"
    master_logo.save(master_path, "PNG")
    print(f"Saved master logo: {master_path}")

    # Standard app logo (512x512)
    logo_512 = master_logo.resize((512, 512), Image.Resampling.LANCZOS)
    logo_512.save(ASSETS_DIR / "logo_512.png", "PNG")
    logo_512.save(WEB_ICONS_DIR / "Icon-512.png", "PNG")
    logo_512.save(WEB_ICONS_DIR / "Icon-maskable-512.png", "PNG")

    # Icon size (192x192)
    logo_192 = master_logo.resize((192, 192), Image.Resampling.LANCZOS)
    logo_192.save(ASSETS_DIR / "logo_192.png", "PNG")
    logo_192.save(WEB_ICONS_DIR / "Icon-192.png", "PNG")
    logo_192.save(WEB_ICONS_DIR / "Icon-maskable-192.png", "PNG")

    # App bar / Favicon (64x64 & 32x32)
    logo_64 = master_logo.resize((64, 64), Image.Resampling.LANCZOS)
    logo_64.save(ASSETS_DIR / "logo_icon.png", "PNG")
    logo_64.save(WEB_DIR / "favicon.png", "PNG")

    print("AgriVyn logo branding suite successfully generated across all resolutions!")

if __name__ == "__main__":
    main()
