import os
import json
import time
import urllib.request
import urllib.parse
from PIL import Image, ImageDraw
import io
import concurrent.futures

BASE_ASSET_DIR = r"S:\Project\BuyerSellerManagementAPPSaas\mobile\assets\products"

HEADERS = {
    'User-Agent': 'AntigravityCropBot/2.0 (contact@bsg.app)'
}

CATALOGUE = [
    # FRUITS
    ("fruit", "fruit_001", "Apple", "apple.png", "Apple fruit", "Kg"),
    ("fruit", "fruit_002", "Banana", "banana.png", "Banana fruit", "Boxes"),
    ("fruit", "fruit_003", "Mango", "mango.png", "Mango fruit", "Boxes"),
    ("fruit", "fruit_004", "Orange", "orange.png", "Orange fruit", "Kg"),
    ("fruit", "fruit_005", "Grapes", "grapes.png", "Grapes fruit", "Boxes"),
    ("fruit", "fruit_006", "Watermelon", "watermelon.png", "Watermelon fruit", "Kg"),
    ("fruit", "fruit_007", "Muskmelon", "muskmelon.png", "Muskmelon fruit", "Kg"),
    ("fruit", "fruit_008", "Papaya", "papaya.png", "Papaya fruit", "Kg"),
    ("fruit", "fruit_009", "Pineapple", "pineapple.png", "Pineapple fruit", "Boxes"),
    ("fruit", "fruit_010", "Guava", "guava.png", "Guava fruit", "Kg"),
    ("fruit", "fruit_011", "Pomegranate", "pomegranate.png", "Pomegranate fruit", "Boxes"),
    ("fruit", "fruit_012", "Lemon", "lemon.png", "Lemon fruit", "Bags"),
    ("fruit", "fruit_013", "Sweet Lime", "sweet_lime.png", "Sweet lime Mosambi fruit", "Bags"),
    ("fruit", "fruit_014", "Coconut", "coconut.png", "Coconut fruit", "Bags"),
    ("fruit", "fruit_015", "Tender Coconut", "tender_coconut.png", "Green tender coconut", "Bags"),
    ("fruit", "fruit_016", "Jackfruit", "jackfruit.png", "Jackfruit fruit", "Kg"),
    ("fruit", "fruit_017", "Sapota / Chikoo", "sapota.png", "Sapota Chikoo fruit", "Boxes"),
    ("fruit", "fruit_018", "Custard Apple", "custard_apple.png", "Custard apple Sitaphal", "Boxes"),
    ("fruit", "fruit_019", "Dragon Fruit", "dragon_fruit.png", "Dragon fruit Pitaya", "Boxes"),
    ("fruit", "fruit_020", "Strawberry", "strawberry.png", "Strawberry fruit", "Boxes"),
    ("fruit", "fruit_021", "Blueberry", "blueberry.png", "Blueberry fruit", "Boxes"),
    ("fruit", "fruit_022", "Blackberry", "blackberry.png", "Blackberry fruit", "Boxes"),
    ("fruit", "fruit_023", "Raspberry", "raspberry.png", "Raspberry fruit", "Boxes"),
    ("fruit", "fruit_024", "Kiwi", "kiwi.png", "Kiwifruit", "Boxes"),
    ("fruit", "fruit_025", "Pear", "pear.png", "Pear fruit", "Boxes"),
    ("fruit", "fruit_026", "Peach", "peach.png", "Peach fruit", "Boxes"),
    ("fruit", "fruit_027", "Plum", "plum.png", "Plum fruit", "Boxes"),
    ("fruit", "fruit_028", "Cherry", "cherry.png", "Cherry fruit", "Boxes"),
    ("fruit", "fruit_029", "Avocado", "avocado.png", "Avocado fruit", "Boxes"),
    ("fruit", "fruit_030", "Fig", "fig.png", "Common fig Anjeer", "Boxes"),
    ("fruit", "fruit_031", "Dates", "dates.png", "Date fruit Khajoor", "Boxes"),
    ("fruit", "fruit_032", "Lychee", "lychee.png", "Lychee fruit Litchi", "Boxes"),
    ("fruit", "fruit_033", "Longan", "longan.png", "Longan fruit", "Boxes"),
    ("fruit", "fruit_034", "Passion Fruit", "passion_fruit.png", "Passion fruit", "Kg"),
    ("fruit", "fruit_035", "Star Fruit", "star_fruit.png", "Carambola star fruit", "Kg"),
    ("fruit", "fruit_036", "Gooseberry", "gooseberry.png", "Gooseberry fruit", "Kg"),
    ("fruit", "fruit_037", "Amla", "amla.png", "Phyllanthus emblica Amla fruit", "Kg"),
    ("fruit", "fruit_038", "Jamun", "jamun.png", "Syzygium cumini Jamun", "Kg"),
    ("fruit", "fruit_039", "Wood Apple", "wood_apple.png", "Wood apple Bael", "Kg"),
    ("fruit", "fruit_040", "Pomelo", "pomelo.png", "Pomelo citrus", "Kg"),
    ("fruit", "fruit_041", "Apricot", "apricot.png", "Apricot fruit", "Boxes"),
    ("fruit", "fruit_042", "Grapefruit", "grapefruit.png", "Grapefruit citrus", "Boxes"),
    ("fruit", "fruit_043", "Persimmon", "persimmon.png", "Persimmon fruit", "Boxes"),
    ("fruit", "fruit_044", "Mangosteen", "mangosteen.png", "Mangosteen fruit", "Boxes"),
    ("fruit", "fruit_045", "Rambutan", "rambutan.png", "Rambutan fruit", "Boxes"),
    ("fruit", "fruit_046", "Durian", "durian.png", "Durian fruit", "Kg"),
    ("fruit", "fruit_047", "Breadfruit", "breadfruit.png", "Breadfruit", "Kg"),
    ("fruit", "fruit_048", "Mulberry", "mulberry.png", "Mulberry fruit", "Kg"),

    # VEGETABLES
    ("veg", "veg_001", "Ash Gourd", "ash_gourd.png", "India Ash Gourd", "Kg"),
    ("veg", "veg_002", "Bitter Gourd", "bitter_gourd.png", "Momordica charantia bitter gourd", "Bags"),
    ("veg", "veg_003", "Bottle Gourd", "bottle_gourd.png", "Calabash bottle gourd", "Bags"),
    ("veg", "veg_004", "Brinjal", "brinjal.png", "Eggplant aubergine brinjal", "Bags"),
    ("veg", "veg_005", "Blue Long Brinjal", "blue_long_brinjal.png", "Eggplant long purple", "Bags"),
    ("veg", "veg_006", "Blue Round Brinjal", "blue_round_brinjal.png", "Round purple eggplant brinjal", "Bags"),
    ("veg", "veg_007", "Black Carrot", "black_carrot.png", "Black carrot", "Kg"),
    ("veg", "veg_008", "Beetroot", "beetroot.png", "Beetroot beta vulgaris", "Bags"),
    ("veg", "veg_009", "Carrot", "carrot.png", "Carrot vegetables", "Bags"),
    ("veg", "veg_010", "Cabbage", "cabbage.png", "Cabbage vegetable", "Bags"),
    ("veg", "veg_011", "Cauliflower", "cauliflower.png", "Cauliflower brassica", "Bags"),
    ("veg", "veg_012", "Broccoli", "broccoli.png", "Broccoli vegetable", "Boxes"),
    ("veg", "veg_013", "Beans", "beans.png", "Green beans vegetable", "Bags"),
    ("veg", "veg_014", "Broad Beans", "broad_beans.png", "Broad beans Vicia faba", "Bags"),
    ("veg", "veg_015", "Cluster Beans", "cluster_beans.png", "Guar cluster beans", "Bags"),
    ("veg", "veg_016", "Green Peas", "green_peas.png", "Green peas in pod", "Bags"),
    ("veg", "veg_017", "Drumstick", "drumstick.png", "Moringa oleifera drumstick pods", "Bundles"),
    ("veg", "veg_018", "Drumstick Leaves", "drumstick_leaves.png", "Moringa leaves drumstick", "Bundles"),
    ("veg", "veg_019", "Okra / Lady Finger", "okra.png", "Okra ladies finger vegetable", "Bags"),
    ("veg", "veg_020", "Onion", "onion.png", "Red onion vegetable", "Bags"),
    ("veg", "veg_021", "Small Onion", "small_onion.png", "Shallot small onion Sambar onion", "Bags"),
    ("veg", "veg_022", "Potato", "potato.png", "Potato tubers", "Bags"),
    ("veg", "veg_023", "Sweet Potato", "sweet_potato.png", "Sweet potato tubers", "Bags"),
    ("veg", "veg_024", "Tomato", "tomato.png", "Red fresh tomato", "Boxes"),
    ("veg", "veg_025", "Green Chilli", "green_chilli.png", "Green chili pepper", "Bags"),
    ("veg", "veg_026", "Red Chilli", "red_chilli.png", "Fresh red chili pepper", "Bags"),
    ("veg", "veg_027", "Capsicum", "capsicum.png", "Green bell pepper capsicum", "Boxes"),
    ("veg", "veg_028", "Cucumber", "cucumber.png", "Fresh cucumber vegetable", "Bags"),
    ("veg", "veg_029", "Pumpkin", "pumpkin.png", "Pumpkin squash", "Kg"),
    ("veg", "veg_030", "Snake Gourd", "snake_gourd.png", "Trichosanthes cucumerina snake gourd", "Bags"),
    ("veg", "veg_031", "Ridge Gourd", "ridge_gourd.png", "Luffa acutangula ridge gourd", "Bags"),
    ("veg", "veg_032", "Ivy Gourd", "ivy_gourd.png", "Coccinia grandis ivy gourd Tindora", "Bags"),
    ("veg", "veg_033", "Chow Chow", "chow_chow.png", "Chayote chow chow", "Bags"),
    ("veg", "veg_034", "Radish", "radish.png", "White radish daikon", "Bags"),
    ("veg", "veg_035", "Turnip", "turnip.png", "Turnip root vegetable", "Kg"),
    ("veg", "veg_036", "Spinach", "spinach.png", "Spinach leaves palak", "Bundles"),
    ("veg", "veg_037", "Amaranthus", "amaranthus.png", "Red amaranth leaves", "Bundles"),
    ("veg", "veg_038", "Coriander Leaves", "coriander_leaves.png", "Fresh coriander cilantro leaves", "Bundles"),
    ("veg", "veg_039", "Mint Leaves", "mint_leaves.png", "Fresh mint leaves pudina", "Bundles"),
    ("veg", "veg_040", "Curry Leaves", "curry_leaves.png", "Curry leaves Murraya koenigii", "Bundles"),
    ("veg", "veg_041", "Lettuce", "lettuce.png", "Lettuce salad greens", "Boxes"),
    ("veg", "veg_042", "Celery", "celery.png", "Celery vegetable", "Boxes"),
    ("veg", "veg_043", "Spring Onion", "spring_onion.png", "Spring onion scallion", "Bundles"),
    ("veg", "veg_044", "Mushroom", "mushroom.png", "Button mushroom Agaricus bisporus", "Boxes"),
    ("veg", "veg_045", "Sweet Corn", "sweet_corn.png", "Sweet corn cob", "Bags"),
    ("veg", "veg_046", "Baby Corn", "baby_corn.png", "Baby corn", "Boxes"),
    ("veg", "veg_047", "Brussels Sprouts", "brussels_sprouts.png", "Brussels sprouts", "Boxes"),
    ("veg", "veg_048", "Bok Choy", "bok_choy.png", "Bok choy pak choi", "Boxes"),
    ("veg", "veg_049", "Zucchini", "zucchini.png", "Green zucchini courgette", "Boxes"),
    ("veg", "veg_050", "Asparagus", "asparagus.png", "Green asparagus spears", "Boxes"),
    ("veg", "veg_051", "Artichokes", "artichokes.png", "Globe artichoke", "Boxes"),
    ("veg", "veg_052", "Aloe Vera", "aloe_vera.png", "Aloe vera plant leaves", "Kg"),
    ("veg", "veg_053", "Betel Leaf", "betel_leaf.png", "Piper betle leaf paan", "Bundles"),
    ("veg", "veg_054", "Raw Banana", "raw_banana.png", "Green cooking plantain banana", "Bunches"),
    ("veg", "veg_055", "Banana Flower", "banana_flower.png", "Banana heart blossom flower", "Pieces"),
    ("veg", "veg_056", "Banana Stem", "banana_stem.png", "Banana pith pseudostem", "Pieces"),
    ("veg", "veg_057", "Taro Root", "taro_root.png", "Taro corm Arbi", "Bags"),
    ("veg", "veg_058", "Elephant Yam", "elephant_yam.png", "Amorphophallus paeoniifolius elephant foot yam", "Kg"),
    ("veg", "veg_059", "Tapioca", "tapioca.png", "Cassava tapioca root", "Bags"),
    ("veg", "veg_060", "Ginger", "ginger.png", "Fresh ginger rhizome", "Bags"),
    ("veg", "veg_061", "Garlic", "garlic.png", "Garlic bulb cloves", "Bags"),

    # FLOWERS
    ("flower", "flower_001", "Cent Yellow", "cent_yellow.png", "Yellow Chrysanthemum flower", "Kg"),
    ("flower", "flower_002", "Chocolate Rose", "chocolate_rose.png", "Dark red chocolate rose", "Bunches"),
    ("flower", "flower_003", "Lakshmi Purple", "lakshmi_purple.png", "Purple Dendrobium orchid", "Bunches"),
    ("flower", "flower_004", "Mango Yellow Rose", "mango_yellow_rose.png", "Yellow rose flower", "Bunches"),
    ("flower", "flower_005", "Marigold", "marigold.png", "Tagetes orange marigold", "Bags"),
    ("flower", "flower_006", "Merabul Rose", "merabul_rose.png", "Rose flower bloom", "Bunches"),
    ("flower", "flower_007", "Red Rose", "red_rose.png", "Red rose bloom", "Bunches"),
    ("flower", "flower_008", "White Rose", "white_rose.png", "White rose flower", "Bunches"),
    ("flower", "flower_009", "Pink Rose", "pink_rose.png", "Pink rose flower", "Bunches"),
    ("flower", "flower_010", "Jasmine", "jasmine.png", "Jasminum sambac Arabian jasmine", "Kg"),
    ("flower", "flower_011", "Mullai", "mullai.png", "Jasminum auriculatum flower", "Kg"),
    ("flower", "flower_012", "Jathimalli", "jathimalli.png", "Jasminum grandiflorum flower", "Kg"),
    ("flower", "flower_013", "Kanakambaram", "kanakambaram.png", "Crossandra infundibuliformis firecracker flower", "Kg"),
    ("flower", "flower_014", "Chrysanthemum", "chrysanthemum.png", "Chrysanthemum flower bloom", "Bags"),
    ("flower", "flower_015", "Gerbera", "gerbera.png", "Gerbera daisy flower", "Bunches"),
    ("flower", "flower_016", "Lotus", "lotus.png", "Nelumbo nucifera pink lotus", "Pieces"),
    ("flower", "flower_017", "Sunflower", "sunflower.png", "Sunflower bloom Helianthus", "Pieces"),
    ("flower", "flower_018", "Lily", "lily.png", "Lilium white lily flower", "Bunches"),
    ("flower", "flower_019", "Orchid", "orchid.png", "Orchid flower bloom", "Bunches"),
    ("flower", "flower_020", "Tulip", "tulip.png", "Tulip flower", "Bunches"),
    ("flower", "flower_021", "Tuberose", "tuberose.png", "Agave amica Polianthes tuberosa rajnigandha", "Kg"),
    ("flower", "flower_022", "Crossandra", "crossandra.png", "Crossandra flower", "Kg"),
    ("flower", "flower_023", "Hibiscus", "hibiscus.png", "Hibiscus rosa-sinensis red", "Pieces"),
    ("flower", "flower_024", "Daffodil", "daffodil.png", "Yellow daffodil Narcissus", "Bunches"),
    ("flower", "flower_025", "Carnation", "carnation.png", "Carnation Dianthus flower", "Bunches"),
    ("flower", "flower_026", "Dahlia", "dahlia.png", "Dahlia flower bloom", "Bunches"),
    ("flower", "flower_027", "Aster", "aster.png", "Aster flower bloom", "Bunches"),
    ("flower", "flower_028", "Baby's Breath", "babys_breath.png", "Gypsophila baby breath", "Bunches"),
    ("flower", "flower_029", "Button Rose", "button_rose.png", "Miniature button rose", "Kg"),
    ("flower", "flower_030", "Sampangi", "sampangi.png", "Magnolia champaca Michelia golden champa", "Kg"),
    ("flower", "flower_031", "Arali", "arali.png", "Nerium oleander pink arali flower", "Kg"),
    ("flower", "flower_032", "Vadamalli", "vadamalli.png", "Gomphrena globosa globe amaranth vadamalli", "Kg"),

    # SPICES
    ("spices", "spice_001", "Black Pepper", "black_pepper.png", "Black peppercorns Piper nigrum", "Kg"),
    ("spices", "spice_002", "White Pepper", "white_pepper.png", "White peppercorns", "Kg"),
    ("spices", "spice_003", "Cardamom", "cardamom.png", "Green cardamom pods", "Kg"),
    ("spices", "spice_004", "Green Cardamom", "green_cardamom.png", "Elettaria cardamomum pods", "Kg"),
    ("spices", "spice_005", "Black Cardamom", "black_cardamom.png", "Black cardamom pods Amomum", "Kg"),
    ("spices", "spice_006", "Cloves", "cloves.png", "Cloves spice Syzygium aromaticum", "Kg"),
    ("spices", "spice_007", "Cinnamon", "cinnamon.png", "Cinnamon bark sticks", "Kg"),
    ("spices", "spice_008", "Cumin", "cumin.png", "Cumin seeds Jeera", "Kg"),
    ("spices", "spice_009", "Coriander Seeds", "coriander_seeds.png", "Coriander seeds Dhania", "Bags"),
    ("spices", "spice_010", "Fennel Seeds", "fennel_seeds.png", "Fennel seeds Saunf", "Kg"),
    ("spices", "spice_011", "Mustard Seeds", "mustard_seeds.png", "Black mustard seeds Rai", "Kg"),
    ("spices", "spice_012", "Fenugreek", "fenugreek.png", "Fenugreek seeds Methi", "Kg"),
    ("spices", "spice_013", "Turmeric", "turmeric.png", "Turmeric dried rhizome Haldi", "Bags"),
    ("spices", "spice_014", "Dry Red Chilli", "dry_red_chilli.png", "Dried red chili peppers", "Bags"),
    ("spices", "spice_015", "Star Anise", "star_anise.png", "Illicium verum star anise", "Kg"),
    ("spices", "spice_016", "Nutmeg", "nutmeg.png", "Nutmeg seed Jaiphal", "Kg"),
    ("spices", "spice_017", "Mace", "mace.png", "Mace spice Javitri", "Kg"),
    ("spices", "spice_018", "Bay Leaf", "bay_leaf.png", "Bay leaf Tejpatta", "Bags"),
    ("spices", "spice_019", "Poppy Seeds", "poppy_seeds.png", "White poppy seeds Khas Khas", "Kg"),
    ("spices", "spice_020", "Sesame Seeds", "sesame_seeds.png", "White sesame seeds Til", "Bags"),
    ("spices", "spice_021", "Ajwain", "ajwain.png", "Ajwain carom seeds", "Kg"),
    ("spices", "spice_022", "Asafoetida", "asafoetida.png", "Asafoetida Hing", "Kg"),
    ("spices", "spice_023", "Saffron", "saffron.png", "Saffron threads Kesar", "Grams"),
    ("spices", "spice_024", "Dry Ginger", "dry_ginger.png", "Dried ginger Sonth", "Bags"),
    ("spices", "spice_025", "Garlic Flakes", "garlic_flakes.png", "Dehydrated garlic flakes", "Bags"),
    ("spices", "spice_026", "Tamarind", "tamarind.png", "Tamarind pods Imli", "Bags"),
    ("spices", "spice_027", "Curry Powder", "curry_powder.png", "Curry powder bowl spice", "Kg"),
    ("spices", "spice_028", "Chilli Powder", "chilli_powder.png", "Red chili powder bowl", "Kg"),
    ("spices", "spice_029", "Coriander Powder", "coriander_powder.png", "Coriander powder Dhania powder", "Kg"),

    # CROPS
    ("crop", "crop_001", "Paddy", "paddy.png", "Paddy rice field crop", "Quintal"),
    ("crop", "crop_002", "Rice", "rice.png", "Milled white rice grain", "Bags"),
    ("crop", "crop_003", "Wheat", "wheat.png", "Wheat grain harvest", "Quintal"),
    ("crop", "crop_004", "Maize", "maize.png", "Maize corn grain", "Quintal"),
    ("crop", "crop_005", "Corn", "corn.png", "Yellow corn ears", "Quintal"),
    ("crop", "crop_006", "Ragi", "ragi.png", "Finger millet Ragi grain", "Quintal"),
    ("crop", "crop_007", "Jowar", "jowar.png", "Sorghum jowar grain", "Quintal"),
    ("crop", "crop_008", "Bajra", "bajra.png", "Pearl millet Bajra grain", "Quintal"),
    ("crop", "crop_009", "Groundnut", "groundnut.png", "Groundnut peanut pods", "Bags"),
    ("crop", "crop_010", "Cotton", "cotton.png", "Raw cotton bolls", "Quintal"),
    ("crop", "crop_011", "Sugarcane", "sugarcane.png", "Sugarcane stalks harvest", "Ton"),
    ("crop", "crop_012", "Turmeric Crop", "turmeric_crop.png", "Raw turmeric rhizomes", "Quintal"),
    ("crop", "crop_013", "Banana Crop", "banana_crop.png", "Green banana bunch crop", "Ton"),
    ("crop", "crop_014", "Coconut Crop", "coconut_crop.png", "Fresh coconuts harvest", "Thousands"),
    ("crop", "crop_015", "Arecanut", "arecanut.png", "Areca betel nut Supari", "Quintal"),
    ("crop", "crop_016", "Tobacco", "tobacco.png", "Cured tobacco leaves", "Quintal"),
    ("crop", "crop_017", "Sunflower Seeds", "sunflower_seeds.png", "Black sunflower seeds", "Quintal"),
    ("crop", "crop_018", "Soybean", "soybean.png", "Soybean seeds Glycine max", "Quintal"),
    ("crop", "crop_019", "Sesame Crop", "sesame_crop.png", "Sesame seeds harvest", "Quintal"),
    ("crop", "crop_020", "Castor", "castor.png", "Castor bean seeds Ricinus", "Quintal"),
    ("crop", "crop_021", "Black Gram", "black_gram.png", "Urad dal black gram beans", "Quintal"),
    ("crop", "crop_022", "Green Gram", "green_gram.png", "Moong dal green gram beans", "Quintal"),
    ("crop", "crop_023", "Red Gram", "red_gram.png", "Toor dal red gram pigeon pea", "Quintal"),
    ("crop", "crop_024", "Bengal Gram", "bengal_gram.png", "Chana Bengal gram chickpea", "Quintal"),
    ("crop", "crop_025", "Horse Gram", "horse_gram.png", "Horse gram Kollu", "Quintal"),
    ("crop", "crop_026", "Chickpea", "chickpea.png", "Kabuli chana chickpea", "Quintal"),
    ("crop", "crop_027", "Mustard Crop", "mustard_crop.png", "Yellow mustard field flowers", "Quintal"),
]

