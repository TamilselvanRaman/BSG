import os
import json
import time
import urllib.request
import urllib.parse
from PIL import Image, ImageDraw, ImageFont
import io

HEADERS = {
    'User-Agent': 'AntigravityCropBot/1.0 (agri-catalog@bsg.app)'
}

BASE_DIR = r"S:\Project\BuyerSellerManagementAPPSaas\mobile\assets\products"

def get_wiki_image_url(query):
    # Try direct pageimages query
    encoded = urllib.parse.quote(query)
    url = f"https://en.wikipedia.org/w/api.php?action=query&titles={encoded}&prop=pageimages&pithumbsize=300&format=json"
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            pages = data.get('query', {}).get('pages', {})
            for pid, pdata in pages.items():
                if pid != '-1' and 'thumbnail' in pdata:
                    return pdata['thumbnail']['source']
    except Exception as e:
        pass

    # Try search query if direct title failed
    search_url = f"https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={encoded}&srlimit=1&format=json"
    try:
        req = urllib.request.Request(search_url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            results = data.get('query', {}).get('search', [])
            if results:
                first_title = results[0]['title']
                enc_title = urllib.parse.quote(first_title)
                url2 = f"https://en.wikipedia.org/w/api.php?action=query&titles={enc_title}&prop=pageimages&pithumbsize=300&format=json"
                req2 = urllib.request.Request(url2, headers=HEADERS)
                with urllib.request.urlopen(req2, timeout=5) as resp2:
                    data2 = json.loads(resp2.read().decode('utf-8'))
                    pages2 = data2.get('query', {}).get('pages', {})
                    for pid2, pdata2 in pages2.items():
                        if pid2 != '-1' and 'thumbnail' in pdata2:
                            return pdata2['thumbnail']['source']
    except Exception as e:
        pass

    return None

def download_and_process_image(img_url, out_path, fallback_name, fallback_color=(21, 155, 61)):
    target_size = (256, 256)
    canvas = Image.new("RGBA", target_size, (255, 255, 255, 255))
    
    success = False
    if img_url:
        try:
            req = urllib.request.Request(img_url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=8) as resp:
                raw_bytes = resp.read()
                src_img = Image.open(io.BytesIO(raw_bytes)).convert("RGBA")
                src_img.thumbnail((240, 240), Image.Resampling.LANCZOS)
                
                # Center on white canvas
                offset = ((256 - src_img.width) // 2, (256 - src_img.height) // 2)
                canvas.paste(src_img, offset, src_img)
                success = True
        except Exception as e:
            success = False

    if not success:
        # Draw a beautiful clean botanical icon fallback
        draw = ImageDraw.Draw(canvas)
        draw.ellipse([20, 20, 236, 236], fill=(245, 248, 245, 255), outline=fallback_color, width=4)
        # Draw initials
        words = fallback_name.split()
        initials = "".join([w[0].upper() for w in words[:2]])
        draw.text((128, 128), initials, fill=fallback_color, anchor="mm")

    canvas.convert("RGB").save(out_path, "PNG", optimize=True)

print("Helper ready")

