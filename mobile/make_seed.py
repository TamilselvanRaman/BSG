from download_all_catalogue import CATALOGUE

code = """import '../models/product_model.dart';

final List<Product> defaultProductCatalogue = [
"""

now_str = 'DateTime(2026, 1, 1)'

for cat, pid, name, filename, query, unit in CATALOGUE:
    asset_path = f'assets/products/{cat}/{filename}'
    cat_enum = f'ProductCategory.{cat}'
    clean_name = name.replace("'", "\\'")
    code += f"""  Product(
    id: '{pid}',
    name: '{clean_name}',
    category: {cat_enum},
    assetPath: '{asset_path}',
    defaultUnit: '{unit}',
    isActive: true,
    createdAt: {now_str},
    updatedAt: {now_str},
  ),
"""

code += '];\n'

with open(r'lib/data/seeds/product_catalog_seed.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print(f'Successfully generated product_catalog_seed.dart with {len(CATALOGUE)} products!')

