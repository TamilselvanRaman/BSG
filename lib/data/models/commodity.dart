class Commodity {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final String iconEmoji;
  final String defaultUnit;
  final double defaultCostRate;
  final double defaultSellRate;
  final int colorValue;
  final bool isCustom;

  const Commodity({
    required this.id,
    required this.name,
    this.category = 'Vegetables',
    this.imageUrl,
    this.iconEmoji = '📦',
    this.defaultUnit = 'Bags',
    this.defaultCostRate = 24.0,
    this.defaultSellRate = 30.0,
    this.colorValue = 0xFF15803D,
    this.isCustom = false,
  });

  Commodity copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    String? iconEmoji,
    String? defaultUnit,
    double? defaultCostRate,
    double? defaultSellRate,
    int? colorValue,
    bool? isCustom,
  }) {
    return Commodity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultCostRate: defaultCostRate ?? this.defaultCostRate,
      defaultSellRate: defaultSellRate ?? this.defaultSellRate,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'iconEmoji': iconEmoji,
      'defaultUnit': defaultUnit,
      'defaultCostRate': defaultCostRate,
      'defaultSellRate': defaultSellRate,
      'colorValue': colorValue,
      'isCustom': isCustom,
    };
  }

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'Vegetables',
      imageUrl: json['imageUrl'] as String?,
      iconEmoji: json['iconEmoji'] as String? ?? '📦',
      defaultUnit: json['defaultUnit'] as String? ?? 'Bags',
      defaultCostRate: (json['defaultCostRate'] as num?)?.toDouble() ?? 24.0,
      defaultSellRate: (json['defaultSellRate'] as num?)?.toDouble() ?? 30.0,
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF15803D,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
