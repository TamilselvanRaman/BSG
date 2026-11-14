import os
import json
import urllib.request
import urllib.parse
from PIL import Image
import io
import concurrent.futures

BASE_ASSET_DIR = r"S:\Project\BuyerSellerManagementAPPSaas\mobile\assets\products"
HEADERS = {'User-Agent': 'AntigravityCropBot/3.0 (bot@bsg.app)'}

REMAINING = {
    # CROPS
    ("crop", "arecanut.png"): ["Areca nut", "Areca catechu"],
    ("crop", "bajra.png"): ["Pearl millet", "Pennisetum glaucum"],
    ("crop", "banana_crop.png"): ["Banana", "Musa (genus)"],
    ("crop", "bengal_gram.png"): ["Chickpea", "Cicer arietinum"],
    ("crop", "black_gram.png"): ["Vigna mungo", "Urad bean"],
    ("crop", "castor.png"): ["Ricinus communis", "Castor oil plant"],
    ("crop", "chickpea.png"): ["Chickpea", "Cicer arietinum"],
    ("crop", "coconut_crop.png"): ["Coconut", "Cocos nucifera"],
    ("crop", "corn.png"): ["Corn", "Maize"],
    ("crop", "cotton.png"): ["Cotton", "Gossypium"],
    ("crop", "green_gram.png"): ["Mung bean", "Vigna radiata"],
    ("crop", "groundnut.png"): ["Peanut", "Arachis hypogaea"],
    ("crop", "horse_gram.png"): ["Macrotyloma uniflorum", "Horse gram"],
    ("crop", "jowar.png"): ["Sorghum", "Sorghum bicolor"],
    ("crop", "maize.png"): ["Maize", "Corn"],
    ("crop", "mustard_crop.png"): ["Mustard plant", "Brassica juncea"],
    ("crop", "paddy.png"): ["Paddy field", "Rice"],
    ("crop", "ragi.png"): ["Eleusine coracana", "Finger millet"],
    ("crop", "red_gram.png"): ["Pigeon pea", "Cajanus cajan"],
    ("crop", "rice.png"): ["Rice", "Oryza sativa"],
    ("crop", "sesame_crop.png"): ["Sesame", "Sesamum indicum"],
    ("crop", "soybean.png"): ["Soybean", "Glycine max"],
    ("crop", "sugarcane.png"): ["Sugarcane", "Saccharum officinarum"],
    ("crop", "sunflower_seeds.png"): ["Sunflower seed", "Helianthus annuus"],
    ("crop", "tobacco.png"): ["Tobacco", "Nicotiana tabacum"],
    ("crop", "turmeric_crop.png"): ["Curcuma longa", "Turmeric"],
    ("crop", "wheat.png"): ["Wheat", "Triticum"],

    # FLOWERS
    ("flower", "arali.png"): ["Nerium oleander", "Oleander"],
    ("flower", "aster.png"): ["Aster (genus)", "Asteraceae"],
    ("flower", "babys_breath.png"): ["Gypsophila paniculata", "Gypsophila"],
    ("flower", "button_rose.png"): ["Rosa chinensis", "Garden roses"],
    ("flower", "carnation.png"): ["Dianthus caryophyllus", "Carnation"],
    ("flower", "crossandra.png"): ["Crossandra infundibuliformis", "Crossandra"],
    ("flower", "daffodil.png"): ["Narcissus (plant)", "Daffodil"],
    ("flower", "dahlia.png"): ["Dahlia", "Dahlia pinnata"],
    ("flower", "hibiscus.png"): ["Hibiscus rosa-sinensis", "Hibiscus"],
    ("flower", "lily.png"): ["Lilium", "Lily"],
    ("flower", "orchid.png"): ["Orchidaceae", "Orchid"],
    ("flower", "sampangi.png"): ["Magnolia champaca", "Michelia champaca"],
    ("flower", "sunflower.png"): ["Helianthus annuus", "Common sunflower"],
    ("flower", "tuberose.png"): ["Agave amica", "Polianthes tuberosa"],
    ("flower", "tulip.png"): ["Tulip", "Tulipa"],
    ("flower", "vadamalli.png"): ["Gomphrena globosa", "Globe amaranth"],

    # SPICES
    ("spices", "ajwain.png"): ["Ajwain", "Trachyspermum ammi"],
    ("spices", "asafoetida.png"): ["Asafoetida", "Ferula assa-foetida"],
    ("spices", "bay_leaf.png"): ["Bay leaf", "Laurus nobilis"],
    ("spices", "black_cardamom.png"): ["Black cardamom", "Amomum subulatum"],
    ("spices", "black_pepper.png"): ["Black pepper", "Piper nigrum"],
    ("spices", "cardamom.png"): ["Cardamom", "Elettaria cardamomum"],
    ("spices", "chilli_powder.png"): ["Chili powder", "Chili pepper"],
    ("spices", "cinnamon.png"): ["Cinnamon", "Cinnamomum verum"],
    ("spices", "cloves.png"): ["Clove", "Syzygium aromaticum"],
    ("spices", "coriander_powder.png"): ["Coriander", "Coriandrum sativum"],
    ("spices", "coriander_seeds.png"): ["Coriander", "Coriandrum sativum"],
    ("spices", "cumin.png"): ["Cumin", "Cuminum cyminum"],
    ("spices", "curry_powder.png"): ["Curry powder", "Spice mix"],
    ("spices", "dry_ginger.png"): ["Ginger", "Zingiber officinale"],
    ("spices", "dry_red_chilli.png"): ["Chili pepper", "Capsicum annuum"],
    ("spices", "fennel_seeds.png"): ["Fennel", "Foeniculum vulgare"],
    ("spices", "fenugreek.png"): ["Fenugreek", "Trigonella foenum-graecum"],
    ("spices", "garlic_flakes.png"): ["Garlic", "Allium sativum"],
    ("spices", "green_cardamom.png"): ["Elettaria cardamomum", "Cardamom"],
    ("spices", "mace.png"): ["Nutmeg", "Myristica fragrans"],
    ("spices", "mustard_seeds.png"): ["Mustard seed", "Brassica nigra"],
    ("spices", "nutmeg.png"): ["Nutmeg", "Myristica fragrans"],
    ("spices", "poppy_seeds.png"): ["Poppy seed", "Papaver somniferum"],
    ("spices", "saffron.png"): ["Saffron", "Crocus sativus"],
    ("spices", "sesame_seeds.png"): ["Sesame", "Sesamum indicum"],
    ("spices", "star_anise.png"): ["Illicium verum", "Star anise"],
    ("spices", "tamarind.png"): ["Tamarind", "Tamarindus indica"],
    ("spices", "turmeric.png"): ["Turmeric", "Curcuma longa"],
    ("spices", "white_pepper.png"): ["White pepper", "Black pepper"],
}

