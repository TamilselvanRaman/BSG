import 'package:flutter/material.dart';

enum ProductCategory {
  fruit,
  veg,
  flower,
  spices,
  crop,
}

extension ProductCategoryExt on ProductCategory {
  String get id {
    switch (this) {
      case ProductCategory.fruit:
        return 'fruit';
      case ProductCategory.veg:
        return 'veg';
      case ProductCategory.flower:
        return 'flower';
      case ProductCategory.spices:
        return 'spices';
      case ProductCategory.crop:
        return 'crop';
    }
  }

  String get displayName {
    switch (this) {
      case ProductCategory.fruit:
        return 'Fruit';
      case ProductCategory.veg:
        return 'Veg';
      case ProductCategory.flower:
        return 'Flower';
      case ProductCategory.spices:
        return 'Spices';
      case ProductCategory.crop:
        return 'Crop';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductCategory.fruit:
        return Icons.apple_outlined;
      case ProductCategory.veg:
        return Icons.eco_outlined;
      case ProductCategory.flower:
        return Icons.local_florist_outlined;
      case ProductCategory.spices:
        return Icons.grain_outlined;
      case ProductCategory.crop:
        return Icons.agriculture_outlined;
    }
  }

  static ProductCategory fromString(String val) {
    final lower = val.toLowerCase().trim();
    if (lower.contains('veg')) return ProductCategory.veg;
    if (lower.contains('flower')) return ProductCategory.flower;
    if (lower.contains('spice')) return ProductCategory.spices;
    if (lower.contains('crop')) return ProductCategory.crop;
    return ProductCategory.fruit;
  }
}

class Product {
  final String id;
  final String name;
  final ProductCategory category;
  final String assetPath;
  final String? imageUrl;
  final String? description;
  final String defaultUnit;
  final double? defaultRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.assetPath,
    this.imageUrl,
    this.description,
    this.defaultUnit = 'Kg',
    this.defaultRate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get categoryId => category.id;
  String get categoryName => category.displayName;

  Product copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    String? assetPath,
    String? imageUrl,
    String? description,
    String? defaultUnit,
    double? defaultRate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      assetPath: assetPath ?? this.assetPath,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultRate: defaultRate ?? this.defaultRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.id,
      'assetPath': assetPath,
      'imageUrl': imageUrl,
      'description': description,
      'defaultUnit': defaultUnit,
      'defaultRate': defaultRate,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ProductCategoryExt.fromString(json['category'] as String? ?? 'fruit'),
      assetPath: json['assetPath'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      defaultUnit: json['defaultUnit'] as String? ?? 'Kg',
      defaultRate: (json['defaultRate'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