def search_commons_image(query):
    encoded = urllib.parse.quote(query)
    url = f"https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch={encoded}&gsrnamespace=6&gsrlimit=1&prop=imageinfo&iiprop=url&iiurlwidth=300&format=json"
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=8) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            pages = data.get('query', {}).get('pages', {})
            for pid, pdata in pages.items():
                if 'imageinfo' in pdata and pdata['imageinfo']:
                    info = pdata['imageinfo'][0]
                    return info.get('thumburl') or info.get('url')
    except Exception:
        pass
    return None

def search_wikipedia_image(query):
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
    except Exception:
        pass
    return None

def process_item(item):
    cat, pid, name, filename, query, unit = item
    out_dir = os.path.join(BASE_ASSET_DIR, cat)
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, filename)

    # Check if already a real photo (size > 8KB)
    if os.path.exists(out_path) and os.path.getsize(out_path) > 8000:
        return (pid, True, "cached")

    # Try Wikipedia first, then Commons
    img_url = search_wikipedia_image(query)
    if not img_url:
        img_url = search_commons_image(query)
    if not img_url:
        img_url = search_commons_image(name)

    target_size = (256, 256)
    canvas = Image.new("RGBA", target_size, (255, 255, 255, 255))
    success = False

    if img_url:
        try:
            req = urllib.request.Request(img_url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=10) as resp:
                raw_bytes = resp.read()
                src_img = Image.open(io.BytesIO(raw_bytes)).convert("RGBA")
                src_img.thumbnail((240, 240), Image.Resampling.LANCZOS)
                offset = ((256 - src_img.width) // 2, (256 - src_img.height) // 2)
                canvas.paste(src_img, offset, src_img)
                success = True
        except Exception:
            success = False

    if not success:
        draw = ImageDraw.Draw(canvas)
        draw.ellipse([16, 16, 240, 240], fill=(235, 245, 238, 255), outline=(21, 155, 61, 255), width=4)
        words = name.split()
        initials = "".join([w[0].upper() for w in words[:2]])
        draw.text((128, 128), initials, fill=(21, 155, 61, 255), anchor="mm")

    canvas.convert("RGB").save(out_path, "PNG", optimize=True)
    return (pid, success, img_url)

print(f"Enhancing catalogue image downloads with Commons search...")
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    results = list(executor.map(process_item, CATALOGUE))

success_count = sum(1 for r in results if r[1])
print(f"Finished processing {len(results)} items. Success: {success_count}/{len(results)}")