def get_image_url(query):
    encoded = urllib.parse.quote(query)
    # 1. PageImages
    url = f"https://en.wikipedia.org/w/api.php?action=query&titles={encoded}&prop=pageimages&pithumbsize=300&format=json"
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=6) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            for pid, pdata in data.get('query', {}).get('pages', {}).items():
                if pid != '-1' and 'thumbnail' in pdata:
                    return pdata['thumbnail']['source']
    except Exception:
        pass

    # 2. Commons File search
    url2 = f"https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch={encoded}&gsrnamespace=6&gsrlimit=1&prop=imageinfo&iiprop=url&iiurlwidth=300&format=json"
    try:
        req2 = urllib.request.Request(url2, headers=HEADERS)
        with urllib.request.urlopen(req2, timeout=6) as resp2:
            data2 = json.loads(resp2.read().decode('utf-8'))
            for pid, pdata in data2.get('query', {}).get('pages', {}).items():
                if 'imageinfo' in pdata and pdata['imageinfo']:
                    info = pdata['imageinfo'][0]
                    return info.get('thumburl') or info.get('url')
    except Exception:
        pass

    return None

def process_item(item):
    (cat, filename), queries = item
    out_path = os.path.join(BASE_ASSET_DIR, cat, filename)

    img_url = None
    for q in queries:
        img_url = get_image_url(q)
        if img_url:
            break

    if not img_url:
        return (filename, False, "not found")

    try:
        req = urllib.request.Request(img_url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=8) as resp:
            raw_bytes = resp.read()
            src_img = Image.open(io.BytesIO(raw_bytes)).convert("RGBA")
            src_img.thumbnail((240, 240), Image.Resampling.LANCZOS)
            canvas = Image.new("RGBA", (256, 256), (255, 255, 255, 255))
            offset = ((256 - src_img.width) // 2, (256 - src_img.height) // 2)
            canvas.paste(src_img, offset, src_img)
            canvas.convert("RGB").save(out_path, "PNG", optimize=True)
            return (filename, True, img_url)
    except Exception as e:
        return (filename, False, str(e))

print(f"Downloading images for {len(REMAINING)} items...")
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    results = list(executor.map(process_item, REMAINING.items()))

success_count = sum(1 for r in results if r[1])
print(f"Completed: {success_count}/{len(REMAINING)} downloaded!")

